# Basic configuration withour variables

# Define authentification configuration
provider "vsphere" {
  # If you use a domain set your login like this "MyDomain\\MyUser"
  user                 = "root"
  password             = "asdf;lkj"
  vsphere_server       = "192.168.0.27"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "dc" {
  name = "my-litle-datacenter"
}

data "vsphere_resource_pool" "pool" {
  # If you haven't resource pool, put "Resources" after cluster name
  name          = "my-litle-cluster/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_host" "host" {
  name          = "my-litle-host"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = "biggy"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "cent6a"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

#### VM CREATION ####

# Set vm parameters
resource "vsphere_virtual_machine" "vm-one" {
  name                 = "vm-one"
  num_cpus             = 2
  memory               = 4096
  datastore_id         = "${data.vsphere_datastore.datastore.id}"
  host_system_id       = "${data.vsphere_host.host.id}"
  resource_pool_id     = "${data.vsphere_resource_pool.pool.id}"
  guest_id             = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type            = "${data.vsphere_virtual_machine.template.scsi_type}"

  # Set network parameters
  network_interface {
    network_id         = "${data.vsphere_network.network.id}"
  }

  # Use a predefined vmware template has main disk
  disk {
    name = "vm-one.vmdk"
    size = "30"
  }

}
