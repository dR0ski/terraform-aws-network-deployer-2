
data "aws_organizations_organization" "my_aws_organization" {}

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
  principal          = data.aws_organizations_organization.my_aws_organization.arn
  resource_share_arn = aws_ram_resource_share.resolver_firewall_rules_group_ram_share[0].arn
}

