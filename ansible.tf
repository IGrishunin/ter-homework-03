resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/hosts.tftpl",
  { 
    webservers = yandex_compute_instance.web,
    databases  = values(yandex_compute_instance.for_each_vm),
    storages   = [yandex_compute_instance.storage]
  })

  filename = "${abspath(path.module)}/hosts.ini"
}
