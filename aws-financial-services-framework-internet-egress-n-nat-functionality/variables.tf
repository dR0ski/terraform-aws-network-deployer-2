variable "vpc_id" {default = ""}
variable "byoip_id" {default = ""}
variable "subnet_id" {default = ["",""]}

variable "nat_decisions" {
  type = map(bool)
  default = {
    byoip                   = false
    create_eip              = true
    create_nat_gateway      = true
  }
}

variable "nat_gateway_connectivity_type" {
  type = map(bool)
  default = {
    public = true
    private = false
  }
}


variable "number_of_azs_to_deploy_to" {
  type = number
  default = 2
  validation {
    condition     = var.number_of_azs_to_deploy_to >=2
    error_message = "A minimum of two AZs are required and as a result two subnet IDs and EIPs. Please correct to a number of two or greaters."
  }
}

variable "create_private_nat_gateway" {default = false}

variable "create_public_nat_gateway" {default  = false}

# ---------------------------------------------------------------------------------------------------------------
##################################################### TAGS ######################################################
# ---------------------------------------------------------------------------------------------------------------
####### MUST CONFIGURE #######
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
