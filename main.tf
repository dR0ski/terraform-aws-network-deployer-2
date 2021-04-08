# ---------------------------------------------------------------------------------------------------------------
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


# ---------------------------------------------------------------------------------------------------------------
# Creates Shared Services VPC
# ---------------------------------------------------------------------------------------------------------------
module "shared_services_vpc" {
  source = "./aws-financial-services-framework-deploy-shared-services-vpc"
  providers = {
    aws = aws.paris
  }
  vpc_cidr_block                        = "100.64.0.0/16"
  public_subnets                        = ["100.64.1.0/24", "100.64.2.0/24", "100.64.3.0/24"]
  private_subnets                       = ["100.64.4.0/24", "100.64.5.0/24", "100.64.6.0/24"]
  transit_gateway_subnets               = ["100.64.7.0/24", "100.64.8.0/24", "100.64.9.0/24"]
  aws_region                            = var.aws_region.paris
  transit_gateway_association_instructions  = var.transit_gateway_association_instructions
}


# ---------------------------------------------------------------------------------------------------------------
# Creates Spoke VPC
# ---------------------------------------------------------------------------------------------------------------
module "spoke_vpc" {
  source = "./aws-financial-services-framework-deploy-spoke-vpc"
  providers = {
    aws = aws.paris
  }

  vpc_cidr_block                            = "100.65.0.0/16"
  public_subnets                            = ["100.65.1.0/24", "100.65.2.0/24", "100.65.3.0/24"]
  private_subnets                           = ["100.65.4.0/24", "100.65.5.0/24", "100.65.6.0/24"]
  transit_gateway_subnets                   = ["100.65.7.0/24", "100.65.8.0/24", "100.65.9.0/24"]
  aws_region                                = var.aws_region.paris
  transit_gateway_association_instructions  = var.transit_gateway_association_instructions

}