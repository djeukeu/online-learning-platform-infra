resource "aws_cloudwatch_log_group" "rds_log_group" {
  for_each          = toset(local.default_log_exports[var.engine])
  name              = "/aws/rds/instance/${var.name}/${each.key}"
  retention_in_days = 30
}
