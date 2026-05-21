# Questão 05 — Entrega

## Prompt (framework B-A-B)

```
[Before]
Este é o Deployment Kubernetes legado do Chronos API em produção (George, ~2023).
Analise o estado atual e suas falhas em relação ao padrão atual da Hill Valley Tech.

Manifest legado:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chronos-api
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chronos-api
  template:
    metadata:
      labels:
        app: chronos-api
    spec:
      containers:
      - name: api
        image: chronos-api:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_PASSWORD
          value: "P@ssw0rd2023!"
        - name: JWT_SECRET
          value: "hvt-jwt-prod-secret"

Problemas conhecidos a endereçar: réplica única (sem HA), tag latest, secrets em
plain text no manifest, ausência de resources, probes, securityContext e labels
padronizados.

[After]
Estado desejado do Deployment modernizado (namespace production, nome chronos-api):

- replicas >= 3 com RollingUpdate (maxUnavailable: 0) para alta disponibilidade
- imagem com tag semver fixa (ex.: 3.4.2), registry ECR us-east-1, sem :latest
- DB_PASSWORD e JWT_SECRET via secretKeyRef (Secret chronos-api-secrets); zero
  valores sensíveis no Deployment
- resources.requests e resources.limits (CPU e memória) definidos
- livenessProbe e readinessProbe HTTP em /health na porta 8080
- securityContext em pod e container: runAsNonRoot, runAsUser 1000, drop ALL
  capabilities, allowPrivilegeEscalation false, readOnlyRootFilesystem true
  (com emptyDir para /tmp se necessário)
- labels app.kubernetes.io/* (name, component, part-of, version)
- podAntiAffinity preferencial por hostname
- serviceAccountName dedicado; automountServiceAccountToken false
- revisionHistoryLimit e seccompProfile RuntimeDefault

[Bridge]
Transforme o manifest Before no After seguindo estas etapas na resposta:

1. Liste em tabela (máx. 10 linhas) cada gap legado → mudança aplicada.
2. Entregue o Deployment YAML completo modernizado, pronto para kubectl apply.
3. Entregue um chronos-api-secret.example.yaml separado (placeholders, sem
   secrets reais) documentando que o Secret é provisionado fora do Git.
4. Nota de rollout: ordem apply Secret → Deployment; rotacionar credenciais que
   vazaram no manifest antigo; validar probes antes de cortar tráfego.

Restrições: manter namespace production e nome chronos-api; API escuta 8080;
não reintroduzir plaintext secrets no Deployment.
```

## Modelo

**Composer**

## Output

Artefatos gerados e organizados em `Q5/`:

| Arquivo | Função |
|---------|--------|
| `chronos-api-legacy.yaml` | Manifest Before (referência) |
| `chronos-api-deployment.yaml` | Deployment modernizado |
| `chronos-api-secret.example.yaml` | Exemplo de Secret (fora do Git) |
| `chronos-api-serviceaccount.yaml` | ServiceAccount dedicado |
| `Enunciado.md` | Enunciado da questão |

Aplicação:

```bash
# Secret provisionado pelo pipeline (não aplicar o example com placeholders em prod)
kubectl apply -f chronos-api-secret.example.yaml  # apenas referência

kubectl apply -f chronos-api-serviceaccount.yaml
kubectl apply -f chronos-api-deployment.yaml
kubectl rollout status deployment/chronos-api -n production
```

## Justificativa (B-A-B no prompt)

| Componente | Onde aparece no prompt | Efeito na resposta |
|------------|------------------------|--------------------|
| **Before** | Bloco `[Before]` — YAML legado completo + lista de problemas conhecidos | Ancora a IA no estado real: 1 réplica, latest, secrets inline |
| **After** | Bloco `[After]` — checklist do estado desejado (HA, tag fixa, Secret ref, probes, securityContext, labels) | Define critérios de aceite mensuráveis da modernização |
| **Bridge** | Bloco `[Bridge]` — tabela gap→mudança, YAML final, Secret example, nota de rollout | Estrutura a transformação e entrega artefatos aplicáveis + rotação de credenciais |

### Gap legado → mudança (Bridge)

| Gap (Before) | Mudança (After) |
|--------------|-----------------|
| `replicas: 1` | `replicas: 3` + `podAntiAffinity` |
| `image: chronos-api:latest` | ECR `chronos-api:3.4.2` + `imagePullPolicy: IfNotPresent` |
| Secrets em `env.value` | `secretKeyRef` → `chronos-api-secrets` |
| Sem resources | `requests` 250m/512Mi, `limits` 1 CPU/1Gi |
| Sem probes | `livenessProbe` + `readinessProbe` em `/health` |
| Sem securityContext | Pod + container não-root, `drop: [ALL]`, `readOnlyRootFilesystem` |
| Labels mínimos | `app.kubernetes.io/*` recomendados |
| Deploy big-bang implícito | `RollingUpdate` `maxUnavailable: 0` |

### Decisões técnicas

1. **3 réplicas** — HA mínima com anti-affinity em nós distintos.
2. **Secret separado** — compliance Strickland; credenciais do legado devem ser rotacionadas.
3. **`maxUnavailable: 0`** — rollout sem downtime durante modernização.
4. **`emptyDir` em `/tmp`** — compatível com `readOnlyRootFilesystem`.
5. **`automountServiceAccountToken: false`** — reduz superfície de ataque se SA não for necessário à API.
