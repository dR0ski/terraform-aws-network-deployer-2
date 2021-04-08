
# VPC Tenancy Bool. There are two tenancy type [default, dedicated]
# ---------------------------------------------------------------------------------------------------------------

variable "instance_tenancy" {
  type    = string
  default = "default"
  validation {
    condition     = var.instance_tenancy == "default" || var.instance_tenancy == "dedicated"
    error_message = "VPC tenancy must be of type default or dedicated."
  }
}

# DNS_Support Bool Variable. This is used in the DHCP Option Set for the VPC
# ---------------------------------------------------------------------------------------------------------------
variable "dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type    = bool
  default = true
  validation {
    condition     = (var.dns_support == true)
    error_message = "DNS Support flag must be either true or false."
  }
}

# DNS_Hostname Bool Variable. This is used in the DHCP Option Set for the VPC
# ---------------------------------------------------------------------------------------------------------------
variable "dns_host_names" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type    = bool
  default = true
  validation {
    condition     = (var.dns_host_names == true)
    error_message = "DNS Hostname flag must be either true or false."
  }
}

# Primary VPC CIDR range that is allocated to the spoke VPC
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_cidr_block" {
  description = "The cidr block allocated to this vpc."
  type    = string
  default = "10.10.0.0/16"
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}($|/(16|17|18|19|20|21|22|23|24|25|26|27|28))$", var.vpc_cidr_block))
    error_message = "Invalid IPv4 CIDR Block."
  }
}

# Enable an AWS provided /56 IPv6 CIDR Block with /64 Subnet Ranges
# ---------------------------------------------------------------------------------------------------------------
variable "enable_aws_ipv6_cidr_block"{
  description = "Enable and add an AWS Provided IPv6 Address block"
  type    = bool
  default = false
  validation {
    condition     = (var.enable_aws_ipv6_cidr_block == false)
    error_message = "IPv6 flag must be false for now."
  }
}

# AWS Region decalration
# ---------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# VPC Flow enablement bool
# ---------------------------------------------------------------------------------------------------------------
variable "enable_vpc_flow_logs" {
  description = "Whether vpc flow log should be enabled for this vpc."
  type    = bool
  default = true
  validation {
    condition     = (var.enable_vpc_flow_logs == true) ||(var.enable_vpc_flow_logs == false)
    error_message = "IPv6 flag must be false for now."
  }
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




# Private Subnet Declaration
# ---------------------------------------------------------------------------------------------------------------
variable "map_public_ip_on_launch" {
  description = "Asssigns an AWS Elastic IP to resources with IPs from this subnet."
  type    = bool
  default = false
  validation {
    condition     = (var.map_public_ip_on_launch == false)
    error_message = "No public IP address should be mapped on launch/deploy/apply. This should always be false."
  }
}

variable "assign_ipv6_address_on_creation" {
  description = "Asssigns an AWS IPv6 Subnet Address Block."
  type    = bool
  default = false
  validation {
    condition     = (var.assign_ipv6_address_on_creation == false)
    error_message = "No IPv6 public IP address should be assigned. This should always be false."
  }
}


variable "environment_type" {
  description = "Envrionment Type"
  type    = string
  default = "Development"

}


variable "subnet_type" {
  type = map(bool)
  default = {
    aws_routable                      = true
    externally_routable               = true
    transit_gateway_subnet            = true
  }
}

# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "private_subnets" {
  default = [
    "100.64.1.0/24",
    "100.64.2.0/24",
    "100.64.3.0/24"/*,
      "100.64.4.0/24",
      "100.64.5.0/24",
      "100.64.6.0/24",
      "100.64.7.0/24"  */
  ]

}


# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "public_subnets" {
  default = [
    "100.64.8.0/24",
    "100.64.9.0/24",
    "100.64.10.0/24"/*,
      "100.64.11.0/24",
      "100.64.12.0/24",
      "100.64.13.0/24",
      "100.64.14.0/24"  */
  ]

}


# Transit Gateway Attachment Subnet
# ---------------------------------------------------------------------------------------------------------------
variable "transit_gateway_subnets" {
  default = [
    "100.64.0.0/28",
    "100.64.0.16/28",
    "100.64.0.32/28"
  ]

}

# Decision to make a subnet a local zone subnet or not
# ---------------------------------------------------------------------------------------------------------------
variable "local_zone_subnet" {
  type = map(bool)
  default = {
    enabled              = false
  }
}





