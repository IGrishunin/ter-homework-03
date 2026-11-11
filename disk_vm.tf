resource "yandex_compute_disk" "disk" {
  count = 3

  name = "${var.disks.name}-${count.index}"
  size = var.disks.size
  type = var.disks.type
}

resource "yandex_compute_instance" "storage" {
  name        = var.vm_name.storage
  platform_id = var.vm_instance_platform_id.storage
  resources {
    cores         = lookup(var.vm_instance_resources.storage, "cores")
    memory        = lookup(var.vm_instance_resources.storage, "memory")
    core_fraction = lookup(var.vm_instance_resources.storage, "core_fraction")
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_instance_scheduling_policy_preemptible.storage
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_instance_network_interface_nat.storage
  }
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.disk
    
    content {
      disk_id = secondary_disk.value.id
    }
  }

  metadata = {
    serial-port-enable = lookup(var.vm_instance_metadata.common, "serial-port-enable")
    ssh-keys           = "${lookup(var.vm_instance_metadata.common, "ssh-user")}:${lookup(var.vm_instance_metadata.common, "ssh-key")}"
  }
}
