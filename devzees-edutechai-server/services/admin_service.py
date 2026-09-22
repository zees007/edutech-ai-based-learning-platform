from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from models.db_models import Role, Subscription, User
from models.admin_schemas import AdminMetricsResponse

class AdminService:
    @staticmethod
    async def get_metrics(db: AsyncSession) -> AdminMetricsResponse:
        # Total Active Users
        users_stmt = select(func.count(User.id)).where(User.retired == False)
        total_users = (await db.execute(users_stmt)).scalar() or 0

        # Total Active Roles
        roles_stmt = select(func.count(Role.id)).where(Role.retired == False)
        total_roles = (await db.execute(roles_stmt)).scalar() or 0

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
        
        free_count = 0
        pro_count = 0
        ultra_count = 0
        
        for tier, count in subs_res.all():
            if tier.lower() == 'free':
                free_count += count
            elif tier.lower() == 'pro':
                pro_count += count
            elif tier.lower() == 'ultra':
                ultra_count += count

        return AdminMetricsResponse(
            total_users=total_users,
            free_count=free_count,
            pro_count=pro_count,
            ultra_count=ultra_count,
            total_roles=total_roles,
        )
