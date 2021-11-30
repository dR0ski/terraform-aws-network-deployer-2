
# Object that contains a list of key value pairs that forms the tags added to a VPC on creation
# ---------------------------------------------------------------------------------------------------------------
locals {
  default_tags = {
    Name                 = var.Application_Name
    Application_ID       = var.Application_ID
    Application_Name     = var.Application_Name
    Business_Unit        = var.Business_Unit
    CostCenterCode       = var.CostCenterCode
    CreatedBy            = var.CreatedBy
    Manager              = var.Manager
    Environment_Type     = var.Environment_Type
  }
}

resource "aws_eip" "aws_eip_for_nat_gateway" {
  count =   var.nat_decisions.byoip==false && var.nat_decisions.create_eip==true && var.nat_gateway_connectivity_type.public==true ? var.number_of_azs_to_deploy_to : 0
  vpc      = true
}

resource "aws_eip" "customer_byoip-eip-for-nat-gateway" {
  count =   var.nat_decisions.byoip==true && var.nat_decisions.create_eip==true && var.nat_gateway_connectivity_type.public==true ? var.number_of_azs_to_deploy_to : 0
  vpc              = true
  public_ipv4_pool = var.byoip_id
}

resource "aws_nat_gateway" "nat_gateway_public" {
  count = var.create_public_nat_gateway==true && var.nat_decisions.create_nat_gateway == true && var.nat_gateway_connectivity_type.public==true && var.nat_decisions.byoip==false ? var.number_of_azs_to_deploy_to : 0
  allocation_id = aws_eip.aws_eip_for_nat_gateway[count.index].id
  subnet_id     = var.subnet_id[count.index]
  tags =  local.default_tags
  depends_on = [aws_eip.aws_eip_for_nat_gateway]
}

resource "aws_nat_gateway" "nat_gateway_public_byoip" {
  count = var.create_public_nat_gateway==true && var.nat_decisions.create_nat_gateway == true && var.nat_gateway_connectivity_type.public==true && var.nat_decisions.byoip==true ? var.number_of_azs_to_deploy_to : 0
  allocation_id = aws_eip.customer_byoip-eip-for-nat-gateway[count.index].id
  subnet_id     = var.subnet_id[count.index]
  tags =  local.default_tags
  depends_on = [aws_eip.aws_eip_for_nat_gateway]
}

resource "aws_nat_gateway" "nat_gateway_private" {
  count = var.create_private_nat_gateway==true && var.nat_decisions.create_nat_gateway==true && var.nat_gateway_connectivity_type.private==true ? var.number_of_azs_to_deploy_to : 0
  allocation_id = null
  connectivity_type="private"
  subnet_id     = var.subnet_id[count.index]
  tags =  local.default_tags
}