resource "yandex_compute_instance" "app" {
  name = var.instance_name
  labels = {
    tags = var.instance_name
  }
  resources {
    cores         = var.cpu_count
    memory        = var.ram_size
    core_fraction = var.cpu_usage
  }

  boot_disk {
    initialize_params {
      image_id = var.app_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    #subnet_id = module.vpc.subnet_id
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}
resource "null_resource" "app" {
  count = var.install_enable ? 1 : 0
  connection {
    type  = "ssh"
    host  = yandex_compute_instance.app.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }
  provisioner "file" {
    source      = "../modules/app/puma.service"
    destination = "/tmp/puma.service"
  }
  provisioner "remote-exec" {
    inline = [
      "echo export DATABASE_URL=${var.db_ip} >> ~/.profile",
    ]
  }
  provisioner "remote-exec" {
    script = "../modules/app/deploy.sh"
  }
}
