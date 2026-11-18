variable "name" {
  type = string
}

variable "db" {
  type = object({
    name       = string
    port       = string
    secret_arn = string
    address    = string
  })
  nullable = true
  default  = null
}

variable "ecr_repo" {
  type = object({
    arn  = string
    name = string
  })
  nullable = true
  default  = null
}

variable "region" {
  type = string
}

variable "github" {
  type = object({
    repo_url  = string
    branch    = string
    buildspec = string
    token     = string
  })
}

variable "vpc_id" {
  type = string
}

variable "subnet_arns" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}
