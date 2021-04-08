# VPC ID
# ---------------------------------------------------------------------------------------------------------------
#variable "vpc_id" {}


# Decision to create AWS Route 53 Private Hosted Zones
# ---------------------------------------------------------------------------------------------------------------
variable "create_private_hosted_zones_for_endpoints" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type    = bool
  default = true
  validation {
    condition     = (var.create_private_hosted_zones_for_endpoints == true || var.create_private_hosted_zones_for_endpoints == false )
    error_message = "DNS Support flag must be either true or false."
  }
}


# Enable Private DNS
# ---------------------------------------------------------------------------------------------------------------
variable "enable_private_dns" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type    = bool
  default = false
  validation {
    condition     = (var.enable_private_dns == true || var.enable_private_dns == false )
    error_message = "DNS Support flag must be either true or false."
  }
}


# Enable Private Hosted Zones for Interface Endpoints
# ---------------------------------------------------------------------------------------------------------------
variable "enable_private_hosted_zones_for_interface_endpoints" {
  description = "A boolean flag to enable private hosted zones. Defaults true."
  type    = bool
  default = false
  validation {
    condition     = (var.enable_private_dns == true || var.enable_private_dns == false )
    error_message = "DNS Support flag must be either true or false."
  }
}


# VPC Endpoint Object List
# ---------------------------------------------------------------------------------------------------------------
variable "endpoints" {
  type = map(bool)
  default = {
    s3_gateway          = false
    dynamodb            = true
    secrets_manager     = true
    kms                 = true
    ec2                 = true
    ec2_messages        = true
    ecs                 = true
    ecs_agent           = true
    ecs_telemetry       = true
    sts                 = true
    sns                 = true
    sqs                 = true
    ssm                 = true
    ssm_messages        = true
  }
}


# Environment Type
# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "environment_type" {
  type    = string
  default = "Development"
  description = "The environment type that the network is being created for. That is, DEV/PROD/UAT/SANDBOX."
}



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
  default = "100.64.0.0/16"
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
  validation {
    # The condition here identifies if the variable contains one of the AWS Regions specified. This list can be reduced.
    condition = can(regex("us-east-2|us-east-1|us-west-1|us-west-2|af-south-1|ap-east-1|ap-south-1|ap-northeast-3|ap-northeast-2|ap-southeast-1|ap-southeast-2|ap-northeast-1|ca-central-1|eu-central-1|eu-west-1|eu-west-2|eu-south-1|eu-west-3|eu-north-1|me-south-1|sa-east-1", var.aws_region))
    error_message = "Please enter a valid AWS Region."
  }

}

# VPC Flow enablement bool
# ---------------------------------------------------------------------------------------------------------------
variable "enable_vpc_flow_logs" {
  description = "Whether vpc flow log should be enabled for this vpc."
  type    = bool
  default = true
  validation {
    condition     = (var.enable_vpc_flow_logs == true) ||(var.enable_vpc_flow_logs == false)
    error_message = "Please ensure VPC Flow logs is set to true."
  }
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


# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "public_subnets" {
  default = [
    "100.64.8.0/24",
    "100.64.9.0/24",
    "100.64.10.0/24"
  ]

}
