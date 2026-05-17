import os
from functools import wraps

from flask import jsonify, request


def require_api_key(view):
    @wraps(view)
    def wrapper(*args, **kwargs):
        provided = request.headers.get("X-API-Key")
        expected = os.environ.get("API_KEY")
        if not provided or provided != expected:
            return jsonify({"error": "unauthorized"}), 401
        return view(*args, **kwargs)

    return wrapper
