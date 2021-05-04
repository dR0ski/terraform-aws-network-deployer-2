# get current region from provider
data "aws_region" "current" {}

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


# The Spoke VPC creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "spoke_vpc" {
  cidr_block                            = var.vpc_cidr_block
  instance_tenancy                      = var.instance_tenancy
  enable_dns_support                    = var.dns_support
  enable_dns_hostnames                  = var.dns_host_names
  assign_generated_ipv6_cidr_block      = var.enable_aws_ipv6_cidr_block
  tags                                  = local.default_tags
}

