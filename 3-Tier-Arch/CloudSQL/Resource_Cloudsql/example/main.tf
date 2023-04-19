resource "random_id" "suffix" {
  byte_length = 5
}


module "mysql-db" {
  source               = "../"
  name                 = $(var.name)-${random_id.siffix[0].hex}"
  project_id           = var.project_id

  deletion_protection  = var.deletion_protection 

  database_version = var.database_version
  region           = var.region
  zone             = var.zone
  tier             = var.db_tier

}
