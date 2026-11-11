resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_image_family_ubuntu
}

resource "yandex_compute_instance" "first_vm" {
  name        = var.vm_name.first_vm
  platform_id = var.vm_instance_platform_id.first_vm
  resources {
    cores         = lookup(var.vm_instance_resources.first_vm, "cores")
    memory        = lookup(var.vm_instance_resources.first_vm, "memory")
    core_fraction = lookup(var.vm_instance_resources.first_vm, "core_fraction")
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_instance_scheduling_policy_preemptible.first_vm
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_instance_network_interface_nat.first_vm
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    serial-port-enable = lookup(var.vm_instance_metadata.common, "serial-port-enable")
    ssh-keys           = "${lookup(var.vm_instance_metadata.common, "ssh-user")}:${lookup(var.vm_instance_metadata.common, "ssh-key")}"
  }
}
