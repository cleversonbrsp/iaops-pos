# Questão 04 — Relatório mensal de transações do Ledger

Jennifer está fechando a apresentação que vai levar pra Goldie na semana que vem, sobre **crescimento de transações nos últimos 6 meses por categoria**. Ela precisa dos números consolidados mas não escreve SQL, então mandou a demanda pra sua fila.

O **Ledger** (PostgreSQL) tem o histórico completo. Schema de referência: [`schema.sql`](schema.sql).

## Tabelas relevantes

```sql
CREATE TABLE transactions (
  id              BIGSERIAL PRIMARY KEY,
  customer_id     BIGINT NOT NULL REFERENCES customers(id),
  category        VARCHAR(32) NOT NULL,
  amount_cents    BIGINT NOT NULL,
  status          VARCHAR(16) NOT NULL,
  payment_method  VARCHAR(16),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at    TIMESTAMPTZ
);

CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_category ON transactions(category);

CREATE TABLE customers (
  id          BIGSERIAL PRIMARY KEY,
  segment     VARCHAR(16) NOT NULL,
  country     CHAR(2) NOT NULL,
  signup_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Regras do relatório

| Regra | Valor |
|-------|-------|
| Categorias em produção | `subscription`, `one_time`, `refund`, `credit_adjustment` |
| Status incluído | apenas `completed` |
| Valor | `amount_cents` em centavos de real → saída em **reais com 2 casas decimais** |
| Recorte temporal | últimos **6 meses corridos** a partir de **2026-04-24** |
| Agrupamento | mês (`YYYY-MM`) + categoria |
| Métricas por linha | quantidade de transações + volume total em reais |
| Ordenação | mês crescente, depois categoria crescente |

## Tarefa

Aplicando o framework **T-A-G**, escrever o prompt de IA que produza essa **query SQL**.

## Entrega

| Item | Descrição |
|------|-----------|
| **Prompt** | Prompt completo aplicando T-A-G |
| **Modelo** | Modelo utilizado na execução |
| **Output** | Query SQL (e artefatos relacionados) |
| **Justificativa** | Como **Task**, **Action** e **Goal** aparecem no prompt |
