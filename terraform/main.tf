resource "aws_ecr_repository" "ecr_repo" {
  #checkov:skip=CKV_AWS_136:Uses ECR-managed AES-256 encryption; a customer-managed KMS key is not configured.
  for_each = { for service in var.services : service.name => service }

  name                 = "${each.value.name}-repo"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "database" {
  for_each = { for service in var.services : service.name => service }

  source = "./modules/rds"

  name       = each.value.name
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [for subnet in aws_subnet.private_subnet : subnet.id]
  port       = each.value.db_port
  engine     = each.value.db_engine
}

resource "aws_security_group_rule" "db_sg_rule" {
  for_each = { for service in var.services : service.name => service }

  description              = "DB Security Group rule to grant DB Port access to the associated codebuild Source Security Group"
  type                     = "ingress"
  from_port                = module.database[each.key].db_port
  to_port                  = module.database[each.key].db_port
  protocol                 = "tcp"
  security_group_id        = module.database[each.key].db_security_group_id
  source_security_group_id = module.database_build[each.key].codebuild_sg_id
}

module "database_build" {
  for_each = { for service in var.services : service.name => service }

  source = "./modules/codebuild"

  name        = "${each.value.name}-db"
  vpc_id      = aws_vpc.vpc.id
  subnet_ids  = [for subnet in aws_subnet.private_subnet : subnet.id]
  subnet_arns = [for subnet in aws_subnet.private_subnet : subnet.arn]
  region      = var.aws_region
  github = {
    repo_url  = each.value.repo_url
    branch    = each.value.repo_branch
    buildspec = each.value.db_buildspec
    token     = var.github_token
  }
  db = {
    name       = module.database[each.key].db_name
    port       = module.database[each.key].db_port
    secret_arn = module.database[each.key].db_secret_arn
    address    = module.database[each.key].db_address
  }
}

module "image_build" {
  for_each = { for service in var.services : service.name => service }

  source = "./modules/codebuild"

  name        = "${each.value.name}-image"
  vpc_id      = aws_vpc.vpc.id
  subnet_ids  = [for subnet in aws_subnet.private_subnet : subnet.id]
  subnet_arns = [for subnet in aws_subnet.private_subnet : subnet.arn]
  region      = var.aws_region
  github = {
    repo_url  = each.value.repo_url
    branch    = each.value.repo_branch
    buildspec = each.value.image_buildspec
    token     = var.github_token
  }
  ecr_repo = {
    arn  = aws_ecr_repository.ecr_repo[each.key].arn
    name = aws_ecr_repository.ecr_repo[each.key].name
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.app_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.37"

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids              = [for subnet in aws_subnet.private_subnet : subnet.id]
    endpoint_private_access = true
    endpoint_public_access  = true

  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
  ]
}


resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.app_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = [for subnet in aws_subnet.private_subnet : subnet.id]

  scaling_config {
    desired_size = length(aws_subnet.private_subnet)
    min_size     = length(aws_subnet.private_subnet)
    max_size     = length(aws_subnet.private_subnet) * 2
  }

  instance_types = ["t3.medium"]
  ami_type = "AL2023_x86_64_STANDARD"

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEC2ContainerRegistryReadOnly,
  ]
}


