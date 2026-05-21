# Output — GPT-4o (resposta integral)

## Arquivo SQL

Ver [`relatorio-transacoes-mensais.sql`](./relatorio-transacoes-mensais.sql).

```sql
SELECT
  TO_CHAR(DATE_TRUNC('month', t.created_at), 'YYYY-MM') AS mes,
  t.category                                           AS categoria,
  COUNT(*)                                             AS quantidade_transacoes,
  ROUND(SUM(t.amount_cents)::numeric / 100, 2)         AS volume_total_reais
FROM transactions t
WHERE t.status = 'completed'
  AND t.created_at >= TIMESTAMP '2026-04-24' - INTERVAL '6 months'
  AND t.created_at <  TIMESTAMP '2026-04-24' + INTERVAL '1 day'
GROUP BY DATE_TRUNC('month', t.created_at), t.category
ORDER BY mes ASC, categoria ASC;
```

## Premissas (3–5 linhas do modelo)

- Data de referência fixa **2026-04-24** para reprodutibilidade do relatório.
- **`created_at`** usado no recorte e agrupamento (índice existente); `completed_at` pode ser NULL em alguns fluxos.
- **`ROUND(...::numeric / 100, 2)`** evita drift de ponto flutuante em centavos de real.
- `refund` e `credit_adjustment` podem ter `amount_cents` negativos — o volume é líquido por categoria.

---

### Output imperfeito (registrado)

**Tentativa 1:** filtro com `completed_at` e janela “últimos 6 meses calendário” — divergia do enunciado (6 meses corridos desde 2026-04-24). **Correção:** [Action] passo 1–2 reforçados; segunda geração usa `created_at` + `INTERVAL '6 months'`.
