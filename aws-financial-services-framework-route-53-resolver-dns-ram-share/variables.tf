variable "vpc_id" {default = ""}
variable "firewall_fail_open" {default = ""}
variable "domain_list_name" {default = ["",""]}
variable "firewall_rule_group" {default = ""}
variable "route_53_resolver_firewall_rule_name" {default = ""}
variable "route_53_resolver_firewall_rule_action" {default = ""}
variable "route_53_resolver_firewall_rule_block_override_dns_type" {default = ""}
variable "route_53_resolver_firewall_rule_block_override_domain" {default = ""}
variable "route_53_resolver_firewall_rule_block_override_ttl" {default = 1}
variable "route_53_resolver_firewall_rule_block_response" {default = ""}
variable "route_53_resolver_firewall_rule_priority" {default = 100}
variable "firewall_rule_group_association_priority" {default = 100}
variable "firewall_rule_group_association_name" {default = ""}
variable "my_principal_arn" {default=""}
variable "resolver_dns_firewall_ram_share_name" {default="resolver_dns_firewall_ram_share"}
variable "allow_external_principals" {default=false}

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
    allow = true
    deny  = false
    alert = false
  }
}

variable "ram_actions" {
  type = map(bool)
  default = {
    create_resource_share = true
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
