variable "aws_region" {
  description = "Região AWS para o provider"
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Responsável pelo recurso"
  type        = string
  default     = "platform@hvt.io"
}

variable "cost_center" {
  description = "Centro de custo"
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "production"
}

variable "access_log_bucket_id" {
  description = "Bucket central de access logs da conta"
  type        = string
}

variable "force_destroy" {
  description = "Permite terraform destroy com objetos no bucket"
  type        = bool
  default     = false
}
