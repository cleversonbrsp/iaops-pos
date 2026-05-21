# Questão 07 — Runbook para alerta recorrente

Toda semana, em média **4 vezes**, o Beacon dispara o mesmo alerta no canal de plantão:

> **[CRITICAL] High memory usage on Chronos API pods (>85% for 10min)**

Quem assume o plantão gasta de **30 a 40 minutos** até resolver, e o tempo varia muito porque **não existe procedimento documentado**. Lorraine quer um runbook que qualquer plantonista consiga seguir de ponta a ponta sem depender de quem conhece o sistema.

## Ambiente

| Item | Detalhe |
|------|---------|
| Workload | Chronos no **EKS**, namespace `production` |
| Réplicas | 6 atuais, **HPA** min 4 / max 12, CPU target 70% |
| Deploy | **Argo CD** — repositório `hvt/chronos-api` |
| Dependências | **Ledger** (PostgreSQL), **Reactor** (filas SQS) |
| Observabilidade | `/metrics`, logs no **Beacon**, dashboards **Grafana** |
| Ferramentas | `kubectl`, `aws cli`, `argocd cli` |
| Canal | `#oncall-chronos` (Slack) |
| Escalação | `@chronos-core` — SLA 15 min (comercial), 30 min (fora) |

## Conteúdo obrigatório do runbook

- Passos iniciais de **diagnóstico** (comandos específicos)
- **Verificação esperada** ao final de cada passo
- Critérios objetivos para **escalar** ao time sênior
- Critério para **encerrar** o incidente

## Tarefa

Aplicando o framework **R-I-S-E**, escrever o prompt de IA que produza esse runbook procedural completo.

## Entrega

| Item | Descrição |
|------|-----------|
| **Prompt** | Prompt completo aplicando R-I-S-E |
| **Modelo** | Modelo utilizado na execução |
| **Output** | Runbook completo |
| **Justificativa** | Como **Role**, **Input**, **Steps** e **Expectation** aparecem no prompt |
