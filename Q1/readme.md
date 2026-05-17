# Questão 01 — Dockerfile para o Lift

Entrega no framework **R-T-F** (Role, Task, Format).

---

# Prompt

Você é um engenheiro DevOps/SRE especialista em Docker, Kubernetes e Python/Flask.

**Objetivo:** gerar Dockerfile production-grade para o serviço Lift (Python/Flask + gunicorn), com `.dockerignore`, comandos de build/run e justificativa via framework R-T-F.

**Contexto:**

- Projeto em `lift/` com `app.py`, `requirements.txt`, `lib/`, `tests/`
- Runtime: `gunicorn --bind 0.0.0.0:8080 --workers 4 app:app`
- Variáveis obrigatórias: `DATABASE_URL`, `API_KEY`
- Base: `/home/cleverson/repos/iaops-pos`
- Compatível com Kubernetes, non-root, `EXPOSE 8080`, otimização de camadas

**Estrutura esperada:**

```
lift/
├── app.py
├── requirements.txt
├── lib/
│   ├── auth.py
│   └── storage.py
└── tests/
    └── test_app.py
```

**requirements.txt:**

```
Flask==3.0.0
gunicorn==21.2.0
requests==2.31.0
python-dotenv==1.0.0
psycopg2-binary==2.9.9
```

---

# Modelo

**Claude Sonnet (agente DevOps)** — equilíbrio entre precisão em Dockerfile, segurança (non-root, slim) e compatibilidade de wheels (`psycopg2-binary` em Debian slim vs. riscos em Alpine/musl).

---

# Output

## Dockerfile

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

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=app:app app.py .
COPY --chown=app:app lib/ lib/

USER app

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]
```

## .dockerignore

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
tests/
*.md
Dockerfile*
.dockerignore
*.egg-info
dist
build
```

## Build e run

```bash
cd /home/cleverson/repos/iaops-pos/lift

docker build -t lift:latest .

docker run --rm -p 8080:8080 \
  -e DATABASE_URL='postgresql://user:pass@host:5432/db' \
  -e API_KEY='sua-api-key' \
  lift:latest
```

## Árvore de arquivos

```
iaops-pos/
├── README.md
└── lift/
    ├── QUESTAO-01.md
    ├── Dockerfile
    ├── .dockerignore
    ├── app.py
    ├── requirements.txt
    ├── lib/
    │   ├── auth.py
    │   └── storage.py
    └── tests/
        └── test_app.py
```

---

# Justificativa

## Role

Engenheiro DevOps/SRE — prioriza imagem enxuta, execução segura e deploy em Kubernetes sem alterar o contrato do app (`gunicorn` na porta 8080).

## Task

- Cache de dependências: `requirements.txt` copiado antes do código da aplicação.
- Segurança: usuário não-root (UID/GID 1000), compatível com `securityContext` no Kubernetes.
- Runtime PostgreSQL: pacote `libpq5` para uso com `psycopg2-binary`.
- Imagem menor: `tests/`, artefatos Python e `.env` excluídos via `.dockerignore`.
- Sinais POSIX: `CMD` em forma exec para repasse correto ao processo principal.

## Format

Documentação e entrega acadêmica em Markdown (`QUESTAO-01.md`); artefatos operacionais (`Dockerfile`, `.dockerignore`) versionados em `lift/`.

## Decisões técnicas

| Decisão | Motivo |
|--------|--------|
| `python:3.12-slim-bookworm` | Imagem menor que `full`; wheels de `psycopg2-binary` estáveis (glibc) |
| Debian slim vs. Alpine | Evita incompatibilidades musl com dependências nativas |
| `USER app` após `COPY --chown` | Processo sem privilégios de root no pod |
| `DATABASE_URL` / `API_KEY` em runtime | Injetadas via `docker run`, `env` ou `Secret` no K8s — não baked na imagem |
| `*.md` no `.dockerignore` | Documentação fora da imagem de produção |
