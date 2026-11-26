resource "aws_cloudwatch_log_group" "rds_log_group" {
  #checkov:skip=CKV_AWS_338:Database logs are retained for 30 days under the environment's log retention policy.
  #checkov:skip=CKV_AWS_158:Uses CloudWatch Logs default encryption; a customer-managed KMS key is not configured.
  for_each          = toset(local.default_log_exports[var.engine])
  name              = "/aws/rds/instance/${var.name}/${each.key}"
  retention_in_days = 30
}
