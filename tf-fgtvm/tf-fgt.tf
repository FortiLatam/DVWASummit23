terraform {
  required_providers {
    fortios = {
      source  = "fortinetdev/fortios"
    }
  }
}

provider "fortios" {
  hostname     = "52.55.58.245:8443"
  token        = "<API_FGT_TOKEN>"
  insecure     = "true"
}

resource "fortios_firewall_address" "trname" {
  color                = 3
  name                 = "<DYN_ADDR_NAME>"
  type                 = "dynamic"
  sdn                  = "<SDN_NAME>"
  sdn_addr_type        = "private"
  filter               = "K8S_Label.app=<APP_NAME>"
  visibility           = "enable"
}