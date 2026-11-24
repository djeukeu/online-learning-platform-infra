# output "eks_cluster" {
#   value = {
#     id       = aws_eks_cluster.eks_cluster.id
#     endpoint = aws_eks_cluster.eks_cluster.endpoint
#   }
# }

# output "auth_db_secret_arn" {
#   value = module.database["auth"].db_secret_arn
# }