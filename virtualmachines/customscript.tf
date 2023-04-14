# The storage account will be used to store the script for Custom Script extension

resource "random_string" "random_suffix" {
  length  = 6
  special = false
  upper   = false
}
resource "azurerm_storage_account" "vmprovisioning" {
  name                     = "${var.client_name}vmproving${random_string.random_suffix.result}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.vmprovisioning.name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.vmprovisioning
  ]
}

resource "azurerm_storage_blob" "IISConfig" {
  name = "IIS_Config.ps1"
  storage_account_name   = azurerm_storage_account.vmprovisioning.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "IIS_Config.ps1"
}


resource "azurerm_virtual_machine_scale_set_extension" "scalesetextension" {
  name                         = "${var.client_name}-scalesetextension"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.appset.id
  publisher                    = "Microsoft.Compute"
  type                         = "CustomScriptExtension"
  type_handler_version         = "1.10"
  depends_on = [
    azurerm_storage_blob.IISConfig
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.vmprovisioning.name}.blob.core.windows.net/data/IIS_Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"     
    }
SETTINGS

}
