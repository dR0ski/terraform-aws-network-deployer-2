#---------------------------------------------------------------------
# Route Table IDs
#---------------------------------------------------------------------

# output "routable_subnets" {
#   value = concat(aws_subnet.private-subnet.*.id, [null])[0]
# }


# output "externally_routable_subnets" {
#   value = concat(aws_subnet.externally_routable_subnet.*.id, [null])[0]
# }


# output "transit_gateway_subnets" {
#   value = concat(aws_subnet.transit_gateway_attachment_subnet.*.id, [null])[0]
# }


output "routable_subnets" {
   value = aws_subnet.private-subnet.*.id
 }


 output "externally_routable_subnets" {
   value = aws_subnet.externally_routable_subnet.*.id
 }


 output "transit_gateway_subnets" {
   value = aws_subnet.transit_gateway_attachment_subnet.*.id
 }


output "aws_routable_enabled" {
  value = var.subnet_type.aws_routable
}


output "externally_routable_enabled" {
  value = var.subnet_type.externally_routable
}


output "tgw_routable_enabled" {
  value = var.subnet_type.transit_gateway_subnet
}
