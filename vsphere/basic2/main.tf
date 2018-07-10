provider "esxi" {
  esxi_hostname      = "esxi"
  esxi_hostport      = "22"
  esxi_username      = "root"
  esxi_password      = "MyPassword"
}
resource "esxi_resource_pool" "MyPool" {
  resource_pool_name = "MyPool"
  cpu_min            = "100"
  cpu_min_expandable = "true"
  cpu_max            = "8000"
  cpu_shares         = "normal"
  mem_min            = "200"
  mem_min_expandable = "true"
  mem_max            = "8000"
  mem_shares         = "normal"
}
resource "esxi_guest" "vmtest" {
  depends_on         = ["esxi_resource_pool.MyPool"]
  guest_name         = "v-test"
  esxi_disk_store    = "MyDiskStore"
  esxi_resource_pool = "Terraform"

  # Use clone_from_vm or ovf_source as a source.
  clone_from_vm      = "Templates/centos7"
  #ovf_source        = "/u1/devel/terraform/centos-7-min/centos-7.vmx"
}
