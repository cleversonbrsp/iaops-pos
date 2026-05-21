# Questão 03 — Entrega

## Prompt

[`prompt.md`](./prompt.md) · Framework **T-A-G**.

## Modelo

**Gemini 2.5 Pro** (Google)

Forte em análise tabular (CSV), síntese executiva e planejamento por fases — adequado a relatório FinOps para CEO com meta percentual.

## Output

[`output.md`](./output.md) · Relatório integral: [`Relatorio-Reducao-Custos-Cloud.md`](./Relatorio-Reducao-Custos-Cloud.md) · Dados: [`custos-aws.csv`](./custos-aws.csv).

## Justificativa

**Task** define relatório para Goldie com priorização e % da conta; **Action** enumera 6 passos (total, desperdício, estimativas, ondas); **Goal** ancora meta 15% sem degradar SLA. O CSV está embutido no prompt para reprodutibilidade.

**Retrabalho:** primeira resposta não quantificou % da conta por oportunidade; ajustei ênfase nos passos 3 e 5 do [Action] (ver `output.md`).
