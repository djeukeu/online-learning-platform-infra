variable "app_name" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "auth" {
  type = object({
    app_name          = string
    db_username       = string
    db_password       = string
    db_port           = number
    db_engine         = string
    db_engine_version = string
  })
}

variable "payment" {
  type = object({
    app_name          = string
    db_username       = string
    db_password       = string
    db_port           = number
    db_engine         = string
    db_engine_version = string
  })
}

variable "course" {
  type = object({
    app_name          = string
    db_username       = string
    db_password       = string
    db_port           = number
    db_engine         = string
    db_engine_version = string
  })
}
