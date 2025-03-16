output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC"
}

output "subnet_ids" {
  value       = { for key, subnet in aws_subnet.this : key => subnet.id }
  description = "A map of subnet IDs"
}

output "route_table_ids" {
  value       = { for key, rt in aws_route_table.this : key => rt.id }
  description = "A map of route table IDs"
}

output "nat_gateway_ids" {
  value       = { for key, ngw in aws_nat_gateway.this : key => ngw.id }
  description = "A map of NAT gateway IDs"
}

output "internet_gateway_id" {
  value       = var.create_internet_gateway ? aws_internet_gateway.this[0].id : null
  description = "The ID of the Internet Gateway"
}
