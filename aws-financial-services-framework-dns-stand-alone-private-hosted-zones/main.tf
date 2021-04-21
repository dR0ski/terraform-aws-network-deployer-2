##########################################################################################
# This module creates the following:
# | > AWS Route 53 Private Hosted Zone
# | > AWS Lambda Function that:
# |   > > > Associates the private hosted zone with the shared services/DNS VPC if exist
# |   > > > Creates a Route 53 Resolver forwarding rule if the option is specified
# |   > > >
##########################################################################################

data "aws_organizations_organization" "my_aws_organization" {}

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
# Route 53 Private Hosted Zone | -> Creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "private_hosted_zone_1" {
  count             = length(var.private_hosted_zone_name)>0 && var.route53_acts.create_standalone_private_hosted_zone==true ? length(var.private_hosted_zone_name) : 0
  name              = var.private_hosted_zone_name[count.index]
  vpc {
    vpc_id          = var.vpc_id
  }
  tags = local.default_tags
}
