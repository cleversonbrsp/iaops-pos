# Questão 05 — Entrega

## Prompt

[`prompt.md`](./prompt.md) · Manifesto legado: [`chronos-api-legacy.yaml`](./chronos-api-legacy.yaml) · Framework **B-A-B**.

## Modelo

**Claude Sonnet 4** (Anthropic)

Manifestos Kubernetes longos com securityContext, probes e secretKeyRef exigem precisão estrutural — Claude costuma manter YAML válido e checklist Before/After.

## Output

[`output.md`](./output.md) · Artefatos: [`chronos-api-deployment.yaml`](./chronos-api-deployment.yaml), Secret/SA de exemplo.

## Justificativa

**Before** cola o YAML legado e gaps; **After** lista o padrão HVT (HA, tag fixa, secrets externos, probes, securityContext); **Bridge** exige tabela de gaps, YAML final, Secret example e nota de rollout. O prompt proíbe reintroduzir secrets inline.

**Retrabalho:** primeira versão com 2 réplicas apenas — ajustei leitura do [After] (≥3) antes de publicar artefatos finais.
