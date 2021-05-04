# VPC ID of the VPC to which this DHCP Option Set should be attached to
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_id" {
  type    = string
}

# Amazon VPC DHCP Option Map: This map allows you to enable the type of DHCP Options to create and associate
# ---------------------------------------------------------------------------------------------------------------
variable "create_dhcp_options" {
  type = map(bool)
  default = {
    dhcp_options          = true
    custom_dhcp_options   = false
  }
}


# AWS Region decalration
# ---------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  type    = string
  validation {
    # The condition here identifies if the variable contains one of the AWS Regions specified. This list can be reduced.
    condition = can(regex("us-east-2|us-east-1|us-west-1|us-west-2|af-south-1|ap-east-1|ap-south-1|ap-northeast-3|ap-northeast-2|ap-southeast-1|ap-southeast-2|ap-northeast-1|ca-central-1|eu-central-1|eu-west-1|eu-west-2|eu-south-1|eu-west-3|eu-north-1|me-south-1|sa-east-1", var.aws_region))
    error_message = "ERROR: Operating System must be Windows OR Linux."
  }

}


# Custom DHCP Options configuration parameters.
# ---------------------------------------------------------------------------------------------------------------
# (Optional) the suffix domain name to use by default when resolving non Fully Qualified Domain Names.
# In other words, this is what ends up being the search value in the /etc/resolv.conf file.
# Domain for Amazon Provided DNS 
variable "custom_domain_name" {
    default = "example.com"
    }


variable "domain_name_servers" { 
   default = ["127.0.0.1", "10.0.0.2"]
}

variable "ntp_servers" {
    default = ["127.0.0.1"]
    }


variable "netbios_name_servers" {
    default = ["127.0.0.1"]
    }


variable "netbios_node_type" {
    default = 2
    }


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
  default = "AWS_FSF_ARTIFACTS"
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