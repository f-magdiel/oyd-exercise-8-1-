terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------------------------
# Starter resources — do not modify
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "media" {
  bucket = "${var.project}-${var.environment}-media"
}

resource "aws_sqs_queue" "jobs" {
  name = "${var.project}-${var.environment}-jobs"
}

# ---------------------------------------------------------------------------
# IAM module
# ---------------------------------------------------------------------------

module "iam" {
  source = "./infra/modules/iam"

  project       = var.project
  environment   = var.environment
  s3_bucket_arn = aws_s3_bucket.media.arn
  sqs_queue_arn = aws_sqs_queue.jobs.arn
}

# ---------------------------------------------------------------------------
# Root-level outputs
# ---------------------------------------------------------------------------

output "app_server_role_arn" {
  description = "ARN of the IAM role attached to the EC2 app server."
  value       = module.iam.app_server_role_arn
}

output "app_server_instance_profile_name" {
  description = "Name of the EC2 instance profile for the app server."
  value       = module.iam.app_server_instance_profile_name
}

output "job_processor_role_arn" {
  description = "ARN of the IAM role attached to the Lambda job processor."
  value       = module.iam.job_processor_role_arn
}
