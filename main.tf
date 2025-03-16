module "vpc" {
  source = "./vpc"

  cidr_block = "10.0.0.0/16"
  name       = "example-vpc"
  tags       = {
    Environment = "dev"
  }

  create_internet_gateway = true

  subnet_map = {
    "subnet1" = {
      cidr_block                                     = "10.0.1.0/24"
      availability_zone                              = "us-east-1a"
      enable_resource_name_dns_a_record_on_launch    = false
      enable_resource_name_dns_aaaa_record_on_launch = false
      map_public_ip_on_launch                        = true
      ipv6_native                                     = false
      assign_ipv6_address_on_creation                = false
      ipv6_cidr_block                                 = null
      enable_dns64                                    = false
      name                                            = "public-subnet"
      attach_internet_gateway                         = true
    },
    "subnet2" = {
      cidr_block                                     = "10.0.2.0/24"
      availability_zone                              = "us-east-1b"
      enable_resource_name_dns_a_record_on_launch    = false
      enable_resource_name_dns_aaaa_record_on_launch = false
      map_public_ip_on_launch                        = false
      ipv6_native                                     = false
      assign_ipv6_address_on_creation                = false
      ipv6_cidr_block                                 = null
      enable_dns64                                    = false
      name                                            = "private-subnet"
      attach_internet_gateway                         = false
    }
  }

  nat_gateway_data = {
    "subnet1" = {
      key = "subnet1"
    }
  }

  additional_routes_map = {
    "subnet1" = {
      destination_cidr_block      = "10.1.0.0/16"
      destination_ipv6_cidr_block = null
      type                        = "transit-gateway"
      id                          = "tgw-12345678"
      key                         = "subnet1"
    }
  }
}
