# Questão 07 — Entrega

## Prompt

[`prompt.md`](./prompt.md) · Framework **R-I-S-E**.

## Modelo

**Gemini 2.5 Pro** (Google)

Runbooks longos com tabelas OK/Atenção e critérios numéricos — Gemini mantém estrutura procedural e limiares (85%, 10 min) de forma consistente.

## Output

[`output.md`](./output.md) · Runbook: [`runbook-chronos-high-memory.md`](./runbook-chronos-high-memory.md).

## Justificativa

**Role** define audiência plantonista sem conhecimento do Chronos; **Input** embute alerta e ambiente (EKS, HPA, Argo, deps, Slack, SLA); **Steps** lista 8 blocos obrigatórios com comando + verificação; **Expectation** fixa < 30 min e limiares objetivos. O prompt exige template de escalação e encerramento.

**Retrabalho:** versão inicial escalava réplicas com `kubectl scale` — revisei [Steps] para respeitar HPA (ver `output.md`).
