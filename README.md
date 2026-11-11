# ter-homework-03

# Задача 1
<img width="1341" height="1111" alt="1" src="https://github.com/user-attachments/assets/02def113-ff73-4890-a156-d6f629e1d178" />

# Задача 2
1. Создал файл **count-vm.tf** и описал в нём 2 ВМ через **count**. Создал необходимые переменные в **variables.tf**. Описал в **main.tf** конфиг ВМ из первого задания и импортировал её в **tfstate** командой ```terraform import yandex_compute_instance.first_vm fv4d04vhidovcinjk6cg```. В блоке **network_interface** ВМ из первого задания добавил ```security_group_ids = [yandex_vpc_security_group.example.id]``` для того, чтобы она получила уже созданную группу безопасности.
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
```

count-vm.tf:
```
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
}
```

variables.tf:
```
variable "vm_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
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

2. В файле **variable.tf** была создана переменная **each_vm** со следующим листингом:
```
variable "each_vm" {
  type = list(object({
    platform_id   = string,
    vm_name       = string,
    cores         = number,
    memory        = number,
    core_fraction = number,
    disk_size     = number,
    preemptible   = bool,
  }))

  default = [
    {
      vm_name       = "main"
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 1
      core_fraction = 20
      disk_size     = 10
      preemptible   = true
    },
    {
      vm_name       = "replica"
      platform_id   = "standard-v3"
      cores         = 4
      memory        = 2
      core_fraction = 20
      disk_size     = 11
      preemptible   = true
    }
  ]
}
```
Для удобства были изменены названия переменных, указанные в задании, а именно **cpu -> cores**; **ram -> memory**; **disk_volume -> disk_size**, а также добавлены новые. Также создан файл **for_each-vm.tf** со следующим листингом:
```
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
    ssh-keys           = "${lookup(var.vm_instance_metadata.common, "ssh-user")}:${lookup(var.vm_instance_metadata.common, "ssh-key")}"
  }
}
```
3. Порядок создания ресурсов был определён через **depends_on** строкой ```depends_on = [yandex_compute_instance.for_each_vm]```
4. Был добавлен для удобства отдельный файл **locals.tf** со следующим листингом:
```
locals {
  ssh-pub-key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}
```
в Файле **for_each-vm.tf** в блоке **metadata** была изменена строка **ssh-keys** на ```ssh-keys           = "${lookup(var.vm_instance_metadata.common, "ssh-user")}:${local.ssh-pub-key}"```
Выполнил ```terraform plan``` и ```terraform apply```, необходимые ВМ создались
<img width="1846" height="454" alt="3" src="https://github.com/user-attachments/assets/89ae6cef-9b25-4475-a10a-457dfcfb9e53" />

# Задача 3
1. Создал файл **disk_vm.tf** со следующим содержимым
```
resource "yandex_compute_disk" "disk" {
  count = 3

  name = "${var.disks.name}-${count.index}"
  size = var.disks.size
  type = var.disks.type
}
```
Также добавил в **variables.tf** переменную
```
variable "disks" {
  type = object({
    type = string,
    size = number,
    name = string
  })

  default = {
    type = "network-hdd"
    size = 1
    name = "disk"
  }
}
```
Применил изменения -> диски создались
2. Был добавлен динамический блок
```
dynamic "secondary_disk" {
  for_each = yandex_compute_disk.disk

  content {
    disk_id = secondary_disk.value.id
  }
}
```
И применены изменения

# Задача 4
Создал файл **ansible.tf**
```
resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/hosts.tftpl",
  {
    webservers = yandex_compute_instance.web,
    databases  = values(yandex_compute_instance.for_each_vm),
    storages   = [yandex_compute_instance.storage]
  })

  filename = "${abspath(path.module)}/hosts.ini"
}
```
Также создал шаблон **hosts.tftpl**
```
%{if length(webservers) > 0 ~}
[webservers]
%{for vm in webservers ~}
${vm.name}   ansible_host=%{if length(vm.network_interface[0].nat_ip_address) > 0}${vm["network_interface"][0]["nat_ip_address"]}%{else}${vm.network_interface[0].ip_address}%{end>
%{endfor}
%{endif}
%{if length(databases) > 0 ~}
[databases]
%{for vm in databases ~}
${vm.name}   ansible_host=%{if length(vm.network_interface[0].nat_ip_address) > 0}${vm["network_interface"][0]["nat_ip_address"]}%{else}${vm.network_interface[0].ip_address}%{end>
%{endfor}
%{endif}
%{if length(storages) > 0 ~}
[storages]
%{for vm in storages ~}
${vm.name}   ansible_host=%{if length(vm.network_interface[0].nat_ip_address) > 0}${vm["network_interface"][0]["nat_ip_address"]}%{else}${vm.network_interface[0].ip_address}%{end>
%{endfor}
%{endif}
```
# Задача 5
Создаём файл **output.tf** со следующим кодом
```
output "vm_list" {
  value = concat(
    [for vm in yandex_compute_instance.web : {
      name        = vm.name
      fqdn        = vm.fqdn
      id          = vm.id
    }],

    [for vm in values(yandex_compute_instance.for_each_vm) : {
      name        = vm.name
      fqdn        = vm.fqdn
      id          = vm.id
    }]
  )
}
```
Используем функцию **concat** т.к. нужно объединить несколько разных ресурсов в один список
Далее во втором блоке ```[for vm in values(yandex_compute_instance.for_each_vm)
