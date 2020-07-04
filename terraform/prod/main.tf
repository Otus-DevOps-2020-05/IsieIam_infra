provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}
module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  app_disk_image  = var.app_disk_image
  subnet_id       = var.subnet_id
  cpu_count       = var.app_cpu_count
  ram_size        = var.app_ram_size
  cpu_usage       = var.app_cpu_usage
  instance_name   = var.app_instance_name
}

module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  db_disk_image   = var.db_disk_image
  subnet_id       = var.subnet_id
  cpu_count       = var.db_cpu_count
  ram_size        = var.db_ram_size
  cpu_usage       = var.db_cpu_usage
  instance_name   = var.db_instance_name
}
