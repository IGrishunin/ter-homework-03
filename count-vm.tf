resource "yandex_compute_instance" "web" {
  count = 2

  name        = "web-${count.index}"
  platform_id = var.vm_instance_platform_id.web
  resources {
    cores         = lookup(var.vm_instance_resources.web, "cores")
    memory        = lookup(var.vm_instance_resources.web, "memory")
    core_fraction = lookup(var.vm_instance_resources.web, "core_fraction")
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_instance_scheduling_policy_preemptible.web
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_instance_network_interface_nat.web
  }

  metadata = {
    serial-port-enable = lookup(var.vm_instance_metadata.common, "serial-port-enable")
    ssh-keys           = "${lookup(var.vm_instance_metadata.common, "ssh-user")}:${lookup(var.vm_instance_metadata.common, "ssh-key")}"
  }

  depends_on = [yandex_compute_instance.for_each_vm]
}
