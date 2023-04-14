resource "azurerm_windows_virtual_machine_scale_set" "appset" {
  name                = "${var.client_name}-set"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_D2s_v3"
  instances           = var.number_of_machines
  admin_username      = "adminuser"
  admin_password      = var.vm_password
  upgrade_mode        = "Automatic"
  tags                = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  network_interface {
    name    = "scaleset-interface"
    primary = true

    ip_configuration {
      name                                         = "internal"
      primary                                      = true
      subnet_id                                    = var.subnet_id
      application_gateway_backend_address_pool_ids = var.application_gateway_backend_address_pool_ids
    }
  }
}
