resource "random_string" "random_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "accntpub" {
  name                            = "${var.settings.basestack}${var.settings.environemnt}${random_string.random_suffix.result}accntpub"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = true
  identity {
    type = "SystemAssigned"
  }
  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET"]
      allowed_origins    = ["*"]
      exposed_headers    = ["Date"]
      max_age_in_seconds = 3600
    }
    delete_retention_policy {
    }
  }
  /*
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.example.id]
  }
  */
  min_tls_version = "TLS1_2"
  tags            = var.tags
}

resource "azurerm_storage_encryption_scope" "pubencryption" {
  name               = "microsoftmanaged"
  storage_account_id = azurerm_storage_account.accntpub.id
  source             = "Microsoft.Storage"
}

resource "azurerm_storage_management_policy" "pubpolicy" {
  storage_account_id = azurerm_storage_account.accntpub.id

  rule {
    name    = "rule1"
    enabled = false
    filters {
      prefix_match = ["container1/prefix1"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 10
        tier_to_archive_after_days_since_modification_greater_than = 50
        delete_after_days_since_modification_greater_than          = 100
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
  rule {
    name    = "rule2"
    enabled = false
    filters {
      prefix_match = ["container2/prefix1", "container2/prefix2"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 11
        tier_to_archive_after_days_since_modification_greater_than = 51
        delete_after_days_since_modification_greater_than          = 101
      }
      snapshot {
        change_tier_to_archive_after_days_since_creation = 90
        change_tier_to_cool_after_days_since_creation    = 23
        delete_after_days_since_creation_greater_than    = 31
      }
      version {
        change_tier_to_archive_after_days_since_creation = 9
        change_tier_to_cool_after_days_since_creation    = 90
        delete_after_days_since_creation                 = 3
      }
    }
  }
}

resource "azurerm_storage_container" "static" {
  for_each              = toset(var.public_containers)
  name                  = lower(each.key)
  storage_account_name  = azurerm_storage_account.accntpub.name
  container_access_type = "blob"

}

resource "azurerm_storage_account" "accntpriv" {
  name                            = "${var.settings.basestack}${var.settings.environemnt}${random_string.random_suffix.result}accntpriv"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = true
  identity {
    type = "SystemAssigned"
  }
  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET"]
      allowed_origins    = ["https://${var.settings.environemnt}.rebotics.net", "http://${var.settings.environemnt}.rebotics.net"]
      exposed_headers    = ["Date"]
      max_age_in_seconds = 3600
    }
    delete_retention_policy {
    }
  }
  min_tls_version = "TLS1_2"
  tags            = var.tags
}

resource "azurerm_storage_encryption_scope" "privencryption" {
  name               = "microsoftmanaged"
  storage_account_id = azurerm_storage_account.accntpriv.id
  source             = "Microsoft.Storage"
}

resource "azurerm_storage_management_policy" "privpolicy" {
  storage_account_id = azurerm_storage_account.accntpriv.id

  rule {
    name    = "rule1"
    enabled = false
    filters {
      prefix_match = ["container1/prefix1"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 10
        tier_to_archive_after_days_since_modification_greater_than = 50
        delete_after_days_since_modification_greater_than          = 100
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
  rule {
    name    = "rule2"
    enabled = false
    filters {
      prefix_match = ["container2/prefix1", "container2/prefix2"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 11
        tier_to_archive_after_days_since_modification_greater_than = 51
        delete_after_days_since_modification_greater_than          = 101
      }
      snapshot {
        change_tier_to_archive_after_days_since_creation = 90
        change_tier_to_cool_after_days_since_creation    = 23
        delete_after_days_since_creation_greater_than    = 31
      }
      version {
        change_tier_to_archive_after_days_since_creation = 9
        change_tier_to_cool_after_days_since_creation    = 90
        delete_after_days_since_creation                 = 3
      }
    }
  }
}

resource "azurerm_storage_container" "media" {
  for_each              = toset(var.private_containers)
  name                  = lower(each.key)
  storage_account_name  = azurerm_storage_account.accntpriv.name
  container_access_type = "private"
}
