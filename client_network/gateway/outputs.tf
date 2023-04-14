output "backend_address_pool" {
    value = azurerm_application_gateway.appgateway.backend_address_pool
}

output "gateway_ip" {
  value = azurerm_public_ip.gatewayip
}
