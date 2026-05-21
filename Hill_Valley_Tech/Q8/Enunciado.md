# Questão 08 — Postmortem técnico de incidente em produção

Um incidente está em andamento durante pico de tráfego. Doc Brown entrou na call e precisa de um **postmortem técnico em 20 minutos** para decidir entre:

1. **Rollback** do deploy **v2.48.0** (subiu ontem)
2. **Scaling emergencial** (aumento de limits do RDS e do pool de conexões)

## Artefatos disponíveis

### Deploy (ontem, 18:42 UTC)

```
Deploy chronos-api: v2.47.0 -> v2.48.0
Argo CD sync: 2026-04-23 18:42:11 UTC
Changelog:
- Adicionado endpoint POST /v2/transactions/batch
- Refatorado cliente do Ledger (pool de conexoes movido para nova biblioteca interna)
- Bump de psycopg 3.1.18 -> 3.2.0
- Reduzido timeout do Ledger de 5s para 2s
```

### Métricas Beacon (últimos 30 min)

| timestamp | p99_latency_ms | req_rate_s | err_rate_pct |
|-----------|---------------:|-----------:|-------------:|
| 2026-04-24 13:30 UTC | 420 | 1200 | 0.2 |
| 2026-04-24 13:45 UTC | 510 | 1450 | 0.3 |
| 2026-04-24 14:00 UTC | 780 | 1780 | 0.8 |
| 2026-04-24 14:10 UTC | 2400 | 2100 | 4.5 |
| 2026-04-24 14:15 UTC | 5200 | 2400 | 8.2 |
| 2026-04-24 14:20 UTC | 8100 | 2650 | 11.7 |

### Log (pod chronos-api-79c4d8b9-xk2jp)

```
2026-04-24 14:19:48 [ERROR] [ledger-client] connection pool exhausted (max=20, active=20, waiting=147)
2026-04-24 14:19:49 [WARN]  [ledger-client] query timeout after 2000ms: SELECT ... FROM transactions WHERE ...
2026-04-24 14:19:49 [ERROR] [handler] POST /v2/transactions/batch failed: context deadline exceeded
2026-04-24 14:19:50 [ERROR] [ledger-client] connection reset by peer
2026-04-24 14:19:51 [WARN]  [circuit-breaker] ledger-client OPEN (threshold 50%, current 87%)
2026-04-24 14:19:52 [ERROR] [reactor] failed to publish message: chronos-api upstream error
```

### Reactor (fila chronos-transactions)

- **50.127** mensagens acumuladas, crescendo ~800/min
- Consumer lag: **18 min** e aumentando

### Cluster

| Métrica | Valor |
|---------|-------|
| Chronos pods | 12/12 (HPA no máximo) |
| CPU média | 62% |
| Memória média | 71% |
| Conexões Ledger | 240/250 (limite RDS) |

## Tarefa

Escolher entre os cinco frameworks do capítulo (**R-T-F**, **T-A-G**, **B-A-B**, **C-A-R-E** ou **R-I-S-E**) o que melhor se aplica e escrever o prompt de IA que produza o postmortem técnico.

> Nesta questão a **justificativa é o coração da entrega**: explicar o framework escolhido, como os componentes aparecem no prompt, e **comparar explicitamente com pelo menos 2 outros candidatos** (ganhos e perdas).

## Entrega

| Item | Descrição |
|------|-----------|
| **Framework escolhido** | Qual e por quê |
| **Prompt** | Prompt completo |
| **Modelo** | Modelo utilizado |
| **Output** | Postmortem técnico |
| **Justificativa estendida** | Framework escolhido + comparação com ≥ 2 alternativas |
