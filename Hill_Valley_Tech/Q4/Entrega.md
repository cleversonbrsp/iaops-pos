# Questão 04 — Entrega

## Prompt

[`prompt.md`](./prompt.md) · Framework **T-A-G**.

## Modelo

**GPT-4o** (OpenAI)

Preciso de SQL PostgreSQL preciso (intervalos, `DATE_TRUNC`, `numeric`) e comentários de premissa — GPT-4o costuma acertar sintaxe e bordas de tipo.

## Output

[`output.md`](./output.md) · [`relatorio-transacoes-mensais.sql`](./relatorio-transacoes-mensais.sql).

## Justificativa

**Task** define relatório mensal com regras de status, recorte e métricas; **Action** lista 6 passos de implementação SQL; **Goal** fixa entrega executável para Jennifer em slides. O prompt separa `created_at` vs `completed_at` no [Action].

**Retrabalho:** primeira query usou `completed_at` — regenerei após explicitar `created_at` no passo 2 (ver `output.md`).
