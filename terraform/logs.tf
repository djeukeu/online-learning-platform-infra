resource "aws_cloudwatch_log_group" "eks_cluster_log_group" {
  name              = "/aws/eks/${var.app_name}-cluster/cluster"
  retention_in_days = 30
}