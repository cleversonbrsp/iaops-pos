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
