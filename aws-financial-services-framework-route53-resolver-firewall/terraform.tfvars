# --------------------------------------------------------------------------------------------------------------------
# Resolver DNS Firewall | <  Variables  >
# --------------------------------------------------------------------------------------------------------------------
vpc_id                                                            = "vpc-0ce10ea50ab2df5d2"
firewall_fail_open                                                = "DISABLED"
domain_list_name                                                  = "aws-fsf-resolver-fire-wall-domain-list"
firewall_rule_group                                               = "aws-fsf-resolver-fire-wall-rule-group"
route_53_resolver_firewall_rule_name                              = "aws-fsf-resolver-fire-wall-rule"
route_53_resolver_firewall_rule_block_override_dns_type           = "CNAME"       # Required if block_response is OVERRIDE
route_53_resolver_firewall_rule_block_override_domain             = "xyz.com"     # Required if block_response is OVERRIDE
route_53_resolver_firewall_rule_block_override_ttl                = 600           # Required if block_response is OVERRIDE
route_53_resolver_firewall_rule_block_response                    = "OVERRIDE"    # Required if action is BLOCK
firewall_rule_group_association_priority                          = 101           # Required - Provide a num <> "100" and "9900"
firewall_rule_group_association_name                              = "aws-fsf-resolver-fire-wall-rule-group-association"
resource_share_arn                                                = "arn:aws:ram:us-west-2:900095077793:resource-share/de0d95e0-7b89-4ad4-8f82-ec74a6d8a263"
# --------------------------------------------------------------------------------------------------------------------
# Resolver DNS Firewall | Orchestration Object
# --------------------------------------------------------------------------------------------------------------------
domain_list                                                       = { allow = ["facebook.com"]
                                                                      deny  = ["facebook.com"]
                                                                      alert = ["facebook.com"] }


action_type                                                       = { allow   = true
                                                                      deny    = true
                                                                      alert   = true }

ram_actions                                                       = { create_resource_share = true }

route_53_resolver_firewall_rule_priority                          = { allow = 0
                                                                      deny  = 1
                                                                      alert = 2
                                                                    }

# --------------------------------------------------------------------------------------------------------------------
# TAGS
# --------------------------------------------------------------------------------------------------------------------
Application_ID                                                    = "please_add_this_info"
Application_Name                                                  = "please_add_this_info"
Business_Unit                                                     = "please_add_this_info"
Environment_Type                                                  = "DEV"
CostCenterCode                                                    = "CB_0000000"
CreatedBy                                                         = "Androski_Spicer"
Manager                                                           = "please_add_this_info"

# --------------------------------------------------------------------------------------------------------------------
#
# --------------------------------------------------------------------------------------------------------------------




/*
name - (Required)
  A name that lets you identify the rule, to manage and use it.

action - (Required)
  - The action that DNS Firewall should take on a DNS query when it matches one of the domains in the rule's domain list.
  - Valid values: ALLOW, BLOCK, ALERT.

block_override_dns_type - (Required if block_response is OVERRIDE)
  - The DNS record's type. This determines the format of the record value that you provided in BlockOverrideDomain.
  - Value values: CNAME.

block_override_domain - (Required if block_response is OVERRIDE)
  - The custom DNS record to send back in response to the query.

block_override_ttl - (Required if block_response is OVERRIDE)
  - The recommended amount of time, in seconds, for the DNS resolver or web browser to cache the provided override record.
  - Minimum value of 0. Maximum value of 604800.

block_response - (Required if action is BLOCK)
  - The way that you want DNS Firewall to block the request. Valid values: NODATA, NXDOMAIN, OVERRIDE.

priority - (Required)
  - The setting that determines the processing order of the rule in the rule group.
  - DNS Firewall processes the rules in a rule group by order of priority, starting from the lowest setting.

firewall_fail_open - (Required)
  - Determines how Route 53 Resolver handles queries during failures,
  - for example when all traffic that is sent to DNS Firewall fails to receive a reply.
  - By default, fail open is disabled, which means the failure mode is closed.
  - This approach favors security over availability. DNS Firewall blocks queries that it is unable to evaluate properly.
  - If you enable this option, the failure mode is open. This approach favors availability over security.
  - DNS Firewall allows queries to proceed if it is unable to properly evaluate them. Valid values: ENABLED, DISABLED.


*/