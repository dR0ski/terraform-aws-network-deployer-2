/*
 Transit Gateway Route Configuration
 ---------------------------------------------------------------------------------------------------------------

The below resources adds a route to the VPC route table of the externally routable subnets and the aws routable
subnets. This module runs after the VPC has been associated with the AWS Transit Gateway.

The route that is added is a default route that points to the transit gateway ID.
*/

locals{
  ip_array = var.add_igw_route_to_externally_routable_route_tables==true ? var.tgw_external_route_destination : var.blanket_default_route_destination
}
# ADDS ROUTE TO AWS ROUTABLE (Private) ROUTE TABLE
# ---------------------------------------------------------------------------------------------------------------

resource "aws_route" "tgw_route_for_aws_route_table" {
  count                     = var.route_table.aws_routable_table == true && var.next_hop_infra.tgw == true && length(var.tgw_aws_route_destination) > 0 && var.default_deployment_route_configuration==true ? length(var.tgw_aws_route_destination) : 0
  route_table_id            = var.aws_route_table_id
  destination_cidr_block    = var.tgw_aws_route_destination[count.index]
  transit_gateway_id        = var.tgw_nexthopinfra_id
}


# ADDS ROUTE TO EXTERNALLY ROUTABLE (Public) ROUTE TABLE
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_route_for_externally_route_table" {
  count = (
  var.route_table.external_table==true && var.next_hop_infra.tgw==true && var.add_igw_route_to_externally_routable_route_tables==true && length(var.tgw_external_route_destination) > 0 && var.default_deployment_route_configuration==true ? length(var.tgw_external_route_destination) : (
  var.route_table.external_table==true && var.next_hop_infra.tgw==true && var.add_igw_route_to_externally_routable_route_tables==false && length(var.blanket_default_route_destination) > 0 && var.default_deployment_route_configuration==true) ? length(var.blanket_default_route_destination) : 0
  )
  route_table_id            = var.external_route_table_id
  destination_cidr_block    = local.ip_array[count.index]
  transit_gateway_id        = var.tgw_nexthopinfra_id
}


resource "aws_route" "tgw_route_for_tgw_route_table" {
   count                     = var.route_table.tgw_table == true && var.next_hop_infra.tgw == true && length(var.tgw_aws_route_destination) > 0 && var.default_deployment_route_configuration==true ? length(var.tgw_subnet_route_destination) : 0
   route_table_id            = var.tgw_route_table_id
   destination_cidr_block    = var.tgw_subnet_route_destination[count.index]
   transit_gateway_id        = var.tgw_nexthopinfra_id
 }


# ADDS POST/ADDITIONAL ROUTE(S) TO TRANSIT GATEWAY & EXTERNALLY ROUTABLE (Public) ROUTE TABLE
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_route_for_tgw_route_table_public_nat" {
  count                     = var.create_public_nat_gateway==true && var.route_table.tgw_table == true && var.next_hop_infra.tgw == true && length(var.tgw_subnet_route_destination_for_public_nat_deployment) > 0 && var.default_deployment_route_configuration==false && var.additional_route_deployment_configuration==true ? length(var.tgw_subnet_route_destination_for_public_nat_deployment) : 0
  route_table_id            = var.tgw_route_table_id
  destination_cidr_block    = var.tgw_subnet_route_destination_for_public_nat_deployment[count.index]
  nat_gateway_id            = var.nat_gw_nexthop_infra_id
}

resource "aws_route" "tgw_route_for_tgw_route_table_private_nat" {
  count                     = var.create_private_nat_gateway==true && var.route_table.tgw_table == true && var.next_hop_infra.tgw == true && length(var.tgw_subnet_route_destination_for_public_nat_deployment) > 0 && var.default_deployment_route_configuration==false && var.additional_route_deployment_configuration==true ? length(var.tgw_subnet_route_destination_for_private_nat_deployment) : 0
  route_table_id            = var.tgw_route_table_id
  destination_cidr_block    = var.tgw_subnet_route_destination_for_private_nat_deployment[count.index]
  nat_gateway_id            = var.nat_gw_nexthop_infra_id
}

# ADDS INTERNET ROUTE TO EXTERNALLY ROUTABLE (Public) ROUTE TABLE
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route" "igw_route_for_externally_route_table_ipv4" {
  count                     = var.add_igw_route_to_externally_routable_route_tables==true && var.default_deployment_route_configuration==false && var.additional_route_deployment_configuration==false ? 1 : 0
  route_table_id            = var.external_route_table_id
  destination_cidr_block    = var.igw_destination_cidr_block
  gateway_id                = var.igw_nexthop_infra_id
}