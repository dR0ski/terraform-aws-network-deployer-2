#---------------------------------------------------------------------
# Route Table IDs
#---------------------------------------------------------------------
output "aws_routable_routing_table_id" {
  value = aws_route_table.private-routing-table.id
}

output "externally_routable_routing_table_id" {
  value = aws_route_table.external-routing-table.id
}

output "tgw_attachment_routing_table_id" {
  value = aws_route_table.tgw-routing-table.id
}