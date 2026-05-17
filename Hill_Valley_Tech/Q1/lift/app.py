import os

from flask import Flask, jsonify

from lib.auth import require_api_key
from lib.storage import get_db_status


def _require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(f"{name} environment variable is required")
    return value


def create_app() -> Flask:
    database_url = _require_env("DATABASE_URL")
    _require_env("API_KEY")

    application = Flask(__name__)

    @application.get("/health")
    def health():
        return jsonify({"status": "ok"})

    @application.get("/api/status")
    @require_api_key
    def status():
        return jsonify({"database": get_db_status(database_url)})

    return application


app = create_app()
