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

variable "services" {
  type = list(object({
    name        = string
    db_port         = number
    db_engine       = string
    repo_url    = string
    repo_branch = string
    db_buildspec    = string
    image_buildspec = string
  }))
}
