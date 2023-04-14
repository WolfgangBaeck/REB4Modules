variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
}

variable "location" {
  type        = string
  description = "The region for the deployment"
}

variable "settings" {
  type = object({
    basestack   = string
    environemnt = string
  })

}

variable "client_name" {
  type        = string
  description = "name of the client for which this network is built"

}

variable "tags" {
  type = object({
    BillingEnvironment = string
    BillingRetailer    = string
    BillingApplication = string
  })
}

variable "subnet_size" {
  type = string
  validation {
    condition     = contains(["large", "small"], var.subnet_size)
    error_message = "Valid values are large or small."
  }
  description = "Indicates large or small subnet_map to be used"
}

variable "address_prefix" {
  type        = string
  description = "high order portion of address based on client"
}

/*
  This is a map of the desired subnets. The keys in the map are the subnet names, the address postfix will be combined with the address_prefix 
  passed as a variable to result in the desired address_space for the subnet.
*/
variable "subnet_map_large" {
  type = map(any)
  default = {
    AppGatewaySubnet = {
      subnet_postfix    = "0.0/24"
      service_endpoints = []
      delegation = []
      nsg_enabled = false
      nat_enabled = false
      rules             = []
    }
    LB-NAT = {
      subnet_postfix    = "1.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "443"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }

    DB-Delegated = {
      subnet_postfix    = "2.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = ["Microsoft.DBforPostgreSQL/flexibleServers"]
      nsg_enabled = true
      nat_enabled = true
      rules             = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [5432]
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [53,80,123,443]
          source_address_prefix      = "*"
          destination_address_prefix = "0.0.0.0/0"
        }
      ]
    }
    /*
    Public-Free2 = {
      subnet_postfix = "3.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "443"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    */
    Data = {
      subnet_postfix    = "4.0/22"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "5432"
          destination_port_ranges    = []
          source_address_prefix      = "64.0/18"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "5432"
          destination_port_ranges    = []
          source_address_prefix      = "128.0/17"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule3"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [53, 80, 123, 443]
          source_address_prefix      = "*"
          destination_address_prefix = "0.0.0.0/0"
        }
      ]
    }
    Frontend = {
      subnet_postfix    = "64.0/18"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = false
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        /*,
        {
          name                       = "Rule2"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [5432]
          source_address_prefix      = "*"
          destination_address_prefix = "4.0/22"
        },
        {
          name                       = "Rule3"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 400
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [53,80,123,443]
          source_address_prefix      = "*"
          destination_address_prefix = "0.0.0.0/0"
        },
        {
          name                       = "Rule4"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = "80"
          source_port_ranges         = []
          destination_port_range     = "*"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        */
      ]
    }
    /*
    Free = {
      subnet_postfix = "8.0/21"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "443"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    */
    Backend = {
      subnet_postfix    = "128.0/17"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "5432"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "4.0/22",
        },
        {
          name                       = "Rule2"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [53, 80, 123, 443]
          source_address_prefix      = "*"
          destination_address_prefix = "0.0.0.0/0"
        }
      ]
    }
  }
}

variable "subnet_map_small" {
  type = map(any)
  default = {
    AppGatewaySubnet = {
      subnet_postfix    = "0.0/24"
      service_endpoints = []
      delegation = []
      nsg_enabled = false
      nat_enabled = false
      rules             = []
    }
    LB-NAT = {
      subnet_postfix    = "1.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "443"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    /*
    Public-Free1 = {
      subnet_postfix = "2.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "443"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
      ]
    }
    Public-Free2 = {
      subnet_postfix = "3.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "443"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    */
    Data = {
      subnet_postfix    = "4.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "5432"
          destination_port_ranges    = []
          source_address_prefix      = "64.0/18"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "5432"
          destination_port_ranges    = []
          source_address_prefix      = "128.0/17"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule3"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [53, 80, 123, 443]
          source_address_prefix      = "*"
          destination_address_prefix = "0.0.0.0/0"
        }
      ]
    }
    /*
    Free1 = {
      subnet_postfix = "5.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "443"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
      ]
    }
    Free2 = {
      subnet_postfix = "6.0/23"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "443"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    */
    Frontend = {
      subnet_postfix    = "8.0/22"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = false
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = ""
          source_port_ranges         = ["8000-8999", "3000"]
          destination_port_range     = "80"
          destination_port_ranges    = []
          source_address_prefix      = "0.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "Rule2"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [5432]
          source_address_prefix      = "*"
          destination_address_prefix = "4.0/22"
        },
        {
          name                       = "Rule3"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 300
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [53, 80, 123, 443]
          source_address_prefix      = "*"
          destination_address_prefix = "0.0.0.0/0"
        }
      ]
    }
    Backend = {
      subnet_postfix    = "12.0/22"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = []
      nsg_enabled = true
      nat_enabled = true
      rules = [
        {
          name                       = "Rule1"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 100
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = "5432"
          destination_port_ranges    = []
          source_address_prefix      = "*"
          destination_address_prefix = "4.0/22",
        },
        {
          name                       = "Rule2"
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          priority                   = 200
          source_port_range          = "*"
          source_port_ranges         = []
          destination_port_range     = ""
          destination_port_ranges    = [53, 80, 123, 443]
          source_address_prefix      = "*"
          destination_address_prefix = "0.0.0.0/0"
        }
      ]
    }
  }
}
