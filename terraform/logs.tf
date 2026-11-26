resource "aws_cloudwatch_log_group" "eks_cluster_log_group" {
  #checkov:skip=CKV_AWS_338:Cluster logs are retained for 30 days under the environment's log retention policy.
  #checkov:skip=CKV_AWS_158:Uses CloudWatch Logs default encryption; a customer-managed KMS key is not configured.
  name              = "/aws/eks/${var.app_name}-cluster/cluster"
  retention_in_days = 30
}