resource "yandex_compute_instance" "for_each_vm" {
  for_each = { for vm in var.each_vm : vm.vm_name => vm }

  name = each.key
  platform_id = each.value.platform_id

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = each.value.disk_size
    }
  }
  scheduling_policy {
    preemptible = each.value.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_instance_network_interface_nat.first_vm
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    serial-port-enable = lookup(var.vm_instance_metadata.common, "serial-port-enable")
    ssh-keys           = "${lookup(var.vm_instance_metadata.common, "ssh-user")}:${local.ssh-pub-key}"
  }
}
