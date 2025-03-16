variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "instance_tenancy" {
  type        = string
  default     = "default"
  description = "A tenancy option for instances launched into the VPC"
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS support in the VPC"
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
}

variable "assign_generated_ipv6_cidr_block" {
  type        = bool
  default     = false
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC"
}

variable "enable_network_address_usage_metrics" {
  type        = bool
  default     = false
  description = "Enable IAM usage metrics"
}

variable "ipv6_cidr_block" {
  type        = string
  default     = null
  description = "The IPv6 CIDR block"
}

variable "ipv6_ipam_pool_id" {
  type        = string
  default     = null
  description = "The ID of an IPv6 address pool from IPAM"
}

variable "ipv6_netmask_length" {
  type        = number
  default     = null
  description = "The netmask length of the IPv6 CIDR you want to request"
}

variable "ipv6_cidr_block_network_border_group" {
  type        = string
  default     = null
  description = "The name of the location from which we advertise to peers"
}

variable "ipv4_ipam_pool_id" {
  type        = string
  default     = null
  description = "The ID of an IPv4 address pool from IPAM"
}

variable "ipv4_netmask_length" {
  type        = number
  default     = null
  description = "The netmask length of the IPv4 CIDR you want to request"
}

variable "name" {
  type        = string
  description = "Name of the VPC"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources"
}

variable "create_internet_gateway" {
  type        = bool
  default     = false
  description = "Whether to create an Internet Gateway"
}

variable "subnet_map" {
  type = map(object({
    cidr_block                                     = string
    availability_zone                              = string
    enable_resource_name_dns_a_record_on_launch    = bool
    enable_resource_name_dns_aaaa_record_on_launch = bool
    map_public_ip_on_launch                        = bool
    ipv6_native                                     = bool
    assign_ipv6_address_on_creation                = bool
    ipv6_cidr_block                                 = string
    enable_dns64                                    = bool
    name                                            = string
    attach_internet_gateway                         = bool
  }))
  description = "A map of subnets to create"
}

variable "nat_gateway_data" {
  type = map(object({
    key = string
  }))
  description = "Data for NAT gateways"
}

variable "additional_routes_map" {
  type = map(object({
    destination_cidr_block      = string
    destination_ipv6_cidr_block = string
    type                        = string
    id                          = string
    key                         = string
  }))
  description = "Additional routes to add"
}
