# создание группы
resource "yandex_lb_target_group" "reddit_target_group" {
  name      = "reddit-lb-group"
  folder_id = var.folder_id
  # динамическое формирование таргетов
  # https://www.hashicorp.com/blog/hashicorp-terraform-0-12-preview-for-and-for-each/
  dynamic "target" {
    for_each = [for s in yandex_compute_instance.app : {
      subnet_id = var.subnet_id
      address   = s.network_interface.0.ip_address
    }]
    content {
      subnet_id = target.value.subnet_id
      address   = target.value.address
    }
  }
}


# СОздание балансера
resource "yandex_lb_network_load_balancer" "lb_balancer" {
  name      = "reddit-lb"
  folder_id = var.folder_id
  listener {
    name = "reddit-listener"
    port = 9292
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    # для compute instance
    target_group_id = yandex_lb_target_group.reddit_target_group.id
    # для ig
    #target_group_id = yandex_compute_instance_group.ig-1.load_balancer.0.target_group_id
    healthcheck {
      name = "http"
      http_options {
        port = 9292
        path = "/"
      }
    }
  }
}
