"""
EduTechAI — Role Service Layer

Encapsulates database access and business logic for role management operations.
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.exceptions import BadRequestException, ConflictException, NotFoundException
from models.db_models import Privilege, Role
from models.role_schemas import PrivilegeTreeResponse, RoleCreateRequest, RoleEditRequest
from models.user_schemas import SearchDTO

logger = logging.getLogger(__name__)


class RoleService:
    """Service layer for role operations."""

    @staticmethod
    async def create_role(db: AsyncSession, dto: RoleCreateRequest) -> Role:
        """
        Create a new role. Raises ConflictException if role name already exists,
        or BadRequestException if any specified privilege_ids are invalid.
        """
        # Check duplicate role name
        stmt = select(Role).where(Role.name == dto.name)
        res = await db.execute(stmt)
        if res.scalar_one_or_none() is not None:
            raise ConflictException(
                error_code="ROLE_NAME_ALREADY_EXISTS",
                errors=f"A role with name '{dto.name}' already exists.",
            )

        # Validate privilege IDs if provided
        privileges: list[Privilege] = []
        if dto.privilege_ids:
            p_stmt = select(Privilege).where(Privilege.id.in_(dto.privilege_ids))
            p_res = await db.execute(p_stmt)
            privileges = list(p_res.scalars().all())

            found_ids = {p.id for p in privileges}
            missing_ids = [pid for pid in set(dto.privilege_ids) if pid not in found_ids]
            if missing_ids:
                raise BadRequestException(
                    error_code="INVALID_PRIVILEGE_ID",
                    errors=f"Privilege ID(s) {missing_ids} do not exist.",
                )

        role = Role(name=dto.name, privileges=privileges)
        db.add(role)
        await db.commit()
        await db.refresh(role)
        logger.info(f"Role created: {role.id} ('{role.name}')")
        return role

    @staticmethod
    async def get_role_by_id(db: AsyncSession, role_id: str) -> Role:
        """
        Retrieve role by UUID. Raises NotFoundException if not found.
        """
        stmt = select(Role).where(Role.id == role_id)
        res = await db.execute(stmt)
        role = res.scalar_one_or_none()
        if role is None:
            raise NotFoundException(
                error_code="ROLE_NOT_FOUND",
                errors=f"Role with ID '{role_id}' was not found.",
            )
        return role

    @staticmethod
    async def edit_role(db: AsyncSession, role_id: str, dto: RoleEditRequest) -> Role:
        """
        Update role details and privilege assignments.
        Raises NotFoundException if role not found, ConflictException if duplicate name,
        or BadRequestException if invalid privilege ID.
        """
        role = await RoleService.get_role_by_id(db, role_id)

        if dto.name is not None and dto.name != role.name:
            stmt = select(Role).where(Role.name == dto.name, Role.id != role_id)
            res = await db.execute(stmt)
            if res.scalar_one_or_none() is not None:
                raise ConflictException(
                    error_code="ROLE_NAME_ALREADY_EXISTS",
                    errors=f"A role with name '{dto.name}' already exists.",
                )
            role.name = dto.name

        if dto.privilege_ids is not None:
            if dto.privilege_ids:
                p_stmt = select(Privilege).where(Privilege.id.in_(dto.privilege_ids))
                p_res = await db.execute(p_stmt)
                privileges = list(p_res.scalars().all())

                found_ids = {p.id for p in privileges}
                missing_ids = [pid for pid in set(dto.privilege_ids) if pid not in found_ids]
                if missing_ids:
                    raise BadRequestException(
                        error_code="INVALID_PRIVILEGE_ID",
                        errors=f"Privilege ID(s) {missing_ids} do not exist.",
                    )
                role.privileges = privileges
            else:
                role.privileges = []

        await db.commit()
        await db.refresh(role)
        logger.info(f"Role updated: {role.id} ('{role.name}')")
        return role

    @staticmethod
    async def retire_role(db: AsyncSession, role_id: str) -> Role:
        """
        Soft-retire a role by setting retired=True and recording retired_at.
        Raises NotFoundException if role not found or BadRequestException if already retired.
        """
        role = await RoleService.get_role_by_id(db, role_id)
        if role.retired:
            raise BadRequestException(
                error_code="ROLE_ALREADY_RETIRED",
                errors=f"Role with ID '{role_id}' is already retired.",
            )

        role.retired = True
        role.retired_at = datetime.now(timezone.utc).replace(tzinfo=None)
        role.retired_by = None

        await db.commit()
        await db.refresh(role)
        logger.info(f"Role retired: {role.id}")
        return role

    @staticmethod
    async def search_roles(db: AsyncSession, dto: SearchDTO) -> tuple[list[Role], int]:
        """
        Search active roles (retired=False) with 0-indexed pagination, sorting, and lookupText filtering.
        Returns tuple of (roles_list, total_count).
        """
        query = select(Role).where(Role.retired == False)

        lookup = dto.lookupText
        if lookup and lookup.strip():
            term = f"%{lookup.strip()}%"
            query = query.where(Role.name.ilike(term))

        # Count total matching active records
        count_query = select(func.count()).select_from(query.subquery())
        total_res = await db.execute(count_query)
        total = total_res.scalar_one() or 0

        # Sort field resolution
        raw_sort = (dto.sortBy or "created_at").lower().replace("_", "")
        sort_map = {
            "createdat": Role.created_at,
            "name": Role.name,
            "id": Role.id,
        }
        sort_column = sort_map.get(raw_sort, Role.created_at)

        if dto.isDesc:
            query = query.order_by(sort_column.desc())
        else:
            query = query.order_by(sort_column.asc())

        offset = dto.page * dto.size
        query = query.offset(offset).limit(dto.size)

        res = await db.execute(query)
        roles = list(res.scalars().all())

        return roles, total

    @staticmethod
    async def get_all_privileges(db: AsyncSession) -> list[Privilege]:
        """
        Fetch all privileges sorted by order_number and ID.
        """
        stmt = select(Privilege).order_by(
            Privilege.order_number.asc().nulls_last(),
            Privilege.id.asc(),
        )
        res = await db.execute(stmt)
        return list(res.scalars().all())

    @staticmethod
    async def get_privilege_tree(db: AsyncSession) -> list[PrivilegeTreeResponse]:
        """
        Build and return a hierarchical tree structure of privileges.
        Top-level privileges (parent_id is None) appear at the root level,
        with child privileges recursively nested under their respective parents.
        """
        all_privileges = await RoleService.get_all_privileges(db)

        # Map ID -> PrivilegeTreeResponse node
        nodes: dict[int, PrivilegeTreeResponse] = {}
        for p in all_privileges:
            nodes[p.id] = PrivilegeTreeResponse(
                id=p.id,
                name=p.name,
                code=p.code,
                order_number=p.order_number,
                parent_id=p.parent_id,
                children=[],
            )

        root_nodes: list[PrivilegeTreeResponse] = []
        for p in all_privileges:
            node = nodes[p.id]
            if p.parent_id is None:
                root_nodes.append(node)
            elif p.parent_id in nodes:
                nodes[p.parent_id].children.append(node)
            else:
                # Fallback if parent_id is missing/broken
                root_nodes.append(node)

        return root_nodes

