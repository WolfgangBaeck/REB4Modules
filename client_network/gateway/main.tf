resource "azurerm_public_ip" "gatewayip" {
  name                = "${var.client_name}-gateway-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
}


resource "azurerm_application_gateway" "appgateway" {
  name                = "${var.client_name}-app-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.gw_subnet_id
  }

  frontend_port {
    name = "front-end-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "front-end-ip-config"
    public_ip_address_id = azurerm_public_ip.gatewayip.id
  }

  backend_address_pool {
    name = "backend-pool"
  }


  backend_http_settings {
    name                  = "HTTPSetting"
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  backend_http_settings {
    name                  = "backend_http_setting_name"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "gateway-listener"
    frontend_ip_configuration_name = "front-end-ip-config"
    frontend_port_name             = "front-end-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "RoutingRuleBasic"
    rule_type                  = "Basic"
    http_listener_name         = "gateway-listener"
    priority                   = 1
    backend_http_settings_name = "backend_http_setting_name"
    backend_address_pool_name  = "backend-pool"
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.appfirewall.id

  depends_on = [
    azurerm_web_application_firewall_policy.appfirewall
  ]


}
