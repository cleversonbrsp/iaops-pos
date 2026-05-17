import os

import pytest

os.environ.setdefault("DATABASE_URL", "postgresql://user:pass@localhost:5432/lift")
os.environ.setdefault("API_KEY", "test-key")

from app import create_app  # noqa: E402


@pytest.fixture
def client():
    application = create_app()
    application.config["TESTING"] = True
    with application.test_client() as test_client:
        yield test_client


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_status_without_api_key(client):
    response = client.get("/api/status")
    assert response.status_code == 401


def test_status_with_api_key(client):
    response = client.get("/api/status", headers={"X-API-Key": "test-key"})
    assert response.status_code == 200
    assert "database" in response.get_json()
