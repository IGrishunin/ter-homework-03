resource "null_resource" "web_hosts_provision" {
  count = var.web_provision ? 1 : 0

  depends_on = [
    yandex_compute_instance.web, 
    yandex_compute_instance.for_each_vm
  ]

  triggers = {
    playbook_src_hash = file("${abspath(path.module)}/playbook.yml")
  }

  provisioner "local-exec" {
    command    = "eval $(ssh-agent) && cat ${var.ssh_private_key_path} | ssh-add -"
    on_failure = continue
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${abspath(path.module)}/hosts.ini ${abspath(path.module)}/playbook.yml"

    on_failure = continue
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}
