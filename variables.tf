###cloud var
#variable "token" {
#  type        = string
#  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
#}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "vm_image_family_ubuntu" {
  type        = string
  default     = "ubuntu-2004-lts"
}

variable "vm_name" {
  type = map(string)
  default = {
    first_vm = "first_vm"
    storage  = "storage"
  }
}

variable "vm_instance_platform_id" {
  type        = map(string)
  default     = {
    web      = "standard-v3"
    first_vm = "standard-v3"
    storage  = "standard-v3" 
  }
}

variable "vm_instance_network_interface_nat" {
  type        = map(bool)
  default     = {
    web      = true
    first_vm = true
    storage  = true
  }
}

variable "vm_instance_scheduling_policy_preemptible" {
  type = map(bool)
  default = {
    web      = true
    first_vm = true
    storage  = true
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
    "storage" = {
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
