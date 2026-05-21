# Questão 06 — Módulo Terraform no padrão interno

Strickland, que fecha a ponta de **segurança e compliance**, publicou o padrão interno de IaC que todo módulo Terraform novo precisa seguir:

| Regra | Detalhe |
|-------|---------|
| Tags obrigatórias | `Owner`, `CostCenter`, `Environment` em todo recurso |
| Prefixo de nomes | `hvt-` nos nomes de recursos |
| Bucket S3 | encryption (SSE-S3 mínimo), versioning ativo, block public access total, logging configurado |
| Variáveis | `variables.tf` com `description` e `type` obrigatórios |

Doc Brown pediu um **módulo Terraform reutilizável** para criar buckets S3 aderentes a esse padrão. O módulo será consumido por todos os times, então precisa vir com **exemplo de uso**.

## Referência de estilo (módulo VPC existente)

```hcl
variable "environment" {
  description = "Nome do ambiente (dev, staging, production)"
  type        = string
}

locals {
  common_tags = {
    Owner       = var.owner
    CostCenter  = var.cost_center
    Environment = var.environment
  }
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = merge(local.common_tags, {
    Name = "hvt-vpc-${var.environment}"
  })
}
```

## Tarefa

Aplicando o framework **C-A-R-E**, escrever o prompt de IA que produza o módulo Terraform S3 aderente ao padrão, no mesmo estilo do exemplo.

## Entrega

| Item | Descrição |
|------|-----------|
| **Prompt** | Prompt completo aplicando C-A-R-E |
| **Modelo** | Modelo utilizado na execução |
| **Output** | Módulo Terraform + exemplo de uso |
| **Justificativa** | Como **Context**, **Action**, **Result** e **Example** aparecem no prompt |
