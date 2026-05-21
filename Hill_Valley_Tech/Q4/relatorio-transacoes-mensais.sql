-- Relatório mensal de transações do Ledger
-- Destino: Jennifer Parker (apresentação de crescimento para Goldie)
-- Recorte: últimos 6 meses corridos a partir de 2026-04-24
-- Filtro: status = 'completed'
-- Agrupamento: mês (YYYY-MM) + categoria
-- Métricas: quantidade de transações, volume total em reais (2 casas)

SELECT
  TO_CHAR(DATE_TRUNC('month', t.created_at), 'YYYY-MM') AS mes,
  t.category                                           AS categoria,
  COUNT(*)                                             AS quantidade_transacoes,
  ROUND(SUM(t.amount_cents)::numeric / 100, 2)         AS volume_total_reais
FROM transactions t
WHERE t.status = 'completed'
  AND t.created_at >= TIMESTAMP '2026-04-24' - INTERVAL '6 months'
  AND t.created_at <  TIMESTAMP '2026-04-24' + INTERVAL '1 day'
GROUP BY
  DATE_TRUNC('month', t.created_at),
  t.category
ORDER BY
  mes ASC,
  categoria ASC;
