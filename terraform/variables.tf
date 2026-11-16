variable "app_name" {
  type = string
}

variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Wrong environment value!"
  }
}

variable "github_token" {
  type = string
}

variable "auth" {
  type = object({
    app_name           = string
    db_port            = number
    db_engine          = string
    app_repo_url       = string
    app_repo_branch    = string
    app_repo_buildspec = string
  })
}
