############################
# Auth Service Resources
############################

resource "aws_ecr_repository" "auth_ecr_repo" {
  name                 = "${var.auth.app_name}-repo"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "auth_db" {
  source       = "./modules/rds"
  name         = var.auth.app_name
  vpc_id       = aws_vpc.vpc.id
  subnet_ids   = [for subnet in aws_subnet.private_subnet : subnet.id]
  port         = var.auth.db_port
  engine       = var.auth.db_engine
  source_sg_id = module.auth_db_build.codebuild_sg_id
}

module "auth_db_build" {
  source      = "./modules/codebuild"
  name        = "${var.auth.app_name}-db"
  vpc_id      = aws_vpc.vpc.id
  subnet_ids  = [for subnet in aws_subnet.private_subnet : subnet.id]
  subnet_arns = [for subnet in aws_subnet.private_subnet : subnet.arn]
  region      = var.aws_region
  github = {
    repo_url  = var.auth.app_repo_url
    branch    = var.auth.app_repo_branch
    buildspec = var.auth.db_buildspec
    token     = var.github_token
  }
  db = {
    name       = module.auth_db.db_name
    port       = module.auth_db.db_port
    secret_arn = module.auth_db.db_secret_arn
    address    = module.auth_db.db_address
  }
}

module "auth_image_build" {
  source      = "./modules/codebuild"
  name        = "${var.auth.app_name}-image"
  vpc_id      = aws_vpc.vpc.id
  subnet_ids  = [for subnet in aws_subnet.private_subnet : subnet.id]
  subnet_arns = [for subnet in aws_subnet.private_subnet : subnet.arn]
  region      = var.aws_region
  github = {
    repo_url  = var.auth.app_repo_url
    branch    = var.auth.app_repo_branch
    buildspec = var.auth.image_buildspec
    token     = var.github_token
  }
  ecr_repo = {
    arn  = aws_ecr_repository.auth_ecr_repo.arn
    name = aws_ecr_repository.auth_ecr_repo.name
  }
}

############################
# Course Service Resources
############################

resource "aws_ecr_repository" "course_ecr_repo" {
  name                 = "${var.course.app_name}-repo"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "course_db" {
  source       = "./modules/rds"
  name         = var.course.app_name
  vpc_id       = aws_vpc.vpc.id
  subnet_ids   = [for subnet in aws_subnet.private_subnet : subnet.id]
  port         = var.course.db_port
  engine       = var.course.db_engine
  source_sg_id = module.course_db_build.codebuild_sg_id
}

module "course_db_build" {
  source      = "./modules/codebuild"
  name        = "${var.course.app_name}-db"
  vpc_id      = aws_vpc.vpc.id
  subnet_ids  = [for subnet in aws_subnet.private_subnet : subnet.id]
  subnet_arns = [for subnet in aws_subnet.private_subnet : subnet.arn]
  region      = var.aws_region
  github = {
    repo_url  = var.course.app_repo_url
    branch    = var.course.app_repo_branch
    buildspec = var.course.db_buildspec
    token     = var.github_token
  }
  db = {
    name       = module.course_db.db_name
    port       = module.course_db.db_port
    secret_arn = module.course_db.db_secret_arn
    address    = module.course_db.db_address
  }
}

module "course_image_build" {
  source      = "./modules/codebuild"
  name        = "${var.course.app_name}-image"
  vpc_id      = aws_vpc.vpc.id
  subnet_ids  = [for subnet in aws_subnet.private_subnet : subnet.id]
  subnet_arns = [for subnet in aws_subnet.private_subnet : subnet.arn]
  region      = var.aws_region
  github = {
    repo_url  = var.course.app_repo_url
    branch    = var.course.app_repo_branch
    buildspec = var.course.image_buildspec
    token     = var.github_token
  }
  ecr_repo = {
    arn  = aws_ecr_repository.course_ecr_repo.arn
    name = aws_ecr_repository.course_ecr_repo.name
  }
}

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


