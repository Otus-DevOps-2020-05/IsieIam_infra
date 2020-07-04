variable cloud_id {
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable vm_zone {
  description = "VM_zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  # Описание переменной
  description = "Path to the private key used for ssh access"
}
variable image_id {
  description = "Disk image"
}
variable image_full_id {
  description = "Full Disk image"
}
variable subnet_id {
  description = "Subnet"
}
variable service_account_key_file {
  description = "key .json"
}
variable service_account_id {
  description = "ID"
}
variable vm_count {
  description = "VM count"
  default     = "1"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
variable app_cpu_count {
  description = "app CPU count"
}
variable app_ram_size {
  description = "app RAM GB"
}
variable app_cpu_usage {
  description = "app cpu % usage"
}
variable db_cpu_count {
  description = "db CPU count"
}
variable db_ram_size {
  description = "db RAM GB"
}
variable db_cpu_usage {
  description = "db cpu % usage"
}
variable app_instance_name {
  description = "app instance and tag name"
}
variable db_instance_name {
  description = "db instance and tag name"
}
