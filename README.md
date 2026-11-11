# ter-homework-03

# Задача 1
<img width="1341" height="1111" alt="1" src="https://github.com/user-attachments/assets/02def113-ff73-4890-a156-d6f629e1d178" />

# Задача 2
Создал файл **count-vm.tf** и описал в нём 2 ВМ через **count**. Создал необходимые переменные в **variables.tf**. Описал в **main.tf** конфиг ВМ из первого задания и импортировал её в **tfstate** командой ```terraform import yandex_compute_instance.first_vm fv4d04vhidovcinjk6cg```. В блоке **network_interface** ВМ из первого задания добавил ```security_group_ids = [yandex_vpc_security_group.example.id]``` для того, чтобы она получила уже созданную группу безопасности.
Листинг изменений/добавлений
main.tf:
```
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
      image_id = data.yandex_compute_image.first_vm.image_id
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
```

count-vm.tf:
```
data "yandex_compute_image" "web" {
  family = var.vm_image_family.web
}

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
      image_id = data.yandex_compute_image.web.image_id
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
}
```

variables.tf:
```
variable "vm_image_family" {
  type        = map(string)
  default     = {
    web = "ubuntu-2004-lts"
    first_vm = "ubuntu-2004-lts"
  }
}

variable "vm_name" {
  type = map(string)
  default = {
    first_vm = "first_vm"
  }
}

variable "vm_instance_platform_id" {
  type        = map(string)
  default     = {
    web = "standard-v3"
    first_vm = "standard-v3"
  }
}

variable "vm_instance_network_interface_nat" {
  type        = map(bool)
  default     = {
    web = true
    first_vm = true
  }
}

variable "vm_instance_scheduling_policy_preemptible" {
  type = map(bool)
  default = {
    web   = true
    first_vm  = true
  }
}

variable "vm_instance_resources" {
  type              = map(object({
    cores           = number
    memory          = number
    core_fraction   = number
  }))
  default           = {
    "web" = {
      cores         = 2
      memory        = 1
      core_fraction = 20
    }
    "first_vm" = {
      cores = 2
      memory = 1
      core_fraction = 20
    }
  }
}

variable "vm_instance_metadata" {
  type                   = map(object({
    serial-port-enable   = number
    ssh-user             = string
    ssh-key              = string
  }))
  default                = {
    common               = {
      serial-port-enable = 1
      ssh-user           = "ubuntu"
      ssh-key            = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/8wMl1rXEaJF7FIcZekU/vaKffClFybWdb5ha1SQ/o i.grishunin@mfclnr.ru"
    }
  }
}
```
