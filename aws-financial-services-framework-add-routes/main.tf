/*
 Transit Gateway Route Configuration
 ---------------------------------------------------------------------------------------------------------------

The below resources adds a route to the VPC route table of the externally routable subnets and the aws routable
subnets. This module runs after the VPC has been associated with the AWS Transit Gateway.

The route that is added is a default route that points to the transit gateway ID.
*/


# ADDS ROUTE TO AWS ROUTABLE (Private) ROUTE TABLE
# ---------------------------------------------------------------------------------------------------------------

resource "aws_route" "tgw_route_for_aws_route_table" {
  count                     = var.route_table.aws_routable_table == true && var.next_hop_infra.tgw == true && length(var.tgw_aws_route_destination) > 0 ? length(var.tgw_aws_route_destination) : 0
  route_table_id            = var.aws_route_table_id
  destination_cidr_block    = var.tgw_aws_route_destination[count.index]
  transit_gateway_id        = var.tgw_nexthopinfra_id
}


# ADDS ROUTE TO EXTERNALLY ROUTABLE (Public) ROUTE TABLE
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_route_for_externally_route_table" {
  count                     = var.route_table.external_table == true && var.next_hop_infra.tgw == true && length(var.tgw_external_route_destination) > 0 ? length(var.tgw_external_route_destination) : 0
  route_table_id            = var.external_route_table_id
  destination_cidr_block    = var.tgw_external_route_destination[count.index]
  transit_gateway_id        = var.tgw_nexthopinfra_id
}

/*
resource "aws_route" "tgw_route_for_tgw_route_table" {
   count                     = var.route_table.tgw_table == true && var.next_hop_infra.tgw == true && length(var.tgw_aws_route_destination) > 0 ? length(var.tgw_route_destination) : 0
   route_table_id            = var.tgw_route_table_id
   destination_cidr_block    = var.tgw_route_destination[count.index]
   transit_gateway_id        = var.tgw_nexthopinfra_id
 }
*/

