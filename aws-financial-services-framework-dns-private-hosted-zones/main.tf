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
  count             = length(var.private_hosted_zone_name)>0 && var.route53_acts.create_private_hosted_zone==true ? length(var.private_hosted_zone_name) : 0
  name              = var.private_hosted_zone_name[count.index]
  vpc {
    vpc_id          = var.vpc_id
  }
}


resource "aws_route53_vpc_association_authorization" "route_53_assoc_authorization" {
  count             = length(var.private_hosted_zone_name)>0 && var.route53_acts.create_private_hosted_zone==true ? length(var.private_hosted_zone_name) : 0
  vpc_id  = var.shared_services_vpc_id
  zone_id = aws_route53_zone.private_hosted_zone_1[count.index].id
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Lambda | Invoking the FN that adds the creation of this PHZ as an event in the Shared Service EventBus
# ---------------------------------------------------------------------------------------------------------------
data "aws_lambda_invocation" "route53_private_hosted_zone_association" {
  count = var.attach_to_centralize_dns_solution == true && var.route53_acts.create_private_hosted_zone==true ? length(var.private_hosted_zone_name):0
  function_name = var.route53_association_lambda_fn_name
  input = <<JSON
  {
    "event_type": "route53_phz_association",
    "hosted_zone_id": "${aws_route53_zone.private_hosted_zone_1[count.index].zone_id}",
    "vpc_id": "${var.shared_services_vpc_id}",
    "vpc_region": "${var.vpc_region}",
    "eventbus_arn": "${var.eventbus_arn}",
    "rule_type": "${var.rule_type}",
    "share_forwarding_rule_with_aws_organization": "${var.route53_acts.share_forwarding_rule_with_aws_organization}",
    "domain_name":"${aws_route53_zone.private_hosted_zone_1[count.index].name}",
    "aws_organizations_id":"${data.aws_organizations_organization.my_aws_organization.id}",
    "aws_organizations_arn":"${data.aws_organizations_organization.my_aws_organization.arn}"
  }
JSON

}
