# ---------------------------------------------------------------------------------------------------------------
##################################################### VARIABLES ######################################################
# ---------------------------------------------------------------------------------------------------------------

variable "vpc_id"{}

variable "vpc_type"{default="spoke"}

variable "vpc_region"{}

variable "eventbus_arn"{}


variable "private_hosted_zone_id"{}


variable "external_security_id"{
  default = "a"
}


variable "externally_routable_subnet_id"{
  type = list(string)
  default = ["a","b"]
}

variable "route53_acts" {
  type = map(bool)
  default = {
    create_forwarding_rule_for_sub_domain       = false
    create_forwarding_rule_for_domain           = true
    share_forwarding_rule_with_aws_organization = true
  }
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

variable "api_x_key" {
  default = "eInSTeInXtHe0rY7rEltiv!ty"
}

