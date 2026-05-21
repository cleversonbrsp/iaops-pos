[Task]
Escreva uma query SQL (PostgreSQL) que gere o relatório mensal consolidado de
transações do Ledger para Jennifer Parker apresentar crescimento por categoria
aos últimos 6 meses.

Schema:
- transactions(id, customer_id, category, amount_cents, status, payment_method,
  created_at, completed_at) — índices em created_at, status, category
- customers(id, segment, country, signup_at) — não é necessário no relatório
  final, apenas transactions

Regras obrigatórias:
- Incluir somente status = 'completed'
- Categorias em produção: subscription, one_time, refund, credit_adjustment
  (agrupar por category; não excluir outras se existirem, mas documentar no
  comentário que o relatório reflete o que está em transactions)
- Recorte: últimos 6 meses corridos a partir da data de referência 2026-04-24
  (inclusive o dia de referência)
- Agrupar por mês no formato YYYY-MM (derivado de created_at) e por category
- Métricas por linha: quantidade de transações (COUNT) e volume total em reais
  (SUM de amount_cents convertido para reais com 2 casas decimais)
- Ordenação: mês crescente, categoria crescente
- Query deve ser legível, com comentário de cabeçalho (propósito, recorte, filtro)

[Action]
1. Definir o filtro temporal com INTERVAL '6 months' ancorado em '2026-04-24'.
2. Aplicar WHERE status = 'completed' e usar created_at para o recorte (índice
   idx_transactions_created_at).
3. Agrupar com DATE_TRUNC('month', created_at) e formatar mês como YYYY-MM
   (TO_CHAR).
4. Calcular COUNT(*) e ROUND(SUM(amount_cents)::numeric / 100, 2) para reais.
5. ORDER BY mês ASC, categoria ASC (ordem lexicográfica YYYY-MM é válida).
6. Entregar apenas SQL — sem ORM, sem Python; opcionalmente nota de que refund e
   credit_adjustment podem ter amount_cents negativos e entram no volume líquido.

[Goal]
Produzir uma query pronta para executar no PostgreSQL do Ledger que Jennifer
possa rodar via psql, DBeaver ou ferramenta interna, obtendo diretamente a tabela
para slides de crescimento (mês × categoria × quantidade × volume em R$), sem
ambiguidade no recorte de 6 meses nem na conversão centavos → reais.

[Formato de saída]
Um único arquivo SQL com comentários de cabeçalho e a query SELECT completa.
Em seguida, 3–5 linhas explicando premissas (data de referência fixa, uso de
created_at vs completed_at, tratamento de valores negativos em refund).
