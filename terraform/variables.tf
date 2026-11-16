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

variable "auth" {
  type = object({
    app_name      = string
    db_port       = number
    db_engine     = string
    app_repo_url  = string
    app_branch    = string
    app_buildspec = string
  })
}
