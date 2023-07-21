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
  schedule                    = "always"
  ssl_ssh_profile             = "certificate-inspection"
  status                      = "enable"
  utm_status                  = "enable"
  nat                         = "enable"
    service {
    name = "HTTP"
  }
  service {
    name = "HTTPS"
  }
  dstintf {
      name = "port1"
  }
  srcintf {
      name = "gwlb1-tunnels"
  }
  dstaddr {
    name = "all"
  }
  srcaddr {
      name = "<DYN_ADDR_NAME>"
  }
    depends_on = [fortios_firewall_address.k8sappaddr]
}
resource "fortios_firewall_security_policyseq" "test1" {
  policy_src_id         = fortios_firewall_policy.fwpolrule.policyid
  policy_dst_id         = 6
  alter_position        = "before"
  enable_state_checking = true
}