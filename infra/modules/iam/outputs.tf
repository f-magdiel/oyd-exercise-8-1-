output "app_server_role_arn" {
  description = "ARN of the IAM role attached to the EC2 app-server instance."
  value       = aws_iam_role.app_server.arn
}

output "app_server_instance_profile_name" {
  description = "Name of the EC2 instance profile used to attach the app-server role."
  value       = aws_iam_instance_profile.app_server.name
}

output "job_processor_role_arn" {
  description = "ARN of the IAM role assumed by the Lambda job-processor function."
  value       = aws_iam_role.job_processor.arn
}
