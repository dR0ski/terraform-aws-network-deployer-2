# ---------------------------------------------------------------------------------------------------------------
# Locals Object that contains tagging information
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


# ---------------------------------------------------------------------------------------------------------------
# Creates an IPv4 Internet Gateway
# ---------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "igw_ipv4" {
  count = var.igw_decisions.ipv4_internet_gateway==true ? 1:0
  vpc_id = var.vpc_id
  tags = local.default_tags
}


# ---------------------------------------------------------------------------------------------------------------
# Creates an IPv6 Internet Gateway
# ---------------------------------------------------------------------------------------------------------------
resource "aws_egress_only_internet_gateway" "igw_ipv6" {
  count = var.igw_decisions.ipv6_internet_gateway==true ? 1:0
  vpc_id = var.vpc_id
  tags = local.default_tags
}