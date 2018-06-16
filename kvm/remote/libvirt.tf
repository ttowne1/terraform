# instance the provider
provider "libvirt" {
  uri = "qemu+ssh://media@192.168.0.201/system"
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "ubuntu-qcow2" {
  name = "ubuntu-qcow2"
  pool = "raid5" #CHANGE_ME
  source = "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
  format = "qcow2"
}

# Create a network for our VMs
resource "libvirt_network" "vm_network" {
   name = "vm_network"
   addresses = ["10.0.1.0/24"]
}

# Use CloudInit to add our ssh-key to the instance
resource "libvirt_cloudinit" "commoninit" {
          name           = "commoninit.iso"
          pool = "downloads" #CHANGEME
          ssh_authorized_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTnkLPT42ODjwkE+VQO8kyPstXjpo8anJYktuV03CQBlBJah34NaM5XMcGLhE3FDHr2eNJOHUNQTg4T2NTtMtiqSlCDr72ntnN3wF5uK37WO87YnHVlYd2/z+IePZJo9Ttf8tBSneXqpjyJ/WqfIqHYK8WT0rQ43SgwTIl/r4isPgReHfzHAB0A2s2AYj72OVNu8vmh0Wwbe8vvtAWUUQI+NCQiwfhHUlHqQ8rahvwJhVBa4zv9alCh9zQiXvM0l82DlMVCT9UkhhJwvSKMMvmTl6Lfzy0yUp5YWZcAVI4x+wXfChy5CGBcYOnxLqVnj5e5qES6dI/4gq2J6ZJjCFP6m0bc9x1r0TRxeAuJWSBE77/cvT/cfTTb+LKi2VynqvWpuZIN8xLshyDDcVbnruSbSwQThofOoT+MDqDk6RV9utIedeOBBxb4ZD4HGhaJow02ZyHOIuUs3qtBHf3nUq7a2tvEy9OcIyZtsGbvk0l6pvHVDW60/XhTlBVfWLkMBwGmy3vA3GUV31DQcRikMCJ9QsgxyzHZJpMy+Ru6wRmJ/lb5xei8ZJKLLVj5NwiZqDlAJ0OunhzzjyYNXSkiz33iGEyY8hFfn2udUW1HIBJ4ULe2WyLh99IPX+1AfB6j5T0vzf20Dm4MzsTDInfsAQh2YdU15E4vujjzKuLIn0vxQ== ttow@ttowlt" #CHANGE_ME
        }


# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  name = "ubuntu-terraform"
  memory = "512"
  vcpu = 1

  cloudinit = "${libvirt_cloudinit.commoninit.id}"

  network_interface {
    hostname = "master"
    network_name = "vm_network"
  }

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
      type        = "pty"
      target_type = "virtio"
      target_port = "1"
  }

  disk {
       volume_id = "${libvirt_volume.ubuntu-qcow2.id}"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

# Print the Boxes IP
# Note: you can use `virsh domifaddr <vm_name> <interface>` to get the ip later
output "ip" {
  value = "${libvirt_domain.domain-ubuntu.network_interface.0.addresses.0}"
}
