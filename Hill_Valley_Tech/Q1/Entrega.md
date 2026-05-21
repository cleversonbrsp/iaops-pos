# Questão 01 — Entrega

## Prompt

Texto exato em [`prompt.md`](./prompt.md) · Framework **R-T-F**.

## Modelo

**GPT-4o** (OpenAI)

Forte em Dockerfile multi-camada, convenções de imagens Python oficiais e HEALTHCHECK alinhado a Kubernetes — domínio bem documentado no treinamento do modelo.

## Output

Resposta integral do modelo em [`output.md`](./output.md).

Artefatos aplicáveis: [`Dockerfile`](./Dockerfile), [`.dockerignore`](./.dockerignore), [`lift/`](./lift/).

## Justificativa

**Role** define engenheiro de plataforma/K8s; **Task** lista requisitos numerados (slim 3.12, libpq5, ordem COPY, gunicorn, sem secrets); **Format** exige três blocos fixos (Dockerfile, .dockerignore, justificativa). O modelo seguiu a estrutura e não embutiu `DATABASE_URL` na imagem.

**Retrabalho:** primeira resposta usou `curl` no HEALTHCHECK; imagem slim não traz `curl` — ajustei o prompt implícito na revisão para check via `python -c` + `urllib` (ver `output.md`).
