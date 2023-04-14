variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The region for the deployment"
}

variable "gw_subnet_id" {
    type = string
    description = "The id of the subnet reserved for the gateway"
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