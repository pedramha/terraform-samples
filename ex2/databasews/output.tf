output "connection_strings" {
    value = "mongodb+srv://${mongodbatlas_database_user.user.username}:${mongodbatlas_database_user.user.username}@${trim(mongodbatlas_cluster.cluster.connection_strings[0].standard_srv, "mongodb+srv://")}"
    sensitive = true
}

output "ipaccesslist" {
  value = mongodbatlas_project_ip_access_list.ip.ip_address
}

output "project_name" {
  value = mongodbatlas_project.project.name
}