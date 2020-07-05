resource "yandex_compute_instance" "db" {
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
      image_id = var.db_disk_image
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

resource "null_resource" "db" {
  count = var.install_enable ? 1 : 0
  connection {
    type  = "ssh"
    host  = yandex_compute_instance.db.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i -e 's/127.0.0.1/127.0.0.1,${yandex_compute_instance.db.network_interface.0.ip_address}/g' /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }
}
