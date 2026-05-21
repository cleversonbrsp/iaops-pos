# Output — Claude Sonnet 4 (trecho da resposta)

## 1. Tabela gap → mudança

| Gap legado | Mudança |
|------------|---------|
| `replicas: 1` | `replicas: 3`, `maxUnavailable: 0` |
| `image: latest` | ECR `chronos-api:3.4.2` |
| secrets inline | `secretKeyRef` → `chronos-api-secrets` |
| sem resources | requests 250m/512Mi, limits 1CPU/1Gi |
| sem probes | liveness/readiness `/health` |
| sem securityContext | runAsUser 1000, drop ALL, readOnlyRootFilesystem + emptyDir /tmp |

## 2. Deployment modernizado

Arquivo integral: [`chronos-api-deployment.yaml`](./chronos-api-deployment.yaml).

## 3. Secret example

[`chronos-api-secret.example.yaml`](./chronos-api-secret.example.yaml) · [`chronos-api-serviceaccount.yaml`](./chronos-api-serviceaccount.yaml).

## 4. Rollout

1. Rotacionar credenciais vazadas no manifest legado.  
2. `kubectl apply` Secret (pipeline) → ServiceAccount → Deployment.  
3. `kubectl rollout status` + validar probes antes de encerrar incidente de deploy.

---

### Output imperfeito (registrado)

**Tentativa 1:** Deployment com `replicas: 2` e sem `podAntiAffinity` — não atendia HA pedida. **Correção:** [After] exige ≥3 réplicas; segunda geração inclui anti-affinity e `maxUnavailable: 0`.
