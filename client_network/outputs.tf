output "subnets" {
    value = azurerm_subnet.subnets
  
}

output "gateway_ip" {
  value = module.gateway.gateway_ip
}

output "backend_address_pool" {
    value = module.gateway.backend_address_pool
}
