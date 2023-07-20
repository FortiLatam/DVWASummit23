terraform {
  required_providers {
    fortios = {
      source  = "fortinetdev/fortios"
    }
  }
}

provider "fortios" {
  hostname     = "<FGT_IP>:<FGT_PORT>"
  token        = "<API_FGT_TOKEN>"
  insecure     = "true"
}

resource "fortios_firewall_address" "k8sappaddr" {
  color                = 3
  name                 = "<DYN_ADDR_NAME>"
  type                 = "dynamic"
  sdn                  = "<SDN_NAME>"
  sdn_addr_type        = "private"
  filter               = "K8S_Label.app=<APP_NAME>"
  visibility           = "enable"
}

resource "fortios_firewall_policy" "fwpolrule" {
  action                      = "accept"
  av_profile                  = "default"
  inspection_mode             = "flow"
  ips_sensor                  = "default"
  logtraffic                  = "utm"
  name                        = "Allow <APP_NAME> egress"
  policyid                    = 2
  schedule                    = "always"
  ssl_ssh_profile             = "certificate-inspection"
  status                      = "enable"
  utm_status                  = "enable"
  nat                         = "enable"
  dstintf {
      name = "port1"
  }
  internet_service_name {
      name = "Amazon-AWS"
  }
  internet_service_name {
      name = "GitHub-GitHub"
  }
  srcaddr {
      name = "<DYN_ADDR_NAME>"
  }
  srcintf {
      name = "gwlb1-tunnels"
  }
}