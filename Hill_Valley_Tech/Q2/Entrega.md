# Questão 02 — Entrega

## Prompt

[`prompt.md`](./prompt.md) · Framework **R-T-F**.

## Modelo

**Claude Sonnet 4** (Anthropic)

Bom em bash defensivo (`set -euo pipefail`, traps) e fluxos AWS CLI — adequado a script de backup com retenção e logging operacional.

## Output

[`output.md`](./output.md) · Artefato: [`ledger-backup.sh`](./ledger-backup.sh).

## Justificativa

**Role** posiciona SRE PostgreSQL/AWS; **Task** fixa host, bucket, PGPASSWORD externa e 8 requisitos; **Format** separa script, crontab e justificativa. O prompt impediu credencial hardcoded e exigiu limpeza S3 no script.

**Retrabalho:** primeira versão da retenção S3 era agressiva demais no delete em lote; refinei o passo 3 do Task mentalmente e regenerei com filtro por data no nome do objeto (documentado em `output.md`).
