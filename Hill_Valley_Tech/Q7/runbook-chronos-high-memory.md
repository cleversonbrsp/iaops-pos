# Runbook — [CRITICAL] High memory usage on Chronos API pods

| Campo | Valor |
|-------|-------|
| **Alerta** | `[CRITICAL] High memory usage on Chronos API pods (>85% for 10min)` |
| **Sistema** | Chronos API |
| **Canal** | `#oncall-chronos` (Slack) |
| **Escalação** | `@chronos-core` |
| **SLA escalação** | 15 min (horário comercial) · 30 min (fora do horário) |
| **Versão** | 1.0 |
| **Owner** | Lorraine Baines (SRE) |

---

## 1. Objetivo

Procedimento para plantonistas resolverem pico de memória nos pods do Chronos API sem conhecimento prévio do sistema. Tempo-alvo: **≤ 30 minutos** até mitigação ou escalação fundamentada.

---

## 2. Pré-requisitos

- [ ] Acesso ao cluster EKS de produção (`kubectl` configurado)
- [ ] `aws cli` autenticado (região `us-east-1`)
- [ ] `argocd` CLI logado no Argo CD da HVT
- [ ] Permissão de leitura em namespace `production` e sync/restart conforme política de plantão
- [ ] Link do dashboard Grafana **Chronos API — Production** (Beacon)

Poste no `#oncall-chronos` ao assumir: *"Assumindo INC Chronos high memory — `<seu-nome>`"*.

---

## 3. Diagnóstico e mitigação

### Passo 1 — Confirmar escopo do alerta

**Comandos:**

```bash
kubectl get pods -n production -l app.kubernetes.io/name=chronos-api \
  -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,RESTARTS:.status.containerStatuses[0].restartCount,MEMORY:.status.containerStatuses[0].usage.memory

kubectl top pods -n production -l app.kubernetes.io/name=chronos-api --containers
```

**Verificação esperada:**

| Resultado | Interpretação |
|-----------|---------------|
| ≥ 1 pod com memória **> 85% do limit** ou OOMKilled | Alerta confirmado — seguir Passo 2 |
| Todos os pods **< 85%** e estáveis | Possível alerta stale — checar Beacon (Passo 6) antes de encerrar |
| Muitos `RESTARTS` (> 3 em 1 h) | Instabilidade ativa — anotar pods afetados |

---

### Passo 2 — Estado do Deployment e HPA

**Comandos:**

```bash
kubectl get deployment chronos-api -n production
kubectl get hpa -n production | grep chronos
kubectl describe hpa chronos-api -n production
```

**Verificação esperada:**

| Campo | OK | Atenção |
|-------|-----|---------|
| `deployment` READY | READY = DESIRED | READY < DESIRED → seguir Passo 5 (escalação) |
| HPA `REPLICAS` | Entre **4 e 12** | No **max (12)** com memória alta → pressão de carga |
| HPA `TARGETS` CPU | Próximo de 70% ou abaixo | CPU baixa e memória alta → possível leak ou payload grande |
| Eventos HPA | Sem `FailedGetResourceMetric` | Erros de métrica → escalar (critério E3) |

---

### Passo 3 — Deploy recente (Argo CD)

**Comandos:**

```bash
argocd app get hvt/chronos-api --refresh
argocd app history hvt/chronos-api -n argocd | head -10
```

**Verificação esperada:**

| Resultado | Ação |
|-----------|------|
| Sync **Synced** + Health **Healthy** | Deploy estável — continuar diagnóstico |
| Sync **OutOfSync** ou deploy nas **últimas 2 h** | Correlacionar com início do alerta; considerar rollback (Passo 4) |
| Health **Degraded** / **Progressing** > 15 min | Escalar (critério E2) |

---

### Passo 4 — Dependências (Ledger e Reactor)

**Comandos:**

```bash
# Ledger — latência de conexões (ajuste host conforme runbook interno)
kubectl run pg-check --rm -it --restart=Never -n production \
  --image=postgres:16-alpine -- \
  psql "$LEDGER_DATABASE_URL" -c "SELECT 1;" 2>/dev/null || echo "LEDGER_CHECK_FAILED"

# Reactor — filas SQS (substitua ACCOUNT_ID e região se necessário)
aws sqs get-queue-attributes \
  --queue-url "https://sqs.us-east-1.amazonaws.com/ACCOUNT_ID/hvt-reactor-chronos-inbound" \
  --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible
```

**Verificação esperada:**

| Dependência | OK | Problema |
|-------------|-----|----------|
| Ledger | `SELECT 1` retorna em **< 2 s** | Timeout/erro → escalar (E4); memória pode subir por pool bloqueado |
| Reactor SQS | Mensagens visíveis **< 10.000** e crescendo devagar | Backlog **> 50.000** ou crescimento rápido → escalar (E4) |

---

### Passo 5 — Métricas e logs (Beacon / Grafana)

**Comandos:**

```bash
# Métrica local rápida (substitua POD)
kubectl exec -n production POD -c api -- wget -qO- http://localhost:8080/metrics | grep -E 'process_resident_memory_bytes|go_memstats_heap_inuse_bytes|http_requests_total'
```

No **Grafana** (dashboard Chronos API — Production), verificar janela **últimos 30 min**:

- `container_memory_usage_bytes` por pod
- taxa de `http_requests_total` (5xx e latência p99)
- conexões ativas com Ledger (se painel existir)

No **Beacon**, buscar logs: `service=chronos-api level=error` últimos 15 min.

**Verificação esperada:**

| Sinal | Interpretação |
|-------|---------------|
| Memória sobe com **RPS estável** | Possível memory leak → escalar (E1) após mitigação temporária |
| Pico de **5xx** + memória | Sobrecarga ou dependência degradada |
| Logs `OOMKilled` / `java.lang.OutOfMemoryError` / `ENOMEM` | Confirmar leak ou limit baixo — escalar (E1) |
| Sem anomalia em métricas/logs | Reavaliar alerta (Passo 6) |

---

### Passo 6 — Mitigação segura (ordem obrigatória)

Execute **uma ação por vez** e reavalie com Passo 1 após cada uma.

#### 6a. Rolling restart (primeira tentativa)

```bash
kubectl rollout restart deployment/chronos-api -n production
kubectl rollout status deployment/chronos-api -n production --timeout=300s
```

**Verificação:** após 5 min, **nenhum** pod > 85% memória por 10 min contínuos → ir para **Encerramento**.

#### 6b. Escalar réplicas via HPA (carga alta confirmada)

Somente se Passo 2 mostrou CPU/RPS elevados e HPA **não** está no máximo:

```bash
# Temporário: aumentar max do HPA (requer permissão; documentar no Slack)
kubectl patch hpa chronos-api -n production -p '{"spec":{"maxReplicas":14}}'
```

**Verificação:** memória **por pod** cai após scale-out; se não cair em 10 min → reverter patch e escalar (E1).

#### 6c. Rollback Argo CD (deploy correlacionado)

Somente se Passo 3 indicou deploy recente problemático:

```bash
argocd app rollback hvt/chronos-api PREVIOUS_REVISION_ID
argocd app wait hvt/chronos-api --health
```

**Verificação:** rollout **Healthy** + memória estável 10 min → **Encerramento** com nota de rollback.

> **Não** altere limits de memória no manifest sem `@chronos-core`.

---

## 4. Critérios de escalação (@chronos-core)

Escale **imediatamente** no `#oncall-chronos` mencionando `@chronos-core` se **qualquer** condição for verdadeira:

| ID | Critério objetivo |
|----|-------------------|
| **E1** | Após Passo 6a **e** 6b, memória continua **> 85%** por **≥ 10 min** em **≥ 2 pods** |
| **E2** | Deployment com READY < DESIRED por **> 15 min**, ou Argo CD **Degraded** > 15 min |
| **E3** | HPA inoperante (`FailedGetResourceMetric`) ou impossível ler métricas por **> 10 min** |
| **E4** | Ledger indisponível **ou** backlog SQS Reactor **> 50.000** mensagens com tendência de alta |
| **E5** | SLA interno: **15 min** (comercial) / **30 min** (fora) desde o ack sem mitigação clara |
| **E6** | OOMKilled em **≥ 2 pods** no mesmo incidente |

**Mensagem de escalação (copiar/colar):**

```
@chronos-core Escalação Chronos high memory
- Início alerta: <HH:MM UTC>
- Pods afetados: <lista>
- Passos executados: 6a/6b/6c <quais>
- HPA: <replicas>/<max>
- Ledger: <OK|FAIL> | Reactor backlog: <N>
- Argo CD: <Synced/OutOfSync> rev <id>
- Métrica atual max mem: <%> 
```

---

## 5. Encerramento do incidente

Encerre **somente** quando **todos** forem verdadeiros por **≥ 10 minutos**:

| # | Critério |
|---|----------|
| 1 | Nenhum pod Chronos com uso de memória **> 85%** do limit |
| 2 | Deployment `chronos-api`: READY = DESIRED, sem pods CrashLoopBackOff |
| 3 | Argo CD app `hvt/chronos-api`: **Synced** + **Healthy** |
| 4 | Taxa de erro HTTP 5xx **< 1%** (Grafana) ou baseline habitual |
| 5 | Ledger e Reactor dentro dos limites do Passo 4 |
| 6 | Alerta **resolved** no Beacon (ou justificativa documentada se stale) |

**Comandos finais:**

```bash
kubectl get pods -n production -l app.kubernetes.io/name=chronos-api
kubectl top pods -n production -l app.kubernetes.io/name=chronos-api
```

**Post de encerramento no `#oncall-chronos`:**

```
✅ RESOLVED — Chronos high memory
- Causa provável: <restart|scale|rollback|transient|unknown>
- Duração: <min>
- Ação: <resumo>
- Follow-up: <ticket/none>
```

Se HPA foi patchado no Passo 6b, **reverter** `maxReplicas` para **12** após estabilização.

---

## 6. Referência rápida

| Recurso | Valor |
|---------|-------|
| Namespace | `production` |
| Deployment | `chronos-api` |
| Label selector | `app.kubernetes.io/name=chronos-api` |
| HPA | min **4**, max **12**, CPU **70%** |
| Argo CD app | `hvt/chronos-api` |
| Métricas | `GET /metrics` :8080 |
| Escalação | `@chronos-core` |

---

*Runbook aprovado por Lorraine Baines — revisar após mudanças de HPA, limits ou dependências.*
