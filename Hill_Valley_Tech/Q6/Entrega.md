# Questão 06 — Entrega

## Prompt (framework C-A-R-E)

```
[Context]
A Hill Valley Tech exige que todo módulo Terraform novo siga o padrão de IaC de
Strickland (segurança/compliance):

- Tags obrigatórias em todo recurso taggável: Owner, CostCenter, Environment
- Prefixo hvt- nos nomes de recursos
- Buckets S3: encryption SSE-S3 (AES256) no mínimo, versioning Enabled, block
  public access em todos os quatro flags, server access logging para bucket
  central informado via variável
- variables.tf: toda variável com description e type explícitos

Doc Brown solicitou um módulo reutilizável de bucket S3 para consumo por todos os
times. O estilo de código deve espelhar o módulo VPC interno já existente
(locals.common_tags, merge de tags, Name = "hvt-...").

[Action]
1. Criar módulo Terraform em diretório hvt-s3-bucket/ com:
   - versions.tf (Terraform >= 1.5, AWS provider >= 5)
   - variables.tf (owner, cost_center, environment, bucket_name, access_log_bucket_id,
     access_log_prefix opcional, force_destroy opcional)
   - main.tf (aws_s3_bucket + versioning + encryption + public_access_block + logging)
   - outputs.tf (bucket_id, bucket_arn, bucket_region)
2. Nome do bucket: hvt-${bucket_name}-${environment}
3. Aplicar local.common_tags em aws_s3_bucket com Name tag
4. Criar examples/chronos-assets/ demonstrando module call com source relativo
5. Não hardcodar credenciais; não criar bucket de logs dentro do módulo (apenas
   referenciar bucket de logs existente)
6. Manter recursos com resource name "this" onde couber, alinhado ao VPC

[Result]
Entregável pronto para publicar no registry interno:
- Módulo aderente ao padrão Strickland, validável com terraform validate
- Exemplo copiável por outros times (Chronos assets em production)
- Documentação inline via descriptions; zero tags ou nomes fora do padrão

[Example]
Siga o padrão do módulo VPC da empresa:

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

Replique a mesma estrutura (locals, merge tags, prefixo hvt-) para aws_s3_bucket
e recursos associados do provider AWS 5.x.
```

## Modelo

**Composer**

## Output

Artefatos gerados e organizados em `Q6/`:

| Caminho | Função |
|---------|--------|
| `hvt-s3-bucket/` | Módulo reutilizável S3 |
| `hvt-s3-bucket/main.tf` | Bucket + versioning + encryption + PAB + logging |
| `hvt-s3-bucket/variables.tf` | Entradas com description e type |
| `hvt-s3-bucket/outputs.tf` | bucket_id, bucket_arn, bucket_region |
| `examples/chronos-assets/` | Exemplo de consumo do módulo |

Validação local:

```bash
cd Hill_Valley_Tech/Q6/hvt-s3-bucket && terraform init -backend=false && terraform validate
cd Hill_Valley_Tech/Q6/examples/chronos-assets && terraform init -backend=false && terraform validate
```

**Uso (exemplo Chronos):**

```hcl
module "chronos_assets" {
  source = "../../hvt-s3-bucket"

  owner        = "platform@hvt.io"
  cost_center  = "platform"
  environment  = "production"
  bucket_name  = "chronos-assets"

  access_log_bucket_id = "hvt-access-logs-production"
}
```

Bucket resultante: `hvt-chronos-assets-production`.

## Justificativa (C-A-R-E no prompt)

| Componente | Onde aparece no prompt | Efeito na resposta |
|------------|------------------------|--------------------|
| **Context** | Bloco `[Context]` — padrão Strickland, pedido Doc Brown, tags/prefixo/S3/logging, estilo VPC | Ancora compliance e audiência (todos os times) |
| **Action** | Bloco `[Action]` — 6 passos (estrutura de arquivos, naming, tags, example, sem bucket de logs embutido) | Define escopo técnico e limites do módulo |
| **Result** | Bloco `[Result]` — módulo publicável, validate, exemplo copiável | Critério de pronto: aderência + reuso |
| **Example** | Bloco `[Example]` — trecho literal do módulo VPC | Replica locals.common_tags, merge, prefixo hvt-, resource `this` |

### Checklist padrão Strickland

| Regra | Implementação |
|-------|----------------|
| Tags Owner, CostCenter, Environment | `local.common_tags` + `merge` em `aws_s3_bucket` |
| Prefixo `hvt-` | `local.bucket_id = "hvt-${var.bucket_name}-${var.environment}"` |
| SSE-S3 | `sse_algorithm = "AES256"` |
| Versioning | `status = "Enabled"` |
| Block public access | quatro flags `true` |
| Logging | `aws_s3_bucket_logging` → `var.access_log_bucket_id` |
| variables description + type | todas em `variables.tf` |

### Decisões técnicas

1. **Provider AWS 5.x** — recursos separados (versioning, encryption, PAB) em vez de blocos inline deprecated.
2. **Bucket de logs externo** — módulo não cria dependência circular; time de plataforma provisiona `hvt-access-logs-*` central.
3. **`force_destroy` opcional** — default `false`; dev pode habilitar sem mudar o módulo core.
4. **Example `chronos-assets`** — caso realista alinhado ao sistema Chronos do cenário HVT.
5. **Outputs documentados** — `bucket_id`, `bucket_arn` e `bucket_region` para wiring em pipelines.
