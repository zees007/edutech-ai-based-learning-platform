import asyncio
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from sqlalchemy import select
from services.database import get_db_session
from models.db_models import Privilege, Role

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
                    "ET_ASSIGN_USER_ROLE": "Assign Role to User"
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
                    "ET_MANAGE_BILLING": "Manage Global Billing & Transactions"
                }
            },
            "ET_FULL_ACCESS_LEARNING": {
                "name": "Learning Management",
                "children": {
                    "ET_START_LEARNING_SESSION": "Start Learning Session",
                    "ET_INTERACT_LEARNING_SESSION": "Interact Learning Session",
                    "ET_VIEW_LEARNING_HISTORY": "View Learning History",
                    "ET_MANAGE_KNOWLEDGE_BASE": "Manage Knowledge Base",
                    "ET_ACCESS_VISUAL_MODE": "Access Visual Mode",
                    "ET_ACCESS_DEEP_DIVE_MODE": "Access Deep Dive Mode",
                    "ET_REGENERATE_STEP": "Regenerate Step",
                    "ET_ACCESS_ACADEMIC_SEARCH": "Access Academic Search",
                    "ET_ACCESS_FULL_TEXT_RESEARCH": "Access Full Text Research",
                    "ET_UNLIMITED_FOLLOW_UPS": "Unlimited Follow Ups"
                }
            },
            "ET_FULL_ACCESS_VIDEO": {
                "name": "Video Management",
                "children": {
                    "ET_ACCESS_YOUTUBE_BASIC": "Access Youtube Basic",
                    "ET_ACCESS_YOUTUBE_ADVANCED": "Access Youtube Advanced"
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
            }
        }
    }
}

ROLE_PRIVILEGES = {
    "Admin": ["ET_ALL"],
    "Free": [
        "ET_VIEW_SUBSCRIPTION", "ET_UPGRADE_SUBSCRIPTION",
        "ET_START_LEARNING_SESSION", "ET_INTERACT_LEARNING_SESSION",
        "ET_VIEW_LEARNING_HISTORY", "ET_ACCESS_YOUTUBE_BASIC",
        "ET_GENERATE_QUIZ", "ET_SUBMIT_QUIZ",
        "ET_ACCESS_VISUAL_MODE", "ET_ACCESS_ACADEMIC_SEARCH"
    ],
    "Pro": [
        "ET_VIEW_SUBSCRIPTION", "ET_UPGRADE_SUBSCRIPTION", "ET_DOWNGRADE_SUBSCRIPTION",
        "ET_START_LEARNING_SESSION", "ET_INTERACT_LEARNING_SESSION",
        "ET_VIEW_LEARNING_HISTORY", "ET_ACCESS_YOUTUBE_BASIC",
        "ET_GENERATE_QUIZ", "ET_SUBMIT_QUIZ",
        "ET_ACCESS_VISUAL_MODE", "ET_ACCESS_DEEP_DIVE_MODE",
        "ET_REGENERATE_STEP", "ET_ACCESS_YOUTUBE_ADVANCED",
        "ET_ACCESS_ACADEMIC_SEARCH", "ET_EXPORT_MARKDOWN", "ET_EXPORT_HTML"
    ],
    "Ultra": [
        "ET_VIEW_SUBSCRIPTION", "ET_UPGRADE_SUBSCRIPTION", "ET_DOWNGRADE_SUBSCRIPTION",
        "ET_START_LEARNING_SESSION", "ET_INTERACT_LEARNING_SESSION",
        "ET_VIEW_LEARNING_HISTORY", "ET_ACCESS_YOUTUBE_BASIC",
        "ET_GENERATE_QUIZ", "ET_SUBMIT_QUIZ",
        "ET_ACCESS_VISUAL_MODE", "ET_ACCESS_DEEP_DIVE_MODE",
        "ET_REGENERATE_STEP", "ET_ACCESS_YOUTUBE_ADVANCED",
        "ET_ACCESS_ACADEMIC_SEARCH", "ET_EXPORT_MARKDOWN", "ET_EXPORT_HTML",
        "ET_ACCESS_FULL_TEXT_RESEARCH", "ET_UNLIMITED_FOLLOW_UPS", "ET_EXPORT_PDF"
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

        await db.commit()
        print("Privileges and Roles seeded successfully!")

if __name__ == "__main__":
    asyncio.run(seed_privileges_and_roles())
