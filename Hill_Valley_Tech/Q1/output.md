# Output — GPT-4o (resposta integral)

## 1. Dockerfile

```dockerfile
# syntax=docker/dockerfile:1

FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    APP_HOME=/app \
    PORT=8080

WORKDIR ${APP_HOME}

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 1000 app \
    && useradd --uid 1000 --gid app --create-home --shell /usr/sbin/nologin app

COPY lift/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=app:app lift/app.py .
COPY --chown=app:app lift/lib/ lib/

USER app

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]
```

## 2. .dockerignore

```
.git
.gitignore
__pycache__
*.py[cod]
*$py.class
*.so
.Python
.venv
venv
env
.env
.env.*
.pytest_cache
.coverage
htmlcov
.mypy_cache
.ruff_cache
*.md
Dockerfile*
.dockerignore
*.egg-info
dist
build
lift/tests/
```

## 3. Justificativa técnica

1. `python:3.12-slim-bookworm` reduz superfície e mantém compatibilidade com wheels do psycopg2-binary.
2. `libpq5` atende runtime do psycopg2 sem compilar no build.
3. `requirements.txt` antes do código maximiza cache de camadas no CI.
4. Usuário `app` (uid 1000) evita processo root no pod.
5. Secrets (`DATABASE_URL`, `API_KEY`) ficam fora da imagem.
6. `HEALTHCHECK` em `/health` integra com probes do Kubernetes.
7. `.dockerignore` exclui `lift/tests/` e `.env`.
8. `CMD` em forma exec propaga SIGTERM ao Gunicorn.

---

*Artefatos versionados em `Q1/Dockerfile` e `Q1/.dockerignore`.*
