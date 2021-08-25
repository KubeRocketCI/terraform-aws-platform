resource "aws_s3_bucket" "b" {
  bucket = "velero-${var.platform_name}"
  acl    = "private"

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "b" {
  bucket = aws_s3_bucket.b.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
