resource "random_id" "suffix" {
  count = var.random_instance_name ? 1 : 0

  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  provider            = google-beta
  project             = var.project_id
  name                = var.master_instance_name
  database_version    = var.database_version
  region              = var.region
  encryption_key_name = var.encryption_key_name
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    backup_configuration {
	  binary_log_enabled = False
	  enabled 		     = True
	  start-time 		 = var.backup_start_time
	}
	
    ip_configuration {
      ipv4-enabled    = var.public_ip
	  require-ssl     = var.require_ssl
	  private-network = "projects/${var.host_project_id}/global/networks/${var.vpc_name}"
	}

    disk_autoresize = var.disk_autoresize

    disk_size    = var.disk_size
    disk_type    = var.disk_type
    pricing_plan = var.pricing_plan
    user_labels  = var.user_labels


    database_flags {
      name  = "log-disconnections"
      value = "on"
    }

    location_preference {
      zone = var.zone
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }
  }

  lifecycle {
    ignore_changes = [
      settings[0].disk_size
    ]
  }

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }

}

resource "google_sql_database" "database_01" {
  count      = var.enable_default_db ? 1 : 0
  name       = var.db_name
  project    = var.project_id
  instance   = google_sql_database_instance.instance.name
  charset    = var.db_charset
  collation  = var.db_collation
  depends_on = [null_resource.module_depends_on, google_sql_database_instance.instance]
}

resource "random_id" "user-password" {
  keepers = {
    name = google_sql_database_instance.instance.name
  }

  byte_length = 8
  depends_on  = [null_resource.module_depends_on, google_sql_database_instance.instance]
}

resource "google_sql_user" "user01" {
  count      = var.enable_default_user ? 1 : 0
  name       = var.user_name
  project    = var.project_id
  instance   = google_sql_database_instance.instance.name
  host       = var.user_host
  password   = var.user_password == "" ? random_id.user-password.hex : var.user_password
  depends_on = [null_resource.module_depends_on, google_sql_database_instance.instance]
}
