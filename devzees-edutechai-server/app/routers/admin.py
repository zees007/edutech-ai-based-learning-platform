from typing import List

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_current_user, require_privilege
from app.privileges_config import (
    ET_FULL_ACCESS_SUBSCRIPTION,
    ET_MANAGE_BILLING,
    ET_MANAGE_SYSTEM_SETTINGS,
    ET_MANAGE_TIERS,
    ET_VIEW_ANALYTICS,
)
from models.admin_schemas import AdminMetricsResponse
from models.db_models import User
from models.setting_schemas import SettingResponse, SettingUpdateRequest
from models.subscription_schemas import (
    SubscriptionTierCreateRequest,
    SubscriptionTierResponse,
    SubscriptionTierUpdateRequest,
)
from services.admin_service import AdminService
from services.database import get_db
from services.setting_service import SettingService

router = APIRouter()


@router.get(
    "/admin/metrics",
    response_model=AdminMetricsResponse,
    dependencies=[Depends(require_privilege(ET_VIEW_ANALYTICS))],
)
async def get_admin_metrics(
    db: AsyncSession = Depends(get_db),
):
    """Retrieve global admin dashboard metrics."""
    return await AdminService.get_metrics(db)


@router.get(
    "/admin/settings",
    response_model=List[SettingResponse],
    dependencies=[Depends(require_privilege(ET_MANAGE_SYSTEM_SETTINGS))],
)
async def get_all_settings(
    db: AsyncSession = Depends(get_db),
):
    """Retrieve all dynamic system configuration settings."""
    settings = await SettingService.get_all_settings(db)
    return [SettingResponse.model_validate(s) for s in settings]


@router.get(
    "/admin/settings/{code}",
    response_model=SettingResponse,
    dependencies=[Depends(require_privilege(ET_MANAGE_SYSTEM_SETTINGS))],
)
async def get_setting_by_code(
    code: str,
    db: AsyncSession = Depends(get_db),
):
    """Retrieve a single system configuration setting by code."""
    setting = await SettingService.get_setting_by_code(db, code)
    return SettingResponse.model_validate(setting)


@router.put(
    "/admin/settings/{code}",
    response_model=SettingResponse,
    dependencies=[Depends(require_privilege(ET_MANAGE_SYSTEM_SETTINGS))],
)
async def update_setting_by_code(
    code: str,
    request: SettingUpdateRequest,
    db: AsyncSession = Depends(get_db),
):
    """Update a system configuration setting value and optional order number."""
    updated = await SettingService.update_setting(
        db=db,
        code=code,
        value=request.value,
        order_number=request.order_number,
    )
    return SettingResponse.model_validate(updated)


# ─── Subscription Tier Management Endpoints ──────────────────────────

@router.get(
    "/admin/tiers",
    response_model=List[SubscriptionTierResponse],
    dependencies=[Depends(require_privilege(ET_MANAGE_TIERS, ET_FULL_ACCESS_SUBSCRIPTION))],
)
async def list_subscription_tiers(
    include_retired: bool = False,
    db: AsyncSession = Depends(get_db),
):
    """List all available dynamic subscription tiers."""
    return await AdminService.list_tiers(db=db, include_retired=include_retired)


@router.post(
    "/admin/tiers",
    response_model=SubscriptionTierResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_privilege(ET_MANAGE_TIERS, ET_FULL_ACCESS_SUBSCRIPTION))],
)
async def create_subscription_tier(
    request: SubscriptionTierCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new dynamic subscription tier with bound role and limits."""
    return await AdminService.create_tier(db=db, dto=request, current_user_id=current_user.id)


@router.put(
    "/admin/tiers/{tier_id}",
    response_model=SubscriptionTierResponse,
    dependencies=[Depends(require_privilege(ET_MANAGE_TIERS, ET_FULL_ACCESS_SUBSCRIPTION))],
)
async def update_subscription_tier(
    tier_id: str,
    request: SubscriptionTierUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update an existing subscription tier's details, bound role, or limits."""
    return await AdminService.update_tier(db=db, tier_id=tier_id, dto=request, current_user_id=current_user.id)


@router.delete(
    "/admin/tiers/{tier_id}",
    dependencies=[Depends(require_privilege(ET_MANAGE_TIERS, ET_FULL_ACCESS_SUBSCRIPTION))],
)
async def retire_subscription_tier(
    tier_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Soft-retire a subscription tier (only if no active paying subscribers exist)."""
    await AdminService.retire_tier(db=db, tier_id=tier_id, current_user_id=current_user.id)
    return {"success": True, "message": f"Subscription tier '{tier_id}' retired successfully."}

