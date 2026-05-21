locals {
  common_tags = {
    Owner       = var.owner
    CostCenter  = var.cost_center
    Environment = var.environment
  }

  bucket_id = "hvt-${var.bucket_name}-${var.environment}"
}

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_id
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Name = local.bucket_id
  })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.this.id

  target_bucket = var.access_log_bucket_id
  target_prefix = var.access_log_prefix != "" ? var.access_log_prefix : "access-logs/${local.bucket_id}/"
}
