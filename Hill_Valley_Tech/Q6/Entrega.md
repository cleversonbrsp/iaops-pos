# Questão 06 — Entrega

## Prompt

[`prompt.md`](./prompt.md) · Framework **C-A-R-E**.

## Modelo

**GPT-4o** (OpenAI)

HCL Terraform com provider AWS 5.x (recursos S3 separados) e padrão corporativo copiável — GPT-4o acerta sintaxe e estrutura de módulo com `[Example]` ancorado no VPC.

## Output

[`output.md`](./output.md) · Módulo: [`hvt-s3-bucket/`](./hvt-s3-bucket/) · Exemplo: [`examples/chronos-assets/`](./examples/chronos-assets/).

## Justificativa

**Context** fixa padrão Strickland e estilo VPC; **Action** lista arquivos e regras do bucket; **Result** define pronto para registry + `terraform validate`; **Example** cola o módulo VPC como molde de `locals` e tags. O prompt proíbe criar bucket de logs dentro do módulo.

**Retrabalho:** outputs com atributo `type` inválido na versão Terraform do CI/local — corrigido após `terraform validate` falhar (detalhe em `output.md`).
