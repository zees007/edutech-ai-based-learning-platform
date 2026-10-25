from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import require_privilege
from app.privileges_config import ET_MANAGE_SYSTEM_SETTINGS, ET_VIEW_ANALYTICS
from models.admin_schemas import AdminMetricsResponse
from models.setting_schemas import SettingResponse, SettingUpdateRequest
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

