# ---------------------------------------------------------------------------------------------------------------
# Amazon VPC Routing Table Resource Creation
# ---------------------------------------------------------------------------------------------------------------

# Creates an AWS routable VPC Routing Table
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "private-routing-table" {
  vpc_id = var.vpc_id
  tags = {
    Name = "AWS_Routing_Table"
    Type = "AWS_Routable"
    Environment = var.environment_type
  }
}


# Creates an AWS externally routable VPC Routing Table
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "external-routing-table" {
  vpc_id = var.vpc_id
  tags = {
    Name = "External_Routing_Table"
    Type = "Externally_Routable"
    Environment = var.environment_type
  }
}


# Creates an AWS Transit Gateway VPC Routing Table
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "tgw-routing-table" {
  vpc_id = var.vpc_id
  tags = {
    Name = "TGW_Routing_Table"
    Type = "Transit_Gateway"
    Environment = var.environment_type
  }
}


# ---------------------------------------------------------------------------------------------------------------
# Amazon VPC Subnets Association with its Route Table
# ---------------------------------------------------------------------------------------------------------------

# Creates VPC Routing Table Associations with AWS routable subnets
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "private-routing-table-association" {
  count = length(var.routable_subnets) > 0 ? length(var.routable_subnets):0
  route_table_id = aws_route_table.private-routing-table.id
  subnet_id      = var.routable_subnets[count.index]
}

# Creates VPC Routing Table Associations with externally routable subnets
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "external-routing-table-association" {
  count = length(var.externally_routable_subnets) > 0 ? length(var.externally_routable_subnets):0
  route_table_id = aws_route_table.external-routing-table.id
  subnet_id      = var.externally_routable_subnets[count.index]
}

# Creates VPC Routing Table Associations with AWS Transit Gateway subnets
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "tgw-routing-table-association" {
  count = length(var.transit_gateway_subnets) > 0 ? length(var.transit_gateway_subnets):0
  route_table_id = aws_route_table.tgw-routing-table.id
  subnet_id      = var.transit_gateway_subnets[count.index]
}
