"""
EduTechAI — Tests for Role & Privilege Management APIs
"""

from uuid import uuid4

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select

from app.main import create_app
from models.db_models import Privilege
from services.database import get_db_session, init_db


@pytest.fixture
def app():
    return create_app()


@pytest.mark.asyncio
async def test_role_lifecycle(app):
    await init_db()

    # Seed 2 test privileges manually in DB
    async with get_db_session() as db:
        p1 = Privilege(name="User Read", code=f"user:read:{uuid4().hex[:4]}", order_number=1)
        p2 = Privilege(name="User Write", code=f"user:write:{uuid4().hex[:4]}", order_number=2)
        db.add_all([p1, p2])
        await db.commit()
        await db.refresh(p1)
        await db.refresh(p2)
        p1_id, p2_id = p1.id, p2.id

    role_name = f"TestRole_{uuid4().hex[:8]}"

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://testserver"
    ) as client:
        # 1. Create Role with privilegeIds
        create_payload = {
            "name": role_name,
            "privilegeIds": [p1_id, p2_id],
        }
        res = await client.post("/api/v1/roles/create", json=create_payload)
        assert res.status_code == 201, res.text
        data = res.json()
        assert data["name"] == role_name
        assert data["retired"] is False
        assert len(data["privileges"]) == 2
        privilege_codes = {p["code"] for p in data["privileges"]}
        assert p1.code in privilege_codes
        assert p2.code in privilege_codes
        role_id = data["id"]

        # 2. Get Role By ID
        res = await client.get(f"/api/v1/roles/{role_id}")
        assert res.status_code == 200
        role_data = res.json()
        assert role_data["id"] == role_id
        assert role_data["name"] == role_name
        assert len(role_data["privileges"]) == 2

        # 3. Edit Role (Update name and reduce privileges to [p1_id])
        updated_role_name = f"UpdatedRole_{uuid4().hex[:8]}"
        edit_payload = {
            "name": updated_role_name,
            "privilege_ids": [p1_id],
        }
        res = await client.put(f"/api/v1/roles/{role_id}/edit", json=edit_payload)
        assert res.status_code == 200
        edit_data = res.json()
        assert edit_data["name"] == updated_role_name
        assert len(edit_data["privileges"]) == 1
        assert edit_data["privileges"][0]["id"] == p1_id

        # 4. Search Active Roles (Filtered by lookupText, page=0)
        search_params = {
            "page": 0,
            "size": 10,
            "sortBy": "name",
            "isDesc": False,
            "lookupText": updated_role_name,
        }
        res = await client.get("/api/v1/roles/search", params=search_params)
        assert res.status_code == 200
        search_data = res.json()
        assert search_data["page"] == 0
        assert search_data["total"] >= 1
        assert any(item["id"] == role_id for item in search_data["items"])

        # 5. Soft Retire Role
        res = await client.delete(f"/api/v1/roles/{role_id}/retire")
        assert res.status_code == 200
        assert res.json()["message"] == "Role retired successfully"

        # 6. Verify retired role is excluded from active search
        res = await client.get("/api/v1/roles/search", params={"lookupText": updated_role_name})
        assert res.status_code == 200
        search_data_after_retire = res.json()
        assert not any(item["id"] == role_id for item in search_data_after_retire["items"])

        # 7. Verify duplicate name conflict exception
        # First create a role
        res1 = await client.post("/api/v1/roles/create", json={"name": "UniqueRoleName", "privilegeIds": []})
        assert res1.status_code == 201
        # Now attempt creating with exact same name
        res2 = await client.post("/api/v1/roles/create", json={"name": "UniqueRoleName", "privilegeIds": []})
        assert res2.status_code == 409
        err_data = res2.json()
        assert err_data["error_code"] == "ROLE_NAME_ALREADY_EXISTS"

        # 8. Verify invalid privilege ID error
        res3 = await client.post("/api/v1/roles/create", json={"name": f"Role_{uuid4().hex[:6]}", "privilegeIds": [999999]})
        assert res3.status_code == 400
        err_data = res3.json()
        assert err_data["error_code"] == "INVALID_PRIVILEGE_ID"

        # 9. Verify 404 on non-existent role ID
        res4 = await client.get(f"/api/v1/roles/{uuid4()}")
        assert res4.status_code == 404
        assert res4.json()["error_code"] == "ROLE_NOT_FOUND"
