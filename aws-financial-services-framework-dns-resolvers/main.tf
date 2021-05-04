##########################################################################################
# This module creates the following:
# | > Inbound Endpoint for AWS Route 53 Resolvers
# | > Outbound Endpoint for AWS Route 53 Resolvers
##########################################################################################

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
# AWS SSM Parameter | Holds a dictionary of all resolver rules that has been created
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ssm_parameter" "route53_resolver_rules" {
  name  = "fsf_route53_resolver_rules_dict"
  type  = "String"
  value = "0"
  tags = local.default_tags
}

# ---------------------------------------------------------------------------------------------------------------
# Inbound Resolver Endpoint | Creates the ENIs for these endpoints
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_endpoint" "inbound_resolver" {
  name = var.Environment_Type
  direction = "INBOUND"
  tags = local.default_tags
  security_group_ids = [var.external_security_id]

    dynamic "ip_address" {
      for_each = var.externally_routable_subnet_id
      iterator = inbound_grps
      content {
        subnet_id = inbound_grps.value

      } # closes contents
    } ##closes dynamic block

}


# ---------------------------------------------------------------------------------------------------------------
# Outbound Resolver Endpoint | Creates the ENIs for these endpoints
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_endpoint" "outbound_resolver" {
  name = var.Environment_Type
  direction = "OUTBOUND"
  tags = local.default_tags
  security_group_ids = [var.external_security_id]

  dynamic "ip_address" {
    for_each = var.externally_routable_subnet_id
    iterator = inbound_grps
    content {
      subnet_id = inbound_grps.value

    } # closes contents
  } ##closes dynamic block

}


# ---------------------------------------------------------------------------------------------------------------
# Route 53 Resolver Query Logs | Enable Logging for Route 53 Resolver
# ---------------------------------------------------------------------------------------------------------------
//resource "aws_route53_resolver_query_log_config" "aws_route53_resolver_query_logs" {
//  name              = "aws-fsf-route-53-resolver-query-logging"
//  destination_arn   = var.resolver_query_logging_destination
//  tags              = local.default_tags
//}

