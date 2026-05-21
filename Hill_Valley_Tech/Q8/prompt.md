[Before]
Estado e evidências ANTES da degradação crítica e do ponto de decisão:

- Deploy v2.48.0 em 2026-04-23 18:42 UTC (changelog: batch endpoint, refactor pool
  Ledger, psycopg 3.2.0, timeout 5s→2s)
- Métricas baseline 13:30 UTC: p99 420ms, err 0.2%, 1200 req/s
- Inflexão 14:10 UTC: p99 2400ms, err 4.5%
- Colapso 14:20 UTC: p99 8100ms, err 11.7%, 2650 req/s
- Logs: pool exhausted max=20 active=20 waiting=147; timeout 2000ms; batch handler
  failed; circuit breaker OPEN 87%; reactor publish failed
- Reactor: 50127 msgs, +800/min, lag 18min
- Cluster: 12/12 pods HPA max, CPU 62%, mem 71%, RDS 240/250 connections

Descreva o Before como: (a) baseline saudável sob carga, (b) mudanças introduzidas
pelo v2.48.0 que criam risco, (c) capacidade aparente do cluster (não-CPU-bound).

[After]
Estado ATUAL do incidente e estado ALVO pós-decisão:

- Atual: métricas de colapso, pool/RDS saturados, backlog Reactor, CB aberto
- Alvo: p99 <800ms, err <1%, pool sem waiting, RDS <200 conn, lag estável,
  circuit breaker closed — em 15-20 min após ação

Doc Brown precisa decidir em 20 minutos entre:
A) Rollback v2.48.0 → v2.47.0
B) Scaling emergencial RDS + pool de conexões

[Bridge]
Construa o postmortem técnico que conecte Before → After:

1. Linha do tempo correlacionando deploy, métricas e logs
2. Cadeia causal em texto (pico → batch → pool → timeout → CB → Reactor)
3. Análise das opções A e B (tempo, eficácia, risco) com matriz de decisão
4. Recomendação objetiva para Doc Brown (primária + complemento condicional)
5. Follow-up pós-incidente e lacunas de dados

Formato Markdown: Resumo executivo (30s), Linha do tempo, Before, After,
Bridge (causal + opções + matriz), Recomendação, Follow-up, Incertezas.
Tom: técnico, direto, sem linguagem de marketing. Máximo ~2 páginas equivalentes.
