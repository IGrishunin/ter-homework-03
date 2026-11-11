locals {
  ssh-pub-key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}
