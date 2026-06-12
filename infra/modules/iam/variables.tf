variable "project" {
  type        = string
  description = "Project name used as a prefix for all resource names."
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. dev, staging, prod)."
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 media bucket that both components interact with."
}

variable "sqs_queue_arn" {
  type        = string
  description = "ARN of the SQS jobs queue consumed by the Lambda job processor."
}
