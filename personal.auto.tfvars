cloud_id  = "b1gcndrp4b1c56t4vtv3"
folder_id = "b1gjeu5fo05f0jh5mfug"

default_zone = "ru-central1-a"
default_cidr = ["10.0.1.0/24"]

vpc_name               = "develop"
vm_image_family_ubuntu = "ubuntu-2004-lts"

vm_name = {
  first_vm = "first_vm"
  storage  = "storage"
}

vm_instance_platform_id = {
  web      = "standard-v3"
  first_vm = "standard-v3"
  storage  = "standard-v3" 
}

vm_instance_network_interface_nat = {
  web      = true
  first_vm = true
  storage  = true
}

vm_instance_scheduling_policy_preemptible = {
  web      = true
  first_vm = true
  storage  = true
}

vm_instance_resources = {
  "web" = {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  "first_vm" = {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  "storage" = {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
}

vm_instance_metadata = {
  common = {
    serial-port-enable = 1
    ssh-user           = "ubuntu"
    ssh-key            = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/8wMl1rXEaJF7FIcZekU/vaKffClFybWdb5ha1SQ/o i.grishunin@mfclnr.ru"
  }
}

each_vm = [
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

disks = {
  type = "network-hdd"
  size = 1
  name = "disk"
}

web_provision = true

ssh_private_key_path = "~/.ssh/id_ed25519"
