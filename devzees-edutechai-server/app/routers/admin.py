from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import require_privilege
from app.privileges_config import ET_SEARCH_USER
from models.admin_schemas import AdminMetricsResponse
from services.admin_service import AdminService
from services.database import get_db

router = APIRouter()

@router.get(
    "/admin/metrics",
    response_model=AdminMetricsResponse,
    dependencies=[Depends(require_privilege(ET_SEARCH_USER))],
)
async def get_admin_metrics(
    db: AsyncSession = Depends(get_db),
):
    """Retrieve global admin dashboard metrics."""
    return await AdminService.get_metrics(db)
