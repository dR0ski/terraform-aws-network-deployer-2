
// data "aws_organizations_organization" "my_aws_organization" {}

locals {
  default = {
    Name              = var.Application_Name
    Business_Unit     = var.Business_Unit
    Cost_Center       = var.CostCenterCode
    CreatedBy         = var.CreatedBy
    Application_ID    = var.Application_ID
    Manager           = var.Manager
    Environment_Type  = var.Environment_Type
  }
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Resource Access Manager | --> Creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ram_resource_share" "resolver_firewall_rules_group_ram_share" {
  count = var.ram_actions.create_resource_share==true ? 1:0
  name                      = var.resolver_dns_firewall_ram_share_name
  allow_external_principals = var.allow_external_principals
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Resource Access Manager | --> Principal Association with Resource Share
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ram_principal_association" "share_principal_association" {
  count = var.ram_actions.create_resource_share==true ? 1:0
  principal          = var.my_principal_arn
  resource_share_arn = aws_ram_resource_share.resolver_firewall_rules_group_ram_share[0].arn
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Route 53 Resolver DNS Firewall  | --> Firewall Config | Aligning Group with VPC
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_firewall_config" "route_53_resolver_" {
  resource_id        = var.vpc_id
  firewall_fail_open = var.firewall_fail_open
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Route 53 Resolver DNS Firewall  | --> Domain List Creation | ---> ALLOW List
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_firewall_domain_list" "route_53_resolver_firewall_domain_allow_list" {
  count = var.action_type.allow==true && var.action_type.deny==false && var.action_type.alert==false ? 1:0
  name = var.domain_list_name
  domains = var.domain_list.allow
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Route 53 Resolver DNS Firewall  | --> Domain List Creation | ---> DENY List
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_firewall_domain_list" "route_53_resolver_firewall_domain_deny_list" {
  count = var.action_type.deny==true && var.action_type.allow==false && var.action_type.alert==false ? 1:0
  name = var.domain_list_name
  domains = var.domain_list.deny
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Route 53 Resolver DNS Firewall  | --> Domain List Creation | ---> ALERT List
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_firewall_domain_list" "route_53_resolver_firewall_domain_alert_list" {
  count = var.action_type.alert==true && var.action_type.allow==false && var.action_type.deny==false ? 1:0
  name = var.domain_list_name
  domains = var.domain_list.alert
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Route 53 Resolver DNS Firewall  | --> Group Creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_firewall_rule_group" "route_53_resolver_firewall_rule_group" {
  name = var.firewall_rule_group
  tags = local.default
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Resource Access Manager | --> Association of DNS Firewall Rules Group with Resource Share
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ram_resource_association" "resolver_firewall_rule_group_ram_share_association" {
  count = var.ram_actions.create_resource_share==true ? 1:0
  resource_arn       = aws_route53_resolver_firewall_rule_group.route_53_resolver_firewall_rule_group.arn
  resource_share_arn = aws_ram_resource_share.resolver_firewall_rules_group_ram_share[0].arn
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Route 53 Resolver DNS Firewall  | -->
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_firewall_rule" "route_53_resolver_firewall_allow_rule" {
  count = var.route_53_resolver_firewall_rule_action=="ALLOW" ? 1:0
  name                    = var.route_53_resolver_firewall_rule_name
  action                  = var.route_53_resolver_firewall_rule_action
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.route_53_resolver_firewall_domain_allow_list[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.route_53_resolver_firewall_rule_group.id
  priority                = var.route_53_resolver_firewall_rule_priority
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Route 53 Resolver DNS Firewall  | -->
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_firewall_rule" "route_53_resolver_firewall_deny_rule" {
  count = var.route_53_resolver_firewall_rule_action=="BLOCK" ? 1:0
  name                    = var.route_53_resolver_firewall_rule_name
  action                  = var.route_53_resolver_firewall_rule_action
  block_override_dns_type = var.route_53_resolver_firewall_rule_block_override_dns_type
  block_override_domain   = var.route_53_resolver_firewall_rule_block_override_domain
  block_override_ttl      = var.route_53_resolver_firewall_rule_block_override_ttl
  block_response          = var.route_53_resolver_firewall_rule_block_response
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.route_53_resolver_firewall_domain_deny_list[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.route_53_resolver_firewall_rule_group.id
  priority                = var.route_53_resolver_firewall_rule_priority
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Route 53 Resolver DNS Firewall  | -->
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_firewall_rule" "route_53_resolver_firewall_alert_rule" {
  count = var.route_53_resolver_firewall_rule_action=="ALERT" ? 1:0
  name                    = var.route_53_resolver_firewall_rule_name
  action                  = var.route_53_resolver_firewall_rule_action
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.route_53_resolver_firewall_domain_alert_list[0].id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.route_53_resolver_firewall_rule_group.id
  priority                = var.route_53_resolver_firewall_rule_priority
}

# ---------------------------------------------------------------------------------------------------------------
# AWS | Route 53 Resolver DNS Firewall  | -->
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route53_resolver_firewall_rule_group_association" "rule_group_association" {
  name                   = var.firewall_rule_group_association_name
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.route_53_resolver_firewall_rule_group.id
  priority               = var.firewall_rule_group_association_priority
  vpc_id                 = var.vpc_id
}