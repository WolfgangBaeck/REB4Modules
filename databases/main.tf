
resource "azurerm_postgresql_flexible_server" "flexdbserver" {
  name                   = "${var.client_name}-dbserver"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.db_version
  delegated_subnet_id    = var.db_subnet_id
  private_dns_zone_id    = var.private_dns_zone_id
  administrator_login    = var.admin_login
  administrator_password = var.admin_pwd
  zone                   = "1"
  storage_mb = var.storage
  sku_name   = "GP_Standard_D4s_v3"
  tags = var.tags
}
resource "azurerm_postgresql_flexible_server_database" "psqldb" {
  for_each = var.server_databases
  name      = each.value["name"]
  server_id = azurerm_postgresql_flexible_server.flexdbserver.id
  collation = each.value["collation"]
  charset   = each.value["charset"]
}
/*
resource "azurerm_postgresql_flexible_server_firewall_rule" "fwrule" {
  name             = "office"
  server_id        = azurerm_postgresql_flexible_server.flexdbserver.id
  start_ip_address    = "76.131.105.93"
  end_ip_address      = "76.131.105.93"
}
*/
