# Declare the data source
# ---------------------------------------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}


# AWS Routable Subnet Declaration 
# ---------------------------------------------------------------------------------------------------------------
# Private Subnet Declaration 
# ---------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "private-subnet" {
  count = (
    length(data.aws_availability_zones.available.names) >= length(var.private_subnets) && var.subnet_type.aws_routable == true ? length(var.private_subnets) : (
      length(var.private_subnets) > length(data.aws_availability_zones.available.names) && var.subnet_type.aws_routable == true ? length(data.aws_availability_zones.available.names) : 0
    )
  )
  vpc_id                                  = var.vpc_id
  cidr_block                              = var.private_subnets[count.index]
  availability_zone                       = data.aws_availability_zones.available.names[count.index]
  assign_ipv6_address_on_creation         = var.assign_ipv6_address_on_creation
  tags = {
		Name = "AWS_Routable_Subnet_${count.index}"
    Type = "AWS_Routable_Subnet"
		Environment = var.environment_type
	}
}


# Externally Routable Subnet Declaration 
# ---------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "externally_routable_subnet" {
  count = (
    length(data.aws_availability_zones.available.names) >= length(var.private_subnets) && var.subnet_type.externally_routable == true ? length(var.private_subnets) : (
      length(var.private_subnets) > length(data.aws_availability_zones.available.names) && var.subnet_type.externally_routable == true ? length(data.aws_availability_zones.available.names) : 0
    )
  )
  vpc_id                                  = var.vpc_id
  cidr_block                              = var.public_subnets[count.index]
  availability_zone                       = data.aws_availability_zones.available.names[count.index]
  assign_ipv6_address_on_creation         = var.assign_ipv6_address_on_creation
  map_public_ip_on_launch                 = var.map_public_ip_on_launch

  tags = {
		Name = "Externally_Routable_Subnet_${count.index}"
    Type = "Externally_Routable_Subnet"
		Environment = var.environment_type
	}
}


# Transit Gateway Routable Subnet Declaration 
# ---------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "transit_gateway_attachment_subnet" {
  count = (
    length(data.aws_availability_zones.available.names) >= length(var.transit_gateway_subnets) && var.subnet_type.transit_gateway_subnet == true ? length(var.transit_gateway_subnets) : (
      length(var.transit_gateway_subnets) > length(data.aws_availability_zones.available.names) && var.subnet_type.transit_gateway_subnet == true ? length(data.aws_availability_zones.available.names) : 0
    )
  )
  vpc_id                                  = var.vpc_id
  cidr_block                              = var.transit_gateway_subnets[count.index]
  availability_zone                       = data.aws_availability_zones.available.names[count.index]
  assign_ipv6_address_on_creation         = var.assign_ipv6_address_on_creation
  map_public_ip_on_launch                 = var.map_public_ip_on_launch

  tags = {
		Name = "TGW_Attachment_Subnet_${count.index}"
    Type = "TGW_Attachment_Subnet"
		Environment = var.environment_type
	}
}

//
//# ---------------------------------------------------------------------------------------------------------------
//# Spoke VPC | ---> Creates VPC Route Table & Perform Route Table Association
//# ---------------------------------------------------------------------------------------------------------------
//module "vpc-route-table" {
//  source  = "./aws-financial-services-framework-amazon-vpc-route-table-for-terraform"
//  vpc_id = var.vpc_id
//  externally_routable_subnets = "${aws_subnet.externally_routable_subnet.*.id}"
//  routable_subnets = "${aws_subnet.private-subnet.*.id}"
//  transit_gateway_subnets = "${aws_subnet.transit_gateway_attachment_subnet.*.id}"
//  environment_type = var.environment_type
//}
//
//
//# Add Route Module
//# ---------------------------------------------------------------------------------------------------------------
//module "fsf-add-route" {
//  source                          = "./aws-financial-services-framework-add-routes"
//  aws_route_table_id              = module.vpc-route-table.aws_routable_routing_table_id
//  external_route_table_id         = module.vpc-route-table.externally_routable_routing_table_id
//
//  tgw_aws_route_destination       = var.tgw_aws_route_destination
//  tgw_external_route_destination  = var.tgw_external_route_destination
//
//  tgw_nexthopinfra_id             = data.terraform_remote_state.transit_gateway_network.outputs.transit_gateway_id     #ENTER TGW ID    : THIS COULD BE A MODULE REFERENCE OR MANUALLY ENTERED ID : IF CREATE TGW ROUTE IS TRUE
//  route_table                     = var.route_table
//  next_hop_infra                  = var.next_hop_infra
//}
//

/*
# ---------------------------------------------------------------------------------------------------------------
# AWS Transit Gateway | This module submits a TGW association request then automatically configure TGW route tables
# ---------------------------------------------------------------------------------------------------------------
module "terraform-aws-fsf-transit-gateway-association" {
  source                                = "./aws-financial-services-framework-transit-gateway-association"
  vpc_id                                = var.vpc_id
  environment_type                      = var.environment_type
  transit_gateway_subnets               = "${aws_subnet.transit_gateway_attachment_subnet.*.id}"
  create_transit_gateway_association    = var.transit_gateway_association_instructions.create_transit_gateway_association
  transit_gateway_subnets_exist         = var.subnet_type.transit_gateway_subnet
  access_shared_services_vpc            = var.transit_gateway_association_instructions.access_shared_services_vpc 
  perform_east_west_packet_inspection   = var.transit_gateway_association_instructions.perform_east_west_packet_inspection
}
*/