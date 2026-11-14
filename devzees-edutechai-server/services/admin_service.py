from datetime import datetime, timezone
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.exceptions import BadRequestException, NotFoundException
from models.db_models import Role, Subscription, SubscriptionTier, User
from models.admin_schemas import AdminMetricsResponse
from models.subscription_schemas import (
    SubscriptionTierCreateRequest,
    SubscriptionTierResponse,
    SubscriptionTierUpdateRequest,
)

class AdminService:
    @staticmethod
    async def get_metrics(db: AsyncSession) -> AdminMetricsResponse:
        # Total Active Users
        users_stmt = select(func.count(User.id)).where(User.retired == False)
        total_users = (await db.execute(users_stmt)).scalar() or 0

        # Total Active Roles
        roles_stmt = select(func.count(Role.id)).where(Role.retired == False)
        total_roles = (await db.execute(roles_stmt)).scalar() or 0

        # Fetch all defined tiers from the database (ordered by order_index)
        tiers_stmt = (
            select(SubscriptionTier)
            .where(SubscriptionTier.retired == False)
            .order_by(SubscriptionTier.order_index)
        )
        tiers_res = await db.execute(tiers_stmt)
        active_tiers = tiers_res.scalars().all()

        tier_names: dict[str, str] = {}
        tier_counts: dict[str, int] = {}

        # Pre-populate known active tiers
        for t in active_tiers:
            slug = t.slug.lower().strip()
            tier_names[slug] = t.name
            tier_counts[slug] = 0

        # Always ensure 'free' is present
        if "free" not in tier_counts:
            tier_counts["free"] = 0
            tier_names["free"] = "Free Tier"

        # Subscription Tiers for active users and active subscriptions
        subs_stmt = (
            select(Subscription.tier, func.count(Subscription.id))
            .join(User, User.id == Subscription.user_id)
            .where(
                User.retired == False,
                Subscription.status == 'active'
            )
            .group_by(Subscription.tier)
        )
        subs_res = await db.execute(subs_stmt)
        
        paid_accounted = 0
        for tier, count in subs_res.all():
            slug = (tier or "free").lower().strip()
            tier_counts[slug] = tier_counts.get(slug, 0) + count
            if slug not in tier_names:
                tier_names[slug] = f"{slug.capitalize()} Tier"
            if slug != "free":
                paid_accounted += count

        # Active users without an active paid subscription belong to the default free tier
        unaccounted_free_users = max(0, total_users - paid_accounted)
        tier_counts["free"] = unaccounted_free_users
        if "free" not in tier_names:
            tier_names["free"] = "Free Tier"

        return AdminMetricsResponse(
            total_users=total_users,
            free_count=tier_counts.get("free", 0),
            pro_count=tier_counts.get("pro", 0),
            ultra_count=tier_counts.get("ultra", 0),
            total_roles=total_roles,
            tier_counts=tier_counts,
            tier_names=tier_names,
        )

    # ─── Dynamic Subscription Tiers CRUD ──────────────────────────────

    @staticmethod
    async def list_tiers(
        db: AsyncSession, include_retired: bool = False
    ) -> list[SubscriptionTierResponse]:
        """List all subscription tiers with bound role name and active subscriber counts."""
        stmt = (
            select(SubscriptionTier)
            .options(selectinload(SubscriptionTier.role))
            .order_by(SubscriptionTier.order_index.asc(), SubscriptionTier.created_at.asc())
        )
        if not include_retired:
            stmt = stmt.where(SubscriptionTier.retired == False)

        res = await db.execute(stmt)
        tiers = res.scalars().all()

        # Count active subscribers per tier slug
        counts_stmt = (
            select(Subscription.tier, func.count(Subscription.id))
            .where(Subscription.status == "active")
            .group_by(Subscription.tier)
        )
        counts_res = await db.execute(counts_stmt)
        slug_to_count = {slug.lower(): count for slug, count in counts_res.all()}

        output = []
        for t in tiers:
            count = slug_to_count.get(t.slug.lower(), 0)
            dto = SubscriptionTierResponse(
                id=t.id,
                slug=t.slug,
                name=t.name,
                description=t.description,
                role_id=t.role_id,
                role_name=t.role.name if t.role else None,
                price_monthly=t.price_monthly,
                price_annual=t.price_annual,
                currency=t.currency,
                monthly_session_limit=t.monthly_session_limit,
                follow_up_limit_per_step=t.follow_up_limit_per_step,
                youtube_limit_per_step=t.youtube_limit_per_step,
                is_public=t.is_public,
                order_index=t.order_index,
                retired=t.retired,
                created_at=t.created_at,
                active_subscribers_count=count,
            )
            output.append(dto)
        return output

    @staticmethod
    async def get_tier_by_id(db: AsyncSession, tier_id: str) -> SubscriptionTier:
        stmt = (
            select(SubscriptionTier)
            .options(selectinload(SubscriptionTier.role))
            .where(SubscriptionTier.id == tier_id)
        )
        res = await db.execute(stmt)
        tier = res.scalar_one_or_none()
        if not tier:
            raise NotFoundException(error_code="TIER_NOT_FOUND", errors=f"Subscription tier '{tier_id}' not found.")
        return tier

    @staticmethod
    async def create_tier(
        db: AsyncSession, dto: SubscriptionTierCreateRequest, current_user_id: str | None = None
    ) -> SubscriptionTierResponse:
        slug = dto.slug.lower().strip()
        # Verify slug uniqueness
        existing_stmt = select(SubscriptionTier).where(SubscriptionTier.slug == slug)
        existing = (await db.execute(existing_stmt)).scalar_one_or_none()
        if existing:
            raise BadRequestException(
                error_code="TIER_SLUG_EXISTS", errors=f"Subscription tier with slug '{slug}' already exists."
            )

        # Verify role exists
        role_stmt = select(Role).where(Role.id == dto.role_id, Role.retired == False)
        role = (await db.execute(role_stmt)).scalar_one_or_none()
        if not role:
            raise BadRequestException(
                error_code="ROLE_NOT_FOUND", errors=f"Target role '{dto.role_id}' does not exist or is retired."
            )

        tier = SubscriptionTier(
            slug=slug,
            name=dto.name.strip(),
            description=dto.description.strip() if dto.description else None,
            role_id=role.id,
            price_monthly=dto.price_monthly,
            price_annual=dto.price_annual,
            currency=dto.currency.upper().strip(),
            monthly_session_limit=dto.monthly_session_limit,
            follow_up_limit_per_step=dto.follow_up_limit_per_step,
            youtube_limit_per_step=dto.youtube_limit_per_step,
            is_public=dto.is_public,
            order_index=dto.order_index,
        )
        db.add(tier)
        await db.commit()
        await db.refresh(tier)

        return SubscriptionTierResponse(
            id=tier.id,
            slug=tier.slug,
            name=tier.name,
            description=tier.description,
            role_id=tier.role_id,
            role_name=role.name,
            price_monthly=tier.price_monthly,
            price_annual=tier.price_annual,
            currency=tier.currency,
            monthly_session_limit=tier.monthly_session_limit,
            follow_up_limit_per_step=tier.follow_up_limit_per_step,
            youtube_limit_per_step=tier.youtube_limit_per_step,
            is_public=tier.is_public,
            order_index=tier.order_index,
            retired=tier.retired,
            created_at=tier.created_at,
            active_subscribers_count=0,
        )

    @staticmethod
    async def update_tier(
        db: AsyncSession, tier_id: str, dto: SubscriptionTierUpdateRequest, current_user_id: str | None = None
    ) -> SubscriptionTierResponse:
        tier = await AdminService.get_tier_by_id(db, tier_id)

        if dto.role_id is not None:
            role_stmt = select(Role).where(Role.id == dto.role_id, Role.retired == False)
            role = (await db.execute(role_stmt)).scalar_one_or_none()
            if not role:
                raise BadRequestException(
                    error_code="ROLE_NOT_FOUND", errors=f"Target role '{dto.role_id}' does not exist or is retired."
                )
            tier.role_id = role.id

        if dto.name is not None:
            tier.name = dto.name.strip()
        if dto.description is not None:
            tier.description = dto.description.strip() if dto.description else None
        if dto.price_monthly is not None:
            tier.price_monthly = dto.price_monthly
        if dto.price_annual is not None:
            tier.price_annual = dto.price_annual
        if dto.currency is not None:
            tier.currency = dto.currency.upper().strip()
        if dto.monthly_session_limit is not None or "monthly_session_limit" in dto.model_fields_set:
            tier.monthly_session_limit = dto.monthly_session_limit
        if dto.follow_up_limit_per_step is not None or "follow_up_limit_per_step" in dto.model_fields_set:
            tier.follow_up_limit_per_step = dto.follow_up_limit_per_step
        if dto.youtube_limit_per_step is not None or "youtube_limit_per_step" in dto.model_fields_set:
            tier.youtube_limit_per_step = dto.youtube_limit_per_step
        if dto.is_public is not None:
            tier.is_public = dto.is_public
        if dto.order_index is not None:
            tier.order_index = dto.order_index

        await db.commit()
        await db.refresh(tier)

        # Count active subscribers
        counts_stmt = select(func.count(Subscription.id)).where(
            Subscription.tier == tier.slug, Subscription.status == "active"
        )
        count = (await db.execute(counts_stmt)).scalar() or 0

        return SubscriptionTierResponse(
            id=tier.id,
            slug=tier.slug,
            name=tier.name,
            description=tier.description,
            role_id=tier.role_id,
            role_name=tier.role.name if tier.role else None,
            price_monthly=tier.price_monthly,
            price_annual=tier.price_annual,
            currency=tier.currency,
            monthly_session_limit=tier.monthly_session_limit,
            follow_up_limit_per_step=tier.follow_up_limit_per_step,
            youtube_limit_per_step=tier.youtube_limit_per_step,
            is_public=tier.is_public,
            order_index=tier.order_index,
            retired=tier.retired,
            created_at=tier.created_at,
            active_subscribers_count=count,
        )

    @staticmethod
    async def retire_tier(
        db: AsyncSession, tier_id: str, current_user_id: str | None = None
    ) -> None:
        tier = await AdminService.get_tier_by_id(db, tier_id)
        if tier.retired:
            return

        if tier.slug == "free":
            raise BadRequestException(
                error_code="CANNOT_RETIRE_DEFAULT_TIER", errors="Default 'free' tier cannot be retired."
            )

        # Check if active subscribers exist
        counts_stmt = select(func.count(Subscription.id)).where(
            Subscription.tier == tier.slug, Subscription.status == "active"
        )
        count = (await db.execute(counts_stmt)).scalar() or 0
        if count > 0:
            raise BadRequestException(
                error_code="ACTIVE_SUBSCRIBERS_EXIST",
                errors=f"Cannot retire tier '{tier.name}'. There are {count} active subscribers. Please reassign them first.",
            )

        tier.retired = True
        tier.retired_at = datetime.now(timezone.utc).replace(tzinfo=None)
        tier.retired_by = current_user_id
        await db.commit()
