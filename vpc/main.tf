resource "aws_vpc" "dev" {
  cidr_block                           = var.cidr_block
  instance_tenancy                     = var.instance_tenancy
  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block     = var.assign_generated_ipv6_cidr_block
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  ipv6_cidr_block                      = var.ipv6_cidr_block
  ipv6_ipam_pool_id                    = var.ipv6_ipam_pool_id
  ipv6_netmask_length                  = var.ipv6_netmask_length
  ipv6_cidr_block_network_border_group = var.ipv6_cidr_block_network_border_group

  ipv4_ipam_pool_id   = var.ipv4_ipam_pool_id
  ipv4_netmask_length = var.ipv4_netmask_length

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_internet_gateway" "igw" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.dev.id

  tags = merge(
    {
      Name = "internet-gateway-${aws_vpc.dev.id}"
    },
    var.tags
  )
}

resource "aws_subnet" "devsubnet" {
  for_each = var.subnet_map

  vpc_id                                         = aws_vpc.dev.id
  cidr_block                                     = each.value.cidr_block
  availability_zone                              = each.value.availability_zone
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch
  map_public_ip_on_launch                        = each.value.map_public_ip_on_launch

  ipv6_native                     = each.value.ipv6_native
  assign_ipv6_address_on_creation = each.value.assign_ipv6_address_on_creation
  ipv6_cidr_block                 = each.value.ipv6_cidr_block
  enable_dns64                    = each.value.enable_dns64

  tags = merge(
    {
      Name = each.value.name
    },
    var.tags
  )
}

resource "aws_eip" "nat_gw" {
  for_each = var.nat_gateway_data

  tags = merge(
    {
      Name = "${each.key}-eip"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "devngw" {
  for_each = { for key, value in var.nat_gateway_data : value.key => value }

  allocation_id = aws_eip.nat_gw[each.key].id
  subnet_id     = aws_subnet.this[each.key].id

  tags = merge(
    {
      Name = "nat-gateway-${each.key}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.igw]
}

# Creates one Route table for each Subnet
resource "aws_route_table" "rt" {
  for_each = var.subnet_map

  vpc_id = aws_vpc.dev.id

  tags = merge(
    {
      Name = each.value.attach_internet_gateway ? "${each.value.name}-public-route" : "${each.value.name}-private-route"
    },
    var.tags
  )
}

resource "aws_route" "nat" {
  for_each = { for key, value in var.subnet_map : key => value if !value.attach_internet_gateway }

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route" "internet_gw" {
  for_each = { for key, value in var.subnet_map : key => value if value.attach_internet_gateway }

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "this" {
  for_each = var.subnet_map

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}

resource "aws_route" "additional" {
  for_each = var.additional_routes_map

  route_table_id              = aws_route_table.this[each.value.key].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  egress_only_gateway_id    = each.value.type == "egress-only-gateway" ? each.value.id : null
  network_interface_id      = each.value.type == "network-interface" ? each.value.id : null
  transit_gateway_id        = each.value.type == "transit-gateway" ? each.value.id : null
  vpc_endpoint_id           = each.value.type == "vpc-endpoint" ? each.value.id : null
  vpc_peering_connection_id = each.value.type == "vpc-peering-connection" ? each.value.id : null
}
