output "external_ip_address_app" {
  #value = yandex_compute_instance.app[*].network_interface.0.nat_ip_address
  value = "${formatlist(
    "%s = %s",
    yandex_compute_instance.app[*].id,
    yandex_compute_instance.app[*].network_interface.0.nat_ip_address
  )}"
}
#output "external_ip_address_app1" {
#  value = yandex_compute_instance.app1.network_interface.0.nat_ip_address
#}
output "lb_ip_address" {
  value = [for s in yandex_lb_network_load_balancer.lb_balancer.listener : s.external_address_spec.0.address].0
}
