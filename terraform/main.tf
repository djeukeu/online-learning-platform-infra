# resource "aws_eks_cluster" "eks_cluster" {
#   name     = var.app_name
#   role_arn = aws_iam_role.eks_cluster_role.arn
#   version  = "1.32"

#   access_config {
#     authentication_mode = "API"
#   }

#   vpc_config {
#     subnet_ids              = concat([for subnet in aws_subnet.public_subnet : subnet.id], [for subnet in aws_subnet.private_subnet : subnet.id])
#     endpoint_private_access = true
#     endpoint_public_access  = true
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
#   ]
# }


# resource "aws_eks_node_group" "node_group" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   node_group_name = "${var.app_name}-node-group"
#   node_role_arn   = aws_iam_role.eks_node_group_role.arn
#   subnet_ids      = concat([for subnet in aws_subnet.public_subnet : subnet.id], [for subnet in aws_subnet.private_subnet : subnet.id])

#   scaling_config {
#     desired_size = 1
#     max_size     = 3
#     min_size     = 1
#   }

#   instance_types = ["t3.medium"]

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_node_group_AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.eks_node_group_AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.eks_node_group_AmazonEC2ContainerRegistryReadOnly,
#   ]
# }

module "auth_db" {
  source       = "./modules/rds"
  name         = var.auth.app_name
  vpc_id       = aws_vpc.vpc.id
  subnet_ids   = [for subnet in aws_subnet.private_subnet : subnet.id]
  port         = var.auth.db_port
  engine       = var.auth.db_engine
  source_sg_id = aws_security_group.codebuild_sg.id
}
