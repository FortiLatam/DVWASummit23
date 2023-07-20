terraform {
  required_providers {
    fortiwebcloud = {
      source  = "fortinet/terraform/fortiwebcloud"
      version = "1.0.4"
    }
  }
}

provider "fortiwebcloud" {
  hostname   = "api.fortiweb-cloud.com"
  api_token  = "<API_FWB_TOKEN>"
}

resource "fortiwebcloud_app" "app_<APP_NAME>" {
  app_name    = "webapp_<APP_NAME>"
  domain_name = "<CNAME_APP>"
  app_service = {
    http  = 80
    https = 443
  }
  origin_server_ip      = "<EXTERNAL_LBIP>"
  origin_server_service = "HTTP"
  origin_server_port    = "80"
  cdn                   = false
  continent_cdn         = false
  block                 = true
}

output "cname" {
  value = fortiwebcloud_app.app_<APP_NAME>.cname
}