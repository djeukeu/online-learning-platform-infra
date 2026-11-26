resource "aws_eks_access_entry" "admin_access" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = var.eks_admin_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_access_AmazonEKSClusterAdminPolicy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.admin_access.principal_arn

  access_scope {
    type = "cluster"
  }
}
