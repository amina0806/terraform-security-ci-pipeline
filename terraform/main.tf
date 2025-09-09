resource "aws_kms_key" "cloudtrail" {
  description             = "KMS CMK for CloudTrail logs"
  enable_key_rotation     = true
}

resource "random_id" "rand" {
  byte_length = 4
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = "${var.trail_name}-logs-${random_id.rand.hex}"
  force_destroy = true
}


data "aws_iam_policy_document" "cloudtrail" {
  statement {
    sid     = "AWSCloudTrailWrite"
    effect  = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail.json
}

resource "aws_cloudtrail" "this" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_organization_trail         = false

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}
