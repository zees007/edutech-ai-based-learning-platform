import asyncio
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import select
from services.database import get_db_session
from models.db_models import Privilege, Role, SubscriptionTier

TREE = {
    "ET_ALL": {
        "name": "Super Admin Bypass",
        "children": {
            "ET_FULL_ACCESS_ADMIN": {
                "name": "Admin & System Management",
                "children": {
                    "ET_VIEW_ANALYTICS": "View Analytics & Metrics",
                    "ET_MANAGE_SYSTEM_SETTINGS": "Manage System Settings"
                }
            },
            "ET_FULL_ACCESS_USER": {
                "name": "User Management",
                "children": {
                    "ET_CREATE_USER": "Create User",
                    "ET_VIEW_USER": "View & Search User",
                    "ET_EDIT_USER": "Edit User",
                    "ET_RETIRE_USER": "Retire User",
                    "ET_ASSIGN_USER_ROLE": "Assign Role to User",
                    "ET_CHANGE_PASSWORD": "Change Password"
                }
            },
            "ET_FULL_ACCESS_ROLE": {
                "name": "Role & Privilege Management",
                "children": {
                    "ET_CREATE_ROLE": "Create Role",
                    "ET_VIEW_ROLE": "View & Search Role",
                    "ET_EDIT_ROLE": "Edit Role",
                    "ET_RETIRE_ROLE": "Retire Role",
                    "ET_VIEW_PRIVILEGE": "View Privileges"
                }
            },
            "ET_FULL_ACCESS_SUBSCRIPTION": {
                "name": "Subscription Management",
                "children": {
                    "ET_VIEW_SUBSCRIPTION": "View Subscription",
                    "ET_UPGRADE_SUBSCRIPTION": "Upgrade Subscription",
                    "ET_DOWNGRADE_SUBSCRIPTION": "Downgrade Subscription",
                    "ET_MANAGE_BILLING": "Manage Global Billing & Transactions",
                    "ET_MANAGE_TIERS": "Manage Subscription Tiers"
                }
            },
            "ET_FULL_ACCESS_LEARNING": {
                "name": "Learning Management",
                "children": {
                    "ET_START_LEARNING_SESSION": "Start Learning Session",
                    "ET_INTERACT_LEARNING_SESSION": "Interact Learning Session",
                    "ET_VIEW_LEARNING_HISTORY": "View Learning History",
                    "ET_VIEW_QUOTA": "View Monthly Session Quota",
                    "ET_DASHBOARD": "Access Learner Performance Dashboard",
                    "ET_MANAGE_KNOWLEDGE_BASE": "Manage Knowledge Base",
                    "ET_ACCESS_VISUAL_MODE": "Access Visual Mode",
                    "ET_ACCESS_DEEP_DIVE_MODE": "Access Deep Dive Mode",
                    "ET_REGENERATE_STEP": "Regenerate Step",
                    "ET_ACCESS_ACADEMIC_SEARCH": "Access Academic Search",
                    "ET_READ_ACADEMIC_PAPER": "Read Academic Paper & PDF"
                }
            },
            "ET_FULL_ACCESS_EXPORT": {
                "name": "Export Management",
                "children": {
                    "ET_EXPORT_MARKDOWN": "Export Markdown",
                    "ET_EXPORT_HTML": "Export Html",
                    "ET_EXPORT_PDF": "Export Pdf"
                }
            },
            "ET_FULL_ACCESS_QUIZ": {
                "name": "Quiz Management",
                "children": {
                    "ET_GENERATE_QUIZ": "Generate Quiz",
                    "ET_SUBMIT_QUIZ": "Submit Quiz"
                }
            },
            "ET_FULL_ACCESS_FEEDBACK": {
                "name": "Feedback & Testimonial Management",
                "children": {
                    "ET_SUBMIT_FEEDBACK": "Submit Learning Session Feedback",
                    "ET_MODERATE_FEEDBACK": "Moderate and Feature Testimonials (Admin)"
                }
            }
        }
    }
}

ROLE_PRIVILEGES = {
    "Admin": ["ET_ALL"],
    "Free": [
        "ET_VIEW_SUBSCRIPTION", "ET_UPGRADE_SUBSCRIPTION",
        "ET_START_LEARNING_SESSION", "ET_INTERACT_LEARNING_SESSION",
        "ET_VIEW_LEARNING_HISTORY", "ET_VIEW_QUOTA", "ET_DASHBOARD",
        "ET_GENERATE_QUIZ", "ET_SUBMIT_QUIZ",
        "ET_ACCESS_VISUAL_MODE", "ET_SUBMIT_FEEDBACK",
        "ET_CHANGE_PASSWORD"
    ],
    "Pro": [
        "ET_VIEW_SUBSCRIPTION", "ET_UPGRADE_SUBSCRIPTION", "ET_DOWNGRADE_SUBSCRIPTION",
        "ET_START_LEARNING_SESSION", "ET_INTERACT_LEARNING_SESSION",
        "ET_VIEW_LEARNING_HISTORY", "ET_VIEW_QUOTA", "ET_DASHBOARD",
        "ET_GENERATE_QUIZ", "ET_SUBMIT_QUIZ",
        "ET_ACCESS_VISUAL_MODE", "ET_ACCESS_DEEP_DIVE_MODE",
        "ET_REGENERATE_STEP",
        "ET_READ_ACADEMIC_PAPER", "ET_EXPORT_MARKDOWN", "ET_EXPORT_HTML", "ET_SUBMIT_FEEDBACK",
        "ET_CHANGE_PASSWORD"
    ],
    "Ultra": [
        "ET_VIEW_SUBSCRIPTION", "ET_DOWNGRADE_SUBSCRIPTION",
        "ET_START_LEARNING_SESSION", "ET_INTERACT_LEARNING_SESSION",
        "ET_VIEW_LEARNING_HISTORY", "ET_VIEW_QUOTA", "ET_DASHBOARD",
        "ET_GENERATE_QUIZ", "ET_SUBMIT_QUIZ",
        "ET_ACCESS_VISUAL_MODE", "ET_ACCESS_DEEP_DIVE_MODE",
        "ET_REGENERATE_STEP",
        "ET_ACCESS_ACADEMIC_SEARCH", "ET_EXPORT_MARKDOWN", "ET_EXPORT_HTML",
        "ET_READ_ACADEMIC_PAPER", "ET_EXPORT_PDF", "ET_SUBMIT_FEEDBACK",
        "ET_CHANGE_PASSWORD"
    ]
}

async def seed_privileges_and_roles():
    print("Starting privilege and role seeding...")
    async with get_db_session() as db:
        required_nodes = []
        def traverse(node_dict, parent_code=None):
            for code, data in node_dict.items():
                if isinstance(data, dict):
                    required_nodes.append({"code": code, "name": data["name"], "parent_code": parent_code})
                    traverse(data["children"], parent_code=code)
                else:
                    required_nodes.append({"code": code, "name": data, "parent_code": parent_code})

        traverse(TREE)

        # 0. Clean up any rogue/test/obsolete privileges not in official TREE
        valid_codes = {node["code"] for node in required_nodes}
        existing_privs = (await db.execute(select(Privilege))).scalars().all()
        for p in existing_privs:
            if p.code not in valid_codes:
                await db.delete(p)
        await db.flush()

        print("1. Inserting privileges...")
        for node in required_nodes:
            res = await db.execute(select(Privilege).where(Privilege.code == node["code"]))
            p = res.scalar_one_or_none()
            if not p:
                p = Privilege(name=node["name"], code=node["code"])
                db.add(p)
        
        await db.flush()
        
        all_privs = (await db.execute(select(Privilege))).scalars().all()
        code_to_priv = {p.code: p for p in all_privs}

        order_idx = 1
        for node in required_nodes:
            p = code_to_priv[node["code"]]
            p.parent_id = code_to_priv[node["parent_code"]].id if node["parent_code"] else None
            p.order_number = order_idx
            order_idx += 1
            
        print("2. Inserting roles...")
        for role_name, priv_codes in ROLE_PRIVILEGES.items():
            res = await db.execute(select(Role).where(Role.name == role_name))
            role = res.scalar_one_or_none()
            if not role:
                role = Role(name=role_name)
                db.add(role)
            
            # Update privileges for the role
            role.privileges = [code_to_priv[code] for code in priv_codes if code in code_to_priv]

        # Prune rogue roles not in ROLE_PRIVILEGES
        canonical_role_names = set(ROLE_PRIVILEGES.keys())
        all_db_roles = (await db.execute(select(Role))).scalars().all()
        for r in all_db_roles:
            if r.name not in canonical_role_names:
                print(f"Pruning rogue role: {r.name}")
                await db.delete(r)

        await db.flush()

        print("3. Inserting default subscription tiers...")
        all_roles_res = await db.execute(select(Role))
        name_to_role = {r.name: r for r in all_roles_res.scalars().all()}

        DEFAULT_TIERS = [
            {
                "slug": "free",
                "name": "Free Tier",
                "description": "Essential learning journey with monthly AI credits and basic quizzes.",
                "role_name": "Free",
                "price_monthly": 0.0,
                "price_annual": 0.0,
                "streak_multiplier": 1.0,
                "monthly_session_limit": 10,
                "follow_up_limit_per_step": 1,
                "youtube_limit_per_step": 1,
                "is_public": True,
                "order_index": 1,
            },
            {
                "slug": "pro",
                "name": "Pro Tier",
                "description": "Deep-dive learning mode, academic paper reading, advanced YouTube curation, and step regeneration.",
                "role_name": "Pro",
                "price_monthly": 19.0,
                "price_annual": 180.0,
                "streak_multiplier": 1.5,
                "monthly_session_limit": None,
                "follow_up_limit_per_step": 5,
                "youtube_limit_per_step": 3,
                "is_public": True,
                "order_index": 2,
            },
            {
                "slug": "ultra",
                "name": "Ultra Tier",
                "description": "Unlimited follow-ups, live academic search, PDF exports, and top AI models.",
                "role_name": "Ultra",
                "price_monthly": 49.0,
                "price_annual": 470.0,
                "streak_multiplier": 2.0,
                "monthly_session_limit": None,
                "follow_up_limit_per_step": None,
                "youtube_limit_per_step": 5,
                "is_public": True,
                "order_index": 3,
            },
        ]

        # Prune rogue tiers not in DEFAULT_TIERS
        canonical_tier_slugs = {t["slug"] for t in DEFAULT_TIERS}
        all_db_tiers = (await db.execute(select(SubscriptionTier))).scalars().all()
        for t in all_db_tiers:
            if t.slug not in canonical_tier_slugs:
                print(f"Pruning rogue tier: {t.slug}")
                await db.delete(t)
        await db.flush()

        for t_data in DEFAULT_TIERS:
            t_res = await db.execute(select(SubscriptionTier).where(SubscriptionTier.slug == t_data["slug"]))
            tier_obj = t_res.scalar_one_or_none()
            bound_role = name_to_role.get(t_data["role_name"])
            if not bound_role:
                continue

            if not tier_obj:
                tier_obj = SubscriptionTier(
                    slug=t_data["slug"],
                    name=t_data["name"],
                    description=t_data["description"],
                    role_id=bound_role.id,
                    price_monthly=t_data["price_monthly"],
                    price_annual=t_data["price_annual"],
                    streak_multiplier=t_data.get("streak_multiplier", 1.0),
                    monthly_session_limit=t_data["monthly_session_limit"],
                    follow_up_limit_per_step=t_data["follow_up_limit_per_step"],
                    youtube_limit_per_step=t_data["youtube_limit_per_step"],
                    is_public=t_data["is_public"],
                    order_index=t_data["order_index"],
                )
                db.add(tier_obj)
            else:
                tier_obj.name = t_data["name"]
                tier_obj.description = t_data["description"]
                tier_obj.role_id = bound_role.id
                tier_obj.price_monthly = t_data["price_monthly"]
                tier_obj.price_annual = t_data["price_annual"]
                tier_obj.streak_multiplier = t_data.get("streak_multiplier", 1.0)
                tier_obj.monthly_session_limit = t_data["monthly_session_limit"]
                tier_obj.follow_up_limit_per_step = t_data["follow_up_limit_per_step"]
                tier_obj.youtube_limit_per_step = t_data["youtube_limit_per_step"]
                tier_obj.is_public = t_data["is_public"]
                tier_obj.order_index = t_data["order_index"]
                tier_obj.retired = False

        await db.commit()
        print("Privileges, Roles, and Subscription Tiers seeded successfully!")

if __name__ == "__main__":
    asyncio.run(seed_privileges_and_roles())
