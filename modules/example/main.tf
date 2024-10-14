# Primary S3 bucket
resource "aws_s3_bucket" "primary" {
  provider = aws

  bucket_prefix = "${var.bucket_prefix}"
  acl           = "private"

  replication_configuration {
    role = aws_iam_role.replication.arn

    rules {
      id     = "replicateAll"
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.replica.arn
        storage_class = "STANDARD"
      }
    }
  }
}

# Secondary S3 bucket
resource "aws_s3_bucket" "replica" {
  provider = aws.replica

  bucket_prefix = "${var.bucket_prefix}-replica"
  acl           = "private"
}

# IAM role for replication
resource "aws_iam_role" "replication" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })
}

# Policy allowing the replication role to replicate objects
resource "aws_iam_policy" "replication" {
  name   = "s3-replication-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.primary.arn,
          "${aws_s3_bucket.primary.arn}/*",
        ]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:GetObjectVersionTagging"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.replica.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}