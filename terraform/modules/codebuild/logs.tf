resource "aws_cloudwatch_log_group" "codebuild_log_group" {
  name              = var.name
  retention_in_days = 14
}
