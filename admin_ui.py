"""
EduTechAI — Interactive Admin Panel (Streamlit Frontend)

An interactive back-office administration tool for managing:
- 👥 Users & Role Assignments
- 🛡️ System Roles & Fine-grained Privileges
- 💳 Subscription Tiers (Normal, Pro, Ultra) & Automated Tier Role Syncing
- 📊 Platform Analytics & Subscription Distribution Metrics
"""

from __future__ import annotations

import asyncio
import math
import os
import sys

import streamlit as st

# Custom CSS Styling for Modern Premium Look
ADMIN_CSS = """
<style>
    .admin-header {
        font-size: 2.2rem;
        font-weight: 800;
        background: linear-gradient(135deg, #7C3AED 0%, #3B82F6 50%, #06B6D4 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin-bottom: 0.2rem;
    }
    .admin-sub {
        color: #94A3B8;
        font-size: 1.0rem;
        margin-bottom: 1.5rem;
    }
    .tier-badge-normal {
        background-color: #334155;
        color: #F8FAFC;
        padding: 4px 10px;
        border-radius: 12px;
        font-weight: 600;
        font-size: 0.85rem;
    }
    .tier-badge-pro {
        background-color: #2563EB;
        color: #FFFFFF;
        padding: 4px 10px;
        border-radius: 12px;
        font-weight: 600;
        font-size: 0.85rem;
    }
    .tier-badge-ultra {
        background-color: #7C3AED;
        color: #FFFFFF;
        padding: 4px 10px;
        border-radius: 12px;
        font-weight: 600;
        font-size: 0.85rem;
    }
</style>
"""


def run_async(coro):
    """Utility helper to run async tasks inside Streamlit execution context efficiently."""
    try:
        loop = asyncio.get_event_loop()
        if loop.is_closed():
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
    return loop.run_until_complete(coro)


# ─── Data Access Helpers via Service Layer ────────────────────────
from config import get_settings
from services.database import async_session_factory, init_db
from services.role_service import RoleService
from services.subscription_service import SubscriptionService
from services.user_service import UserService
from models.user_schemas import SearchDTO, UserCreateRequest
from models.role_schemas import RoleCreateRequest
from models.subscription_schemas import SubscriptionUpdateRequest


async def _ensure_db():
    settings = get_settings()
    await init_db(settings)


@st.cache_resource
def _init_db_once():
    """Fallback guard — DB is normally initialized at startup by ui.py.
    This only runs if admin_ui.py is launched standalone (e.g. `streamlit run admin_ui.py`).
    """
    run_async(_ensure_db())


def render_admin_panel():
    """Main render function for the Streamlit Admin Panel."""
    st.markdown(ADMIN_CSS, unsafe_allow_html=True)
    # DB is already initialized at app startup by ui.py (_init_db_once).
    # _init_db_once() here acts as a fallback only for standalone admin_ui.py runs.
    _init_db_once()


    # Header & Back button
    col_h1, col_h2 = st.columns([4, 1])
    with col_h1:
        st.markdown('<div class="admin-header">🛡️ EduTechAI Admin Console</div>', unsafe_allow_html=True)
        st.markdown('<div class="admin-sub">Manage Users, Roles, Privileges, and Subscription Tiers in Real-Time</div>', unsafe_allow_html=True)
    with col_h2:
        st.write("")
        if st.button("🎓 Learning Workspace", use_container_width=True, help="Return to student learning workspace"):
            st.session_state["view"] = "learning"
            st.rerun()

    tabs = st.tabs([
        "👥 User Directory & Roles",
        "🛡️ Role & Privilege Matrix",
        "💳 Subscription Tier Manager",
        "📊 Analytics & Metrics",
    ])

    # ─── TAB 1: USER DIRECTORY & ROLE ASSIGNMENT ─────────────────────
    with tabs[0]:
        st.subheader("User Directory & Role Assignment")

        col_search, col_add = st.columns([3, 1])
        with col_search:
            search_term = st.text_input("🔍 Search Users by Name, Email, or Mobile", placeholder="e.g. John or john@example.com", key="admin_user_search")
        with col_add:
            st.write("")
            st.write("")
            show_create_modal = st.button("➕ Create New User", use_container_width=True, key="admin_create_u_btn")

        if show_create_modal:
            with st.form("create_user_form"):
                st.markdown("### Create New User Profile")
                fn = st.text_input("First Name*")
                ln = st.text_input("Last Name*")
                em = st.text_input("Email Address*")
                pw = st.text_input("Password*", type="password")
                mob = st.text_input("Mobile Number")
                ctry = st.text_input("Country")
                submit_user = st.form_submit_button("Create User")

                if submit_user:
                    if not fn or not ln or not em or not pw:
                        st.error("Please fill in all required fields (*).")
                    else:

                        async def do_create():
                            async with async_session_factory() as session:
                                req = UserCreateRequest(
                                    first_name=fn,
                                    last_name=ln,
                                    email=em,
                                    password=pw,
                                    mobile=mob or None,
                                    country=ctry or None,
                                )
                                return await UserService.create_user(session, req)

                        try:
                            new_u = run_async(do_create())
                            st.success(f"User created successfully: {new_u.email} (Assigned default Normal role)")
                            st.rerun()
                        except Exception as exc:
                            st.error(f"Error creating user: {exc}")

        # Fetch users list
        async def fetch_users(lookup: str):
            async with async_session_factory() as session:
                dto = SearchDTO(page=0, size=50, lookupText=lookup or None)
                return await UserService.search_users(session, dto)

        users_list, total_count = run_async(fetch_users(search_term))
        st.caption(f"Showing {len(users_list)} of {total_count} users")

        if users_list:
            user_rows = []
            for u in users_list:
                roles_str = ", ".join([r.name for r in u.roles if not r.retired]) if u.roles else "None"
                sub_tier = u.subscription.tier.upper() if u.subscription else "NORMAL"
                user_rows.append({
                    "ID": u.id,
                    "Name": f"{u.first_name} {u.last_name}",
                    "Email": u.email,
                    "Country": u.country or "N/A",
                    "Sub Tier": sub_tier,
                    "Assigned Roles": roles_str,
                    "Status": "Active" if not u.retired else "Retired",
                    "Created At": u.created_at.strftime("%Y-%m-%d %H:%M"),
                })

            st.dataframe(user_rows, use_container_width=True)

            st.markdown("---")
            st.subheader("Manage User Roles")

            selected_user_id = st.selectbox(
                "Select User to Update Roles:",
                options=[u.id for u in users_list],
                format_func=lambda uid: f"{next(u for u in users_list if u.id == uid).first_name} {next(u for u in users_list if u.id == uid).last_name} ({next(u for u in users_list if u.id == uid).email})",
                key="admin_user_role_select",
            )

            if selected_user_id:
                target_user = next(u for u in users_list if u.id == selected_user_id)

                async def fetch_all_roles():
                    async with async_session_factory() as session:
                        roles, _ = await RoleService.search_roles(session, SearchDTO(page=0, size=100))
                        return roles

                all_roles = run_async(fetch_all_roles())
                current_role_ids = [r.id for r in target_user.roles if not r.retired]

                with st.form("assign_roles_form"):
                    st.markdown(f"**Updating roles for {target_user.first_name} {target_user.last_name}:**")
                    selected_rids = st.multiselect(
                        "Assigned Roles:",
                        options=[r.id for r in all_roles],
                        default=current_role_ids,
                        format_func=lambda rid: next(r.name for r in all_roles if r.id == rid),
                    )
                    save_roles_btn = st.form_submit_button("Save Role Assignments")

                    if save_roles_btn:

                        async def do_assign():
                            async with async_session_factory() as session:
                                return await UserService.assign_roles_to_user(session, selected_user_id, selected_rids)

                        try:
                            run_async(do_assign())
                            st.success("Roles updated successfully!")
                            st.rerun()
                        except Exception as exc:
                            st.error(f"Error updating roles: {exc}")

    # ─── TAB 2: ROLE & PRIVILEGE MATRIX ──────────────────────────────
    with tabs[1]:
        st.subheader("Role & Privilege Management")

        async def fetch_roles_and_privs():
            async with async_session_factory() as session:
                roles, _ = await RoleService.search_roles(session, SearchDTO(page=0, size=100))
                privs = await RoleService.get_all_privileges(session)
                return roles, privs

        roles, privs = run_async(fetch_roles_and_privs())

        col_r1, col_r2 = st.columns([2, 1])

        with col_r1:
            st.markdown("#### System Roles Overview")
            role_matrix = []
            for r in roles:
                priv_names = ", ".join([p.name for p in r.privileges]) if r.privileges else "No Privileges"
                role_matrix.append({
                    "Role ID": r.id,
                    "Role Name": r.name,
                    "Privilege Count": len(r.privileges),
                    "Assigned Privileges": priv_names,
                    "Created At": r.created_at.strftime("%Y-%m-%d"),
                })
            st.dataframe(role_matrix, use_container_width=True)

        with col_r2:
            st.markdown("#### Create New Role")
            with st.form("create_role_form"):
                rname = st.text_input("Role Name*")
                sel_priv_ids = st.multiselect(
                    "Assign Privileges:",
                    options=[p.id for p in privs],
                    format_func=lambda pid: f"{next(p.code for p in privs if p.id == pid)} ({next(p.name for p in privs if p.id == pid)})",
                )
                submit_role = st.form_submit_button("Create Role")

                if submit_role:
                    if not rname:
                        st.error("Role name is required.")
                    else:

                        async def do_create_role():
                            async with async_session_factory() as session:
                                req = RoleCreateRequest(name=rname, privilege_ids=sel_priv_ids)
                                return await RoleService.create_role(session, req)

                        try:
                            new_r = run_async(do_create_role())
                            st.success(f"Role '{new_r.name}' created successfully!")
                            st.rerun()
                        except Exception as exc:
                            st.error(f"Error creating role: {exc}")

        st.markdown("---")
        st.markdown("#### All Available Privilege Codes")
        priv_rows = [{"ID": p.id, "Code": p.code, "Name": p.name, "Order": p.order_number or 0} for p in privs]
        st.dataframe(priv_rows, use_container_width=True)

    # ─── TAB 3: SUBSCRIPTION TIER MANAGER ────────────────────────────
    with tabs[2]:
        st.subheader("Subscription Tier Management")

        async def fetch_all_subscriptions():
            async with async_session_factory() as session:
                users, _ = await UserService.search_users(session, SearchDTO(page=0, size=100))
                return users

        sub_users = run_async(fetch_all_subscriptions())

        sub_table = []
        for u in sub_users:
            tier = u.subscription.tier if u.subscription else "normal"
            status = u.subscription.status if u.subscription else "active"
            sub_table.append({
                "User ID": u.id,
                "User Name": f"{u.first_name} {u.last_name}",
                "Email": u.email,
                "Current Tier": tier.upper(),
                "Status": status.upper(),
                "Assigned Database Roles": ", ".join([r.name for r in u.roles if not r.retired]),
            })

        st.dataframe(sub_table, use_container_width=True)

        st.markdown("---")
        st.markdown("### Upgrade / Change User Subscription Tier")

        selected_sub_user_id = st.selectbox(
            "Select User to Update Subscription Tier:",
            options=[u.id for u in sub_users],
            format_func=lambda uid: f"{next(u for u in sub_users if u.id == uid).first_name} {next(u for u in sub_users if u.id == uid).last_name} ({next(u for u in sub_users if u.id == uid).email})",
            key="sub_user_select",
        )

        if selected_sub_user_id:
            target_sub_user = next(u for u in sub_users if u.id == selected_sub_user_id)
            current_t = target_sub_user.subscription.tier if target_sub_user.subscription else "normal"

            col_t1, col_t2 = st.columns(2)
            with col_t1:
                new_tier = st.selectbox(
                    "Target Subscription Tier:",
                    options=["normal", "pro", "ultra"],
                    index=["normal", "pro", "ultra"].index(current_t) if current_t in ["normal", "pro", "ultra"] else 0,
                    format_func=lambda t: f"{t.upper()} Tier",
                )
            with col_t2:
                new_status = st.selectbox(
                    "Subscription Status:",
                    options=["active", "canceled", "expired", "past_due"],
                    index=0,
                )

            if st.button("Apply Tier Change & Sync Role", type="primary"):

                async def do_update_sub():
                    async with async_session_factory() as session:
                        req = SubscriptionUpdateRequest(tier=new_tier, status=new_status)
                        return await SubscriptionService.update_user_subscription_tier(session, selected_sub_user_id, req)

                try:
                    updated_sub = run_async(do_update_sub())
                    st.success(
                        f"Updated subscription for {target_sub_user.email} to '{updated_sub.tier.upper()}'. "
                        f"Database user roles automatically synchronized!"
                    )
                    st.rerun()
                except Exception as exc:
                    st.error(f"Error updating subscription: {exc}")

    # ─── TAB 4: ANALYTICS & METRICS ─────────────────────────────────
    with tabs[3]:
        st.subheader("Platform Metrics & Subscription Distribution")

        async def fetch_metrics():
            async with async_session_factory() as session:
                all_u, total_u = await UserService.search_users(session, SearchDTO(page=0, size=500))
                all_r, total_r = await RoleService.search_roles(session, SearchDTO(page=0, size=100))
                privs = await RoleService.get_all_privileges(session)
                return all_u, total_u, total_r, len(privs)

        all_u, total_u, total_r, total_p = run_async(fetch_metrics())

        normal_count = sum(1 for u in all_u if u.subscription and u.subscription.tier == "normal")
        pro_count = sum(1 for u in all_u if u.subscription and u.subscription.tier == "pro")
        ultra_count = sum(1 for u in all_u if u.subscription and u.subscription.tier == "ultra")

        m1, m2, m3, m4, m5 = st.columns(5)
        m1.metric("Total Users", total_u)
        m2.metric("Normal Tier (Free)", normal_count)
        m3.metric("Pro Subscribers", pro_count)
        m4.metric("Ultra Subscribers", ultra_count)
        m5.metric("System Roles", total_r)

        st.markdown("---")
        st.markdown("#### Subscription Tier Distribution")

        dist_data = {
            "Tier": ["Normal (Free)", "Pro", "Ultra"],
            "User Count": [normal_count, pro_count, ultra_count],
        }
        st.bar_chart(dist_data, x="Tier", y="User Count", color="Tier")


if __name__ == "__main__":
    st.set_page_config(
        page_title="EduTechAI — Admin Portal",
        page_icon="🛡️",
        layout="wide",
        initial_sidebar_state="expanded",
    )
    render_admin_panel()
