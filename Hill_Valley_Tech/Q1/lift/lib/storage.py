import psycopg2


def get_db_status(database_url: str) -> str:
    try:
        with psycopg2.connect(database_url) as conn:
            conn.cursor().execute("SELECT 1")
        return "connected"
    except Exception:
        return "unavailable"
