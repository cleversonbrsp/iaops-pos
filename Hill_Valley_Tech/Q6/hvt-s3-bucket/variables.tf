variable "owner" {
  description = "Responsável pelo recurso (e-mail ou time)"
  type        = string
}

variable "cost_center" {
  description = "Centro de custo para alocação financeira"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, staging, production)"
  type        = string
}

variable "bucket_name" {
  description = "Sufixo do bucket sem prefixo hvt- (ex.: chronos-assets)"
  type        = string
}

variable "access_log_bucket_id" {
  description = "ID do bucket S3 destino dos access logs (já existente na conta)"
  type        = string
}

variable "access_log_prefix" {
  description = "Prefixo dos objetos de access log dentro do bucket de logging"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Permite destruir o bucket mesmo com objetos (apenas não-prod)"
  type        = bool
  default     = false
}
