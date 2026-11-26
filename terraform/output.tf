output "eks_cluster" {
  value = {
    name     = aws_eks_cluster.eks_cluster.id
    endpoint = aws_eks_cluster.eks_cluster.endpoint
  }
}

output "db_secret_arns" {
  value = {
    for service, database in module.database :
    service => database.db_secret_arn
  }
}

output "db_addresses" {
  value = {
    for service, database in module.database :
    service => database.db_address
  }
}

output "db_ports" {
  value = {
    for service, database in module.database :
    service => database.db_port
  }
}

output "db_names" {
  value = {
    for service, database in module.database :
    service => database.db_name
  }
}