# Questão 05 — Modernizar deployment legado

Numa revisão de produção, Doc Brown puxou o manifest do **Chronos** e caiu neste deployment que o George escreveu três anos atrás. Desde então ninguém mexeu nele, e muita coisa que hoje é obrigatória no padrão da empresa ainda não está presente. Modernizar caiu na sua mesa.

## Manifest legado

Arquivo de referência: [`chronos-api-legacy.yaml`](chronos-api-legacy.yaml)

```yaml
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
```

## Requisitos da versão moderna

- Alta disponibilidade
- Imagem **versionada** (nada de `latest`)
- **Secrets fora do manifest** (referência a Secret do cluster)
- **Resource requests e limits**
- **Liveness e readiness probes**
- **securityContext** não-root
- Demais práticas de produção padrão da empresa

## Tarefa

Aplicando o framework **B-A-B**, escrever o prompt de IA que, recebendo esse manifest, produza a versão modernizada.

## Entrega

| Item | Descrição |
|------|-----------|
| **Prompt** | Prompt completo aplicando B-A-B |
| **Modelo** | Modelo utilizado na execução |
| **Output** | Deployment modernizado (e artefatos relacionados) |
| **Justificativa** | Como **Before**, **After** e **Bridge** aparecem no prompt |
