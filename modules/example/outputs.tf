output "primary_bucket_name" {
  value       = aws_s3_bucket.primary.bucket
  description = "Name of the primary S3 bucket."
}

output "replica_bucket_name" {
  value       = aws_s3_bucket.replica.bucket
  description = "Name of the replica S3 bucket."
}
