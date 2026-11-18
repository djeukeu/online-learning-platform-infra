resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set = [{
    name  = "clusterName"
    value = aws_eks_cluster.eks_cluster.name
    },
    {
      name  = "region"
      value = aws_eks_cluster.eks_cluster.region
    },
    {
      name  = "vpcId"
      value = aws_vpc.vpc.id
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = aws_iam_role.helm_role.id
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
      value = aws_iam_role.helm_role.arn
    }
  ]

   depends_on = [
    aws_eks_node_group.eks_node_group,
    aws_iam_role_policy_attachment.helm_role_attach,
  ]
}
