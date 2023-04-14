variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
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
  description = "name of the client for which this network and db is built"

}

variable "tags" {
  type = object({
    BillingEnvironment = string
    BillingRetailer    = string
    BillingApplication = string
  })
}

variable "db_subnet_id" {
  type        = string
  description = "Ids of the database subnet delegated for flexible server"
}

variable "private_dns_zone_id" {
  type        = string
  description = "DNS Zone id for db server"
}

variable "admin_login" {
  type = string
}

variable "admin_pwd" {
  type = string
}

variable "storage" {
  type = number
}

variable "db_version" {
  type = string

}

variable "zone" {
  type    = string
}

variable "sku_name" {
  type    = string
}

variable "server_databases" {
  type = map(any)
}