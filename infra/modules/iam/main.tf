# ===========================================================================
# app-server — EC2 role with least-privilege S3 access
# ===========================================================================

resource "aws_iam_role" "app_server" {
  name        = "${var.project}-${var.environment}-app-server-role"
  description = "IAM role assumed by the EC2 app-server instance."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
    Component   = "app-server"
  }
}

resource "aws_iam_policy" "app_server" {
  name        = "${var.project}-${var.environment}-app-server-policy"
  description = "Least-privilege S3 policy for the EC2 app-server."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Sid      = "S3BucketList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = var.s3_bucket_arn
      }
    ]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
    Component   = "app-server"
  }
}

resource "aws_iam_role_policy_attachment" "app_server" {
  role       = aws_iam_role.app_server.name
  policy_arn = aws_iam_policy.app_server.arn
}

resource "aws_iam_instance_profile" "app_server" {
  name = "${var.project}-${var.environment}-app-server-profile"
  role = aws_iam_role.app_server.name

  tags = {
    Project     = var.project
    Environment = var.environment
    Component   = "app-server"
  }
}

# ===========================================================================
# job-processor — Lambda role with least-privilege SQS + scoped S3 access
# ===========================================================================

resource "aws_iam_role" "job_processor" {
  name        = "${var.project}-${var.environment}-job-processor-role"
  description = "IAM role assumed by the Lambda job-processor function."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
    Component   = "job-processor"
  }
}

resource "aws_iam_policy" "job_processor" {
  name        = "${var.project}-${var.environment}-job-processor-policy"
  description = "Least-privilege SQS consumer and scoped S3 write policy for the Lambda job-processor."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SQSConsume"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arn
      },
      {
        Sid      = "S3ResultsWrite"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${var.s3_bucket_arn}/results/*"
      }
    ]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
    Component   = "job-processor"
  }
}

resource "aws_iam_role_policy_attachment" "job_processor" {
  role       = aws_iam_role.job_processor.name
  policy_arn = aws_iam_policy.job_processor.arn
}
