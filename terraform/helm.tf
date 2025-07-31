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
      value = aws_iam_role.aws_load_balancer_controller.id
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
      value = aws_iam_role.aws_load_balancer_controller.arn
    }
  ]
}
