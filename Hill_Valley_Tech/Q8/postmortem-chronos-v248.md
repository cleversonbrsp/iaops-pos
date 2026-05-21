# Postmortem técnico (em andamento) — Chronos API v2.48.0

| Campo | Valor |
|-------|-------|
| **Incidente** | Degradação severa em pico de tráfego |
| **Início perceptível** | ~2026-04-24 14:10 UTC (p99 > 2 s, err > 4%) |
| **Deploy correlacionado** | v2.47.0 → v2.48.0 em 2026-04-23 18:42 UTC |
| **Decisão solicitada** | Rollback v2.48.0 **vs** scaling emergencial RDS/pool |
| **Autor** | Análise para Doc Brown |
| **Horizonte** | 20 minutos |

---

## 1. Resumo executivo (30 s)

O incidente **não é limitado por CPU/memória do cluster** (62% / 71%, HPA já no teto). A falha está na **camada de acesso ao Ledger**: pool de conexões da aplicação esgotado (`max=20`, **147 em espera**), timeouts de **2 s** (reduzidos no v2.48.0), circuit breaker aberto e saturação do RDS (**240/250** conexões).

**Recomendação imediata: rollback para v2.47.0** via Argo CD. Scaling emergencial de RDS/pool **sozinho não corrige** o pool `max=20` por pod × 12 pods nem o timeout agressivo introduzidos no deploy; no máximo ganha margem de 10 conexões no RDS enquanto a aplicação continua a degradar.

---

## 2. Linha do tempo

| Horário (UTC) | Evento | Sinal |
|---------------|--------|-------|
| 2026-04-23 18:42 | Deploy v2.48.0 (Argo CD sync) | Changelog altera Ledger client, batch endpoint, timeout 5s→2s |
| 2026-04-24 13:30–14:00 | Pico de tráfego crescente | p99 420→780 ms, err 0,2%→0,8% — ainda controlável |
| 2026-04-24 14:10 | Inflexão | p99 **2400 ms**, err **4,5%** |
| 2026-04-24 14:15–14:20 | Colapso | p99 **5200→8100 ms**, err **8,2%→11,7%** |
| 2026-04-24 14:19:48+ | Logs | Pool exhausted, batch handler timeout, CB OPEN, Reactor publish fail |
| Contínuo | Reactor backlog | 50.127 msgs, +800/min, lag **18 min** ↑ |

**Latência entre deploy e inflexão:** ~19,5 h — compatível com defeito de capacidade/configuração acoplado a **carga de pico**, não falha imediata pós-deploy.

---

## 3. Before — estado antes da degradação crítica

### 3.1 Baseline pré-pico (13:30 UTC)

- p99 **420 ms**, err **0,2%**, **1200 req/s** — serviço saudável sob carga alta moderada.
- Sistema já em v2.48.0 há ~19 h sem alerta crítico contínuo.

### 3.2 Configuração herdada do v2.48.0 (Before → ponto de ruptura)

| Mudança no changelog | Estado Before ruptura | Risco |
|----------------------|----------------------|-------|
| `POST /v2/transactions/batch` | Novo caminho de maior fan-out ao Ledger | Mais queries por request HTTP |
| Pool Ledger em nova biblioteca | **max=20** por pod (log) | Capacidade agregada ~240 conexões em 12 pods — colide com limite RDS **250** |
| Timeout Ledger **5s → 2s** | Falhas mais rápidas sob contenção | Aumenta churn de conexões e erros visíveis |
| psycopg 3.1.18 → 3.2.0 | Comportamento de pool pode diferir | Fator secundário; correlaciona com refactor |

### 3.3 Capacidade aparente do cluster (Before colapso)

- **12/12 pods** — escala horizontal **esgotada**.
- CPU **62%**, memória **71%** — **não** justifica scaling de pods; problema é **I/O wait / blocking** no Ledger client.

---

## 4. After — estado atual e resultado desejado

### 4.1 Estado atual (After — incidente ativo)

| Dimensão | Observação |
|----------|------------|
| Experiência do usuário | p99 **8,1 s**, **11,7%** erros |
| Chronos | Pool **100%** utilização + fila de espera; batch endpoint falhando |
| Ledger (RDS) | **96%** do limite de conexões (240/250) |
| Reactor | Backlog **50k+**, lag **18 min** — risco de perda de SLA downstream |
| Resiliência | Circuit breaker Ledger **OPEN** (87% > 50%) — falha em cascata parcial |

### 4.2 Resultado desejado (After — alvo pós-decisão)

| Métrica | Alvo em 15–20 min pós-ação |
|---------|---------------------------|
| p99 latency | < **800 ms** (tendência ↓) |
| err_rate | < **1%** |
| Pool waiting | **0** sustentado |
| RDS connections | < **200** sustentado |
| Reactor lag | Estável ou ↓ (não ↑) |
| Circuit breaker | **CLOSED** |

---

## 5. Bridge — cadeia causal e opções

### 5.1 Cadeia causal (evidência → conclusão)

```
Pico tráfego (2650 req/s)
  → maior uso de POST /v2/transactions/batch (novo em v2.48.0)
    → pool Ledger max=20/pod saturado (20 active, 147 waiting)
      → timeout 2s dispara + connection reset
        → circuit breaker OPEN
          → erros upstream no Reactor + backlog SQS
            → p99 8100ms, err 11.7%
```

**Conclusão:** o deploy v2.48.0 alterou **pressão e política de acesso ao Ledger**; o cluster Kubernetes **não** é o gargalo primário.

### 5.2 Opção A — Rollback v2.48.0 → v2.47.0

| Aspecto | Avaliação |
|---------|-----------|
| Ação | `argocd app rollback hvt/chronos-api <rev-2.47.0>` |
| O que reverte | Biblioteca antiga do pool, timeout 5s, ausência do batch path agressivo |
| Tempo estimado | **5–10 min** até métricas melhorarem |
| Risco | Perda temporária da feature batch v2; aceitável em incidente |
| Eficácia esperada | **Alta** — ataca causa raiz provável |

### 5.3 Opção B — Scaling emergencial (RDS + pool)

| Aspecto | Avaliação |
|---------|-----------|
| Ação | Aumentar `max_connections` RDS; patch ConfigMap pool 20→40 |
| Tempo estimado | RDS **15–30+ min** (pode exigir reboot); patch pool **5 min** + rollout |
| Eficácia | **Parcial** — 10 conexões livres no RDS não resolvem 147 waiting × contenção |
| Risco | Mais conexões sem rollback mantém timeout 2s e batch path; pode **mascarar** bug |
| Quando usar | **Complemento** após rollback se RDS ainda > 85% |

### 5.4 Matriz de decisão

| Critério | Rollback (A) | Scaling (B) |
|----------|:------------:|:-------------:|
| Tempo até alívio | ✅ ~10 min | ⚠️ 15–30+ min |
| Ataca causa (v2.48.0) | ✅ | ❌ |
| Risco operacional | Baixo | Médio |
| Eficácia com HPA no máximo | ✅ | ⚠️ |
| Adequado em 20 min para Doc | ✅ **Recomendado** | ❌ primário |

---

## 6. Recomendação para Doc Brown

### Decisão imediata (próximos 5 min)

1. **Executar rollback** para v2.47.0 (Argo CD).
2. Postar no war room: horário de rollback, revisão alvo, owner.
3. **Não** aumentar réplicas Chronos — HPA já em 12/12; não resolve pool.

### Se após rollback (15 min) RDS ainda > 220 conexões

4. Scaling **complementar** controlado no RDS (+margem) **e** revisão de pool por pod com `@chronos-core`.

### Monitorar até encerrar incidente

- p99, err_rate, `connection pool exhausted`, Reactor lag, CB state.

---

## 7. Ações de follow-up (pós-incidente)

| # | Ação | Owner sugerido |
|---|------|----------------|
| 1 | Postmortem blameless completo com métricas 24 h | Lorraine |
| 2 | Load test do endpoint batch vs pool sizing | George / Chronos core |
| 3 | Política: changelog com alteração de pool/timeout exige teste de carga | Strickland |
| 4 | Alerta Beacon: pool waiting > 10 e RDS connections > 85% | Beacon team |
| 5 | Reintroduzir v2.48.0 apenas com pool dimensionado e timeout validado | Doc Brown |

---

## 8. O que ainda não sabemos

- Distribuição exata de tráfego para `/v2/transactions/batch` vs rotas legadas (% RPS).
- Se psycopg 3.2.0 alterou defaults de pool além do `max=20` configurado.
- Queries Ledger mais lentas por mudança de plano após bump.

**Não bloqueiam rollback** — evidência atual é suficiente para decisão em 20 min.

---

*Documento gerado para decisão em incidente ativo — revisar números após rollback.*
