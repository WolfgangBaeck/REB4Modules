/*
  Building subnets looping through correcsponding map definition
*/

resource "azurerm_subnet" "subnets" {
  for_each             = (var.subnet_size == "large" ? var.subnet_map_large : var.subnet_map_small)
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  name              = each.key
  address_prefixes  = [format("%s.%s", "${var.address_prefix}", each.value["subnet_postfix"])]
  service_endpoints = each.value["service_endpoints"]
  dynamic "delegation" {
    for_each = each.value["delegation"]
    content {
      name = "fs"
      service_delegation {
        name = delegation.value
        actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
      }
    }
    
  }
}

/*
  Building network security groups for NSG Enabled subnets and associate with subnet
*/

resource "azurerm_network_security_group" "appnsg" {
  for_each = {
    for k, v in(var.subnet_size == "large" ? var.subnet_map_large : var.subnet_map_small) : k => v
    if v.nsg_enabled == true
  }
  name                = "${var.client_name}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value["rules"]
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range != "" ? security_rule.value.source_port_range : null
      source_port_ranges         = security_rule.value.source_port_ranges
      destination_port_range     = security_rule.value.destination_port_range != "" ? security_rule.value.destination_port_range : null
      destination_port_ranges    = security_rule.value.destination_port_ranges
      source_address_prefix      = (security_rule.value.source_address_prefix == "*" || security_rule.value.source_address_prefix == "0.0.0.0/0" ? security_rule.value.source_address_prefix : format("%s.%s", "${var.address_prefix}", security_rule.value.source_address_prefix))
      destination_address_prefix = (security_rule.value.destination_address_prefix == "*" || security_rule.value.destination_address_prefix == "0.0.0.0/0" ? security_rule.value.destination_address_prefix : format("%s.%s", "${var.address_prefix}", security_rule.value.destination_address_prefix))
    }
  }
  tags = var.tags
}


resource "azurerm_subnet_network_security_group_association" "appnsg-link" {
  for_each = {
    for k, v in(var.subnet_size == "large" ? var.subnet_map_large : var.subnet_map_small) : k => v
    if v.nsg_enabled == true
  }
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.appnsg[each.key].id
}

/*
  Creating one NAT gateway with public IP in Zone 1 to be used for all subnets
*/

resource "azurerm_public_ip" "natgatewayip" {
  name                = "${var.client_name}-natgateway-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones               = ["1"]
  tags                = var.tags
}

resource "azurerm_nat_gateway" "natgateway" {
  name                    = "${var.client_name}-nat-Gateway"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

/*
  Finally associating each enabled subnet with the NAT gateway
*/

resource "azurerm_subnet_nat_gateway_association" "nat-link" {
  for_each = {
    for k, v in(var.subnet_size == "large" ? var.subnet_map_large : var.subnet_map_small) : k => v
    if v.nat_enabled == true
  }
  subnet_id      = azurerm_subnet.subnets[each.key].id
  nat_gateway_id = azurerm_nat_gateway.natgateway.id
}

/*
  Building Application Gateway
*/
module "gateway" {
  source              = "./gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  gw_subnet_id        = azurerm_subnet.subnets["AppGatewaySubnet"].id
  client_name         = var.client_name
  settings            = var.settings
  tags                = var.tags
  depends_on = [
    azurerm_subnet.subnets
  ]
}

