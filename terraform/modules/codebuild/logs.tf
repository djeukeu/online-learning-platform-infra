resource "aws_cloudwatch_log_group" "codebuild_log_group" {
  #checkov:skip=CKV_AWS_338:Build logs are retained for 14 days to match the project retention policy.
  #checkov:skip=CKV_AWS_158:Uses CloudWatch Logs default encryption; no customer-managed KMS key is configured.
  name              = var.name
  retention_in_days = 14
}
