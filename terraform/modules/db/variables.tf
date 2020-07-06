variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  description = "Path to the private key used for ssh access"
}
variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
variable subnet_id {
  description = "Subnets for modules"
}
variable cpu_count {
  description = "CPU count"
}
variable ram_size {
  description = "RAM GB"
}
variable cpu_usage {
  description = "cpu % usage"
}
variable instance_name {
  description = "Instance name"
}
variable install_enable {
  description = "run provosioner wit install 1 or 0"
  default     = "1"
}
