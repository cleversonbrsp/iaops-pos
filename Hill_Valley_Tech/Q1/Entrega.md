# Questão 01 — Entrega

## Prompt (framework R-T-F)

```
[Role]
Você é um engenheiro de plataforma sênior, especialista em containerização e
deploy de aplicações Python em Kubernetes. Conhece boas práticas de Dockerfile
(imagem mínima, cache de camadas, usuário não-root, .dockerignore, HEALTHCHECK)
e o runtime de produção com Gunicorn.

[Task]
Crie um Dockerfile de produção para o serviço Lift, API Flask que será migrada
de VMs para Kubernetes. O build usa o diretório Q1/ como contexto; o código da
aplicação está em lift/.

Requisitos obrigatórios:
- Base: imagem Python slim (Debian bookworm), versão 3.12
- Dependências de sistema: libpq5 (cliente PostgreSQL para psycopg2-binary)
- Instalar dependências Python a partir de lift/requirements.txt antes de
  copiar o código da aplicação (otimizar cache de camadas)
- Copiar apenas lift/app.py e lift/lib/ para /app
- Usuário não-root (uid/gid 1000)
- Variáveis de ambiente DATABASE_URL e API_KEY NÃO devem estar na imagem;
  serão injetadas no runtime pelo cluster
- Expor porta 8080
- Comando de produção exato:
  gunicorn --bind 0.0.0.0:8080 --workers 4 app:app
- Incluir HEALTHCHECK no endpoint GET /health
- Gerar também um .dockerignore que exclua testes, arquivos .env, caches
  Python e artefatos de documentação da entrega

[Format]
Responda em três blocos markdown, nesta ordem:

1. **Dockerfile** — arquivo completo, pronto para `docker build -t lift .`
   executado a partir de Q1/
2. **.dockerignore** — conteúdo completo
3. **Justificativa técnica** — lista numerada (máx. 8 itens) explicando cada
   decisão relevante (base image, ordem COPY/RUN, usuário, HEALTHCHECK, etc.)
```

## Modelo

**Composer** (agente Cursor) — execução em 17/05/2026.

## Output

Artefatos gerados e organizados em `Q1/`:

| Arquivo | Função |
|---------|--------|
| `Dockerfile` | Imagem de produção do Lift |
| `.dockerignore` | Exclusões do contexto de build |
| `lift/` | Código-fonte da aplicação (conforme enunciado) |

Build:

```bash
cd Hill_Valley_Tech/Q1
docker build -t lift .
docker run --rm -p 8080:8080 \
  -e DATABASE_URL=postgresql://user:pass@host:5432/lift \
  -e API_KEY=changeme \
  lift
```

## Justificativa (R-T-F no prompt)

| Componente | Onde aparece no prompt | Efeito na resposta |
|------------|------------------------|--------------------|
| **Role** | Bloco `[Role]` — engenheiro de plataforma sênior, K8s, Dockerfile | Orienta tom técnico, escolha de slim image, usuário não-root e HEALTHCHECK |
| **Task** | Bloco `[Task]` — requisitos numerados (base, libpq, ordem de COPY, gunicorn, env vars externas) | Delimita escopo e evita omissões (porta 8080, workers 4, sem secrets na imagem) |
| **Format** | Bloco `[Format]` — três seções markdown fixas | Garante entrega estruturada: Dockerfile, .dockerignore e justificativa separados |

### Decisões técnicas do Dockerfile

1. **python:3.12-slim-bookworm** — imagem menor que `full`, com glibc compatível com wheels do psycopg2-binary.
2. **libpq5** — biblioteca de runtime exigida pelo psycopg2-binary sem compilar extensões no build.
3. **COPY requirements antes do código** — camada de dependências reutilizada quando só o código muda.
4. **Usuário `app` (uid 1000)** — processo não roda como root no pod Kubernetes.
5. **Sem DATABASE_URL/API_KEY na imagem** — secrets vêm de Secret/ConfigMap no deploy.
6. **HEALTHCHECK em /health** — kubelet e orquestrador detectam container unhealthy.
7. **`.dockerignore` com `lift/tests/`** — testes não entram na imagem de produção.
8. **CMD em forma exec** — sinal SIGTERM chega ao Gunicorn para shutdown gracioso no K8s.
