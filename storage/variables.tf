variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The region for the deployment"
}

variable "tags" {
  type = object({
    BillingEnvironment = string
    BillingRetailer = string
    BillingApplication = string
  })
}

variable "settings" {
  type = object({
    basestack = string
    environemnt = string
  })
}
variable "private_containers" {
  type = list(string)
  description = "Name of the individual containers for the private storage account"
}

variable "public_containers" {
  type = list(string)
  description = "Name of the individual containers for the public storage account"
}