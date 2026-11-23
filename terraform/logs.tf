resource "aws_cloudwatch_log_group" "eks_cluster_log_group" {
  name              = "/aws/eks/${var.app_name}-cluster/cluster"
  retention_in_days = 30
}

resource "aws_eks_addon" "eks_cluster_pod_identity" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_addon" "eks_cluster_observability" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "amazon-cloudwatch-observability"

  depends_on = [aws_eks_pod_identity_association.cloudwatch_agent]
}
