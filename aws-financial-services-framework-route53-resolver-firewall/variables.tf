variable "vpc_id" {default = ""}
variable "firewall_fail_open" {default = ""}
variable "domain_list_name" {default = ""}
variable "firewall_rule_group" {default = ""}
variable "route_53_resolver_firewall_rule_name" {default = ""}
variable "route_53_resolver_firewall_rule_block_override_dns_type" {default = ""}
variable "route_53_resolver_firewall_rule_block_override_domain" {default = ""}
variable "route_53_resolver_firewall_rule_block_override_ttl" {default = 1}
variable "route_53_resolver_firewall_rule_block_response" {default = ""}
variable "firewall_rule_group_association_priority" {default = 100}
variable "firewall_rule_group_association_name" {default = ""}
variable "resource_share_arn" {default = ""}

variable "route_53_resolver_firewall_rule_priority" {
  type = map(number)
  default = {
    allow = 100
    deny  = 101
    alert = 102
  }
}

variable "route_53_resolver_firewall_rule_action" {
  type = map(string)
  default = {
    allow = "ALLOW"
    deny  = "BLOCK"
    alert = "ALERT"
  }
}

variable "domain_list" {
  type = map(list(string))
  default = {
    allow = [""]
    deny  = [""]
    alert = [""]
  }
}

variable "action_type" {
  type = map(bool)
  default = {
    allow = false
    deny  = false
    alert = false
  }
}

variable "ram_actions" {
  type = map(bool)
  default = {
    create_resource_share = false
  }
}

# ---------------------------------------------------------------------------------------------------------------
# Variables that makes up the AWS Tags assigned to the VPC on creation.
# ---------------------------------------------------------------------------------------------------------------
variable "Application_ID" {
  description = "The Application ID of the application that will be hosted inside this Amazon VPC."
  type = string
  default = "please_add_this_info"
}

variable "Application_Name" {
  description = "The name of the application. Max 10 characters. Allowed characters [0-9A-Za-z]."
  type = string
  default = "please_add_this_info"
}

variable "Business_Unit" {
  description = "The business unit or line of business to which this application belongs."
  type = string
  default = "please_add_this_info"
}

variable "Environment_Type" {
  description = "The applications environment type. Possible values: LAB, SandBox, DEV, UAT, PROD."
  type = string
  default = "DEV"
}

variable "CostCenterCode" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "CB_0000000"
}

variable "CreatedBy" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "Androski_Spicer"
}

variable "Manager" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "please_add_this_info"
}

# ---------------------------------------------------------------------------------------------------------------



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