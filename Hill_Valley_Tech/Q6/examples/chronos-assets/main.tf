terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "chronos_assets" {
  source = "../../hvt-s3-bucket"

  owner        = var.owner
  cost_center  = var.cost_center
  environment  = var.environment
  bucket_name  = "chronos-assets"

  access_log_bucket_id = var.access_log_bucket_id
  access_log_prefix    = "s3/chronos-assets/"
  force_destroy        = var.force_destroy
}

output "bucket_id" {
  description = "Bucket Chronos assets provisionado"
  value       = module.chronos_assets.bucket_id
}

output "bucket_arn" {
  description = "ARN do bucket Chronos assets"
  value       = module.chronos_assets.bucket_arn
}
