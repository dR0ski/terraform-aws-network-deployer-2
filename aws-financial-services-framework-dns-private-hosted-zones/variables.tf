# ---------------------------------------------------------------------------------------------------------------
##################################################### VARIABLES ######################################################
# ---------------------------------------------------------------------------------------------------------------

variable "vpc_id"{}

variable "vpc_region"{}

variable "eventbus_arn"{default=""}

variable "resolver_query_logging_destination"{default=""}

variable "shared_services_vpc_id"{default=""}

variable "vpc_type"{default="spoke"}

variable "private_hosted_zone_name"{
 type = list(string)
  default =  ["anaconda.aws-fsf-corp.com"]
}

variable "external_security_id"{
  default = "a"
}

variable "externally_routable_subnet_id"{
  type = list(string)
  default = ["a","b"]
}

variable "route53_association_lambda_fn_name" {default = "X"}

variable "rule_type" {
  type    = string
  description = "The AWS Route 53 resolver rule type can either be FORWARD|SYSTEM|RECURSIVE."
  validation {
    # The condition here identifies if the variable contains one of the AWS Regions specified. This list can be reduced.
    condition = can(regex("FORWARD|SYSTEM|RECURSIVE", var.rule_type))
    error_message = "Please enter a valid AWS Route 53 resolver rule type."
  }
}

variable "route53_acts" {
  type = map(bool)
  default = {
    create_standalone_private_hosted_zone                                       = true  # Specify true or false
    create_private_hosted_zone_that_integrates_with_shared_services_or_dns_vpc  = false  # Specify true or false
    associate_with_dns_vpc_or_a_shared_services_vpc                             = false  # Specify true or false
    associate_with_private_hosted_zone_with_centralized_dns_solution            = false  # Specify true or false
    create_forwarding_rule_for_sub_domain                                       = false # Specify true or false
    create_forwarding_rule_for_domain                                           = false # Specify true or false
    share_forwarding_rule_with_aws_organization                                 = false # Specify true or false
  }
}

variable "attach_to_centralize_dns_solution"{
  default=true
}



# ---------------------------------------------------------------------------------------------------------------
##################################################### TAGS ######################################################
# ---------------------------------------------------------------------------------------------------------------

# Variables that makes up the AWS Tags assigned to the VPC on creation.
# ---------------------------------------------------------------------------------------------------------------

variable "Application_ID" {
  description = "The Application ID of the application that will be hosted inside this Amazon VPC."
  type = string
  default = "0000000"
}

variable "Application_Name" {
  description = "The name of the application. Max 10 characters. Allowed characters [0-9A-Za-z]."
  type = string
  default = "fsf-spoke-vpc"
}

variable "Business_Unit" {
  description = "The business unit or line of business to which this application belongs."
  type = string
  default = "Commercial Banking (CB)"
}

variable "Environment_Type" {
  description = "The applications environment type. Possible values: LAB, SandBox, DEV, UAT, PROD."
  type = string
  default = "DEV"
}

variable "CostCenterCode" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "CB-0000000"
}

variable "CreatedBy" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "Androski_Spicer"
}

variable "Manager" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string
  default = "KenJackson"
}

