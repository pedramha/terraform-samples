terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.4.5"
    }
  }
}
# never pass credentials here!
provider "mongodbatlas" {}

resource "mongodbatlas_project" "project" {
  name   = var.project_name
  org_id = var.org_id
}

resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.project.id
  # ip_address = var.ip_address
  cidr_block = var.cidr  
  comment    = "IP Address for accessing the cluster"
}
resource "mongodbatlas_cluster" "cluster" {
  project_id             = mongodbatlas_project.project.id
  name                   = var.cluster_name
  mongo_db_major_version = var.mongodbversion
  cluster_type           = "REPLICASET"
  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }
  # Provider Settings "block"
  cloud_backup                 = true
  auto_scaling_disk_gb_enabled = true
  provider_name                = var.cloud_provider
  provider_instance_size_name  = "M10"
}

resource "mongodbatlas_database_user" "user" {
  username           = var.dbuser
  password           = var.dbuser
  project_id         = mongodbatlas_project.project.id
  auth_database_name = "admin"

  roles {
    role_name     = "dbAdmin"
    database_name = "all"
  }
  labels {
    key   = "Name"
    value = "DB User1"
  }
}
