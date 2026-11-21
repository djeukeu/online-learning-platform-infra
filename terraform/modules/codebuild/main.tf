resource "aws_security_group" "codebuild_sg" {
  #checkov:skip=CKV_AWS_382:Build environments require outbound access to GitHub and external dependency registries.
  name_prefix = "${var.name}-codebuild-sg"
  description = "Codebuild Security Group"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow unrestricted outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_codebuild_source_credential" "github" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github.token
}

resource "aws_codebuild_project" "codebuild" {
  #checkov:skip=CKV_AWS_316:Privileged mode is disabled for database builds and enabled only for container image builds that require Docker.
  name          = var.name
  description   = "CodeBuild for ${var.name} service"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 30

  source {
    type                = "GITHUB"
    location            = var.github.repo_url
    git_clone_depth     = 1
    report_build_status = true
    buildspec           = var.github.buildspec
  }

  source_version = var.github.branch

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux-x86_64-standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.ecr_repo != null ? true : false

    dynamic "environment_variable" {
      for_each = var.db != null ? {
        DB_USERNAME = { type = "SECRETS_MANAGER", value = "${var.db.secret_arn}:username" }
        DB_PASSWORD = { type = "SECRETS_MANAGER", value = "${var.db.secret_arn}:password" }
        DB_HOST     = { type = "PLAINTEXT", value = var.db.address }
        DB_PORT     = { type = "PLAINTEXT", value = tostring(var.db.port) }
        DB_NAME     = { type = "PLAINTEXT", value = var.db.name }
      } : {}

      content {
        name  = environment_variable.key
        type  = environment_variable.value.type
        value = environment_variable.value.value
      }
    }

    dynamic "environment_variable" {
      for_each = var.ecr_repo != null ? {
        AWS_ACCOUNT_ID = { value = data.aws_caller_identity.current.account_id }
        AWS_REGION     = { value = var.region }
        REPO_NAME      = { value = var.ecr_repo.name }
      } : {}

      content {
        name  = environment_variable.key
        value = environment_variable.value.value
      }
    }

  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_log_group.name
      status     = "ENABLED"
    }
  }

  vpc_config {
    vpc_id = var.vpc_id

    subnets = var.subnet_ids

    security_group_ids = [
      aws_security_group.codebuild_sg.id,
    ]
  }

  depends_on = [aws_codebuild_source_credential.github]
}

resource "aws_codebuild_webhook" "codebuild_webhook" {
  project_name = aws_codebuild_project.codebuild.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    filter {
      type    = "HEAD_REF"
      pattern = "^refs/heads/${var.github.branch}$"
    }
    dynamic "filter" {
      for_each = var.db != null ? [1] : []
      content {
        type    = "FILE_PATH"
        pattern = var.db_migration_path
      }
    }
  }
}
