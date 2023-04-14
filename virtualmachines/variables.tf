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

variable "number_of_machines" {
  type        = number
  description = "number of machines to place into the availability set"
}

variable "subnet_id" {
  type = string
  description = "The id of the subnet to place the vm set in"
}
variable "application_gateway_backend_address_pool_ids" {
  type = list(string)
}

variable "vm_password" {
  type = string
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
