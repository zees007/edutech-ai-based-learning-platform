"""
Unit tests for User schemas and mobile number / country normalization.
"""

import pytest
from pydantic import ValidationError

from models.user_schemas import UserCreateRequest, UserEditRequest


def test_user_create_request_valid_mobile():
    req = UserCreateRequest(
        first_name="John",
        last_name="Doe",
        email="john.doe@example.com",
        password="SecurePassword123",
        mobile="+14155552671",
        country="United States",
    )
    assert req.mobile == "+14155552671"
    assert req.country == "United States"


def test_user_create_request_nri_mobile_normalization():
    # US number with spacing
    req = UserCreateRequest(
        first_name="Raj",
        last_name="Patel",
        email="raj.patel@example.com",
        password="SecurePassword123",
        mobile="+1 415 555 2671",
        country="United States",
    )
    assert req.mobile == "+14155552671"

    # Indian number normalization
    req2 = UserCreateRequest(
        first_name="Aarav",
        last_name="Sharma",
        email="aarav@example.com",
        password="SecurePassword123",
        mobile="+91 9876543210",
        country="India",
    )
    assert req2.mobile == "+919876543210"


def test_user_create_request_optional_mobile():
    req = UserCreateRequest(
        first_name="Jane",
        last_name="Smith",
        email="jane.smith@example.com",
        password="SecurePassword123",
        mobile=None,
        country=None,
    )
    assert req.mobile is None
    assert req.country is None


def test_user_edit_request_mobile_normalization():
    req = UserEditRequest(mobile="+1 650 253 0000", country="United States")
    assert req.mobile == "+16502530000"

