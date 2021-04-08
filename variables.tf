variable "aws_region"{
  type = map(string)
  default = {
    n_virginia        = "us-east-1"
    ohio              = "us-east-2"
    n_california      = "us-west-1"
    oregon            = "us-west-2"
    canada_montreal   = "ca-central-1"
    ireland           = "eu-west-1"
    london            = "eu-west-2"
    paris             = "eu-west-3"

  }
}

variable "vpc_env_type"{default="spoke"}

variable "route53_acts" {
  type = map(bool)
  default = {
    create_forwarding_rule_for_sub_domain       = false
    create_forwarding_rule_for_domain           = true
    share_forwarding_rule_with_aws_organization = true
  }
}


variable "attach_to_centralize_dns_solution"{
  default=true
}


######### MUST BE CONFIGURED ##############
# ---------------------------------------------------------------------------------------------------------------
#  Terraform Backend Configuration for AWS Transit Gateway  |
# ---------------------------------------------------------------------------------------------------------------

variable "tf_backend_s3_bucket_aws_region"{
  default = "" # Please fill in the aws S3 region where the bucket is being hosted
}

variable "tf_backend_s3_bucket_name"{
  default = "" # Please fill in the aws S3 bucket name that you are using to store terraform state for your shared services
}


variable "tf_backend_state_file_s3_prefixpath_n_key_name"{
  default = "" # The S3 key or prefix+key for the terraform state file
}


# ---------------------------------------------------------------------------------------------------------------
# Shared Services State Persistence Configuration |
# ---------------------------------------------------------------------------------------------------------------
# This Terraform Backend is configured for Amazon S3 by default; however, you can replace this default config
# and replace it with yours.
# ---------------------------------------------------------------------------------------------------------------

variable "tf_shared_services_backend_s3_bucket_aws_region"{
  default = "" # Please fill in the aws S3 region where the bucket is being hosted
}

variable "tf_shared_services_backend_s3_bucket_name"{
  default = "" # Please fill in the aws S3 bucket name that you are using to store terraform state for your shared services
}

variable "tf_shared_services_backend_state_file_s3_prefixpath_n_key_name"{
  default = "" # The S3 key or prefix+key for the terraform state file
}


# ---------------------------------------------------------------------------------------------------------------
#  Controls Resource Deployment for VPC TYPES
# ---------------------------------------------------------------------------------------------------------------

# VPC TYPE
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_type" {
  type = map(bool)
  default = {
    spoke_vpc               = true
    shared_services         = false
  }
}


variable "vpc_type_string" {
  type = map(string)
  default = {
    spoke-vpc               = "spoke-vpc"
    shared-services         = "shared-services-vpc"

  }
}


# Decision to make associate with centralized Route53 Private Hosted Zone
# ---------------------------------------------------------------------------------------------------------------
variable "is_centralize_interface_endpoints_available" {
  type = map(bool)
  default = {
    is_centralized_interface_endpoints          = false
    associate_with_private_hosted_zones         = false
  }
}



variable "aws_region_names" {
  type = map(string)
  default = {
    us-east-1     = "n_virginia"
    us-east-2     = "ohio"
    us-west-1     = "n_california"
    us-west-2     = "oregon"
    ca-central-1  = "canada_montreal"
    eu-west-1     = "ireland"
    eu-west-2     = "london"
    eu-west-3     = "paris"
  }
}


# ---------------------------------------------------------------------------------------------------------------
################################################## VPC VARIABLES ################################################
# ---------------------------------------------------------------------------------------------------------------

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

# VPC Flow enablement bool
# ---------------------------------------------------------------------------------------------------------------
variable "enable_vpc_flow_logs" {
  description = "Whether vpc flow log should be enabled for this vpc."
  type    = bool
  default = true
  validation {
    condition     = (var.enable_vpc_flow_logs == true)
    error_message = "VPC Flowlogs must be enabled. Therefore, enable_vpc_flow_logs must be set to true."
  }
}

# ---------------------------------------------------------------------------------------------------------------
############################################### DHCP MODULE VARIBLES ############################################
# ---------------------------------------------------------------------------------------------------------------

# Amazon VPC DHCP Option Map: This map allows you to enable the type of DHCP Options to create and associate
# ---------------------------------------------------------------------------------------------------------------
variable "create_dhcp_options" {
  type = map(bool)
  default = {
    dhcp_options          = true
    custom_dhcp_options   = false
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


# ---------------------------------------------------------------------------------------------------------------
################################### TRANSIT GATEWAY ASSOCIATION VARIBLES ########################################
# ---------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------
# Transit Gateway Association Task Map
# ---------------------------------------------------------------------------------------------------------------
variable "transit_gateway_association_instructions" {
  type = map(bool)
  default = {
    create_transit_gateway_association                        = true //Associates VPC with AWS Transit Gateway
    access_shared_services_vpc                                = true //Propagates VPC routes to Shared Services Route Table
    perform_east_west_packet_inspection                       = false
    allow_onprem_access_to_entire_vpc_cidr_range              = false
    allow_onprem_access_to_externally_routable_vpc_cidr_range = false

  }
}


# ---------------------------------------------------------------------------------------------------------------
########################################### SUBNET MODULE VARIABLES #############################################
# ---------------------------------------------------------------------------------------------------------------



# Private Subnet Declaration
# ---------------------------------------------------------------------------------------------------------------

variable "subnet_type" {
  type = map(bool)
  default = {
    aws_routable                      = true
    externally_routable               = true
    transit_gateway_subnet            = true
  }
}



# ---------------------------------------------------------------------------------------------------------------
# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "private_subnets" {
  default = [
    "100.64.1.0/24",
    "100.64.2.0/24",
    "100.64.3.0/24"
  ]
}


# ---------------------------------------------------------------------------------------------------------------
# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "public_subnets" {
  default = [
    "100.64.8.0/24",
    "100.64.9.0/24",
    "100.64.10.0/24"
  ]
}


# ---------------------------------------------------------------------------------------------------------------
# Transit Gateway Attachment Subnet
# ---------------------------------------------------------------------------------------------------------------
variable "transit_gateway_subnets" {
  default = [
    "100.64.0.0/28",
    "100.64.0.16/28",
    "100.64.0.32/28"
  ]
}


# ---------------------------------------------------------------------------------------------------------------
# Module: AWS-FSF-ADD-ROUTE
# ---------------------------------------------------------------------------------------------------------------

# Bool Map that controls the addition of routes with the AWS Transit Gateway as the next hop infrastructure
# ---------------------------------------------------------------------------------------------------------------
variable "route_table" {
  type = map(bool)
  default = {
    aws_routable_table          = true
    tgw_table                   = false
    external_table              = true
  }
}


variable "next_hop_infra" {
  type = map(bool)
  default = {
    tgw   = true
  }
}


# TGW Destination CIDR Block
# ---------------------------------------------------------------------------------------------------------------
variable "tgw_aws_route_destination"{
  description = "Holds the ID of the route table for aws_routable subbnetss"
  default = ["0.0.0.0/0"]

}


variable "tgw_external_route_destination"{
  description = "Holds the ID of the route table for aws_routable subbnetss"
  default = ["0.0.0.0/0"]

}

# Not used in this module
# ---------------------------------------------------------------------------------------------------------------
variable "tgw_route_destination"{
  description = "Holds the ID of the route table for aws_routable subbnetss"
  default = ["0.0.0.0/0"]

}


# ---------------------------------------------------------------------------------------------------------------
# VPC ENDPOINTS
# ---------------------------------------------------------------------------------------------------------------

# VPC Endpoint Object List
# ---------------------------------------------------------------------------------------------------------------
variable "endpoints" {
  type = map(bool)
  default = {
    s3_gateway          = true
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


# Decision to create AWS Route 53 Private Hosted Zones
# ---------------------------------------------------------------------------------------------------------------
variable "create_private_hosted_zones_for_endpoints" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type    = bool
  default = false
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
  default = true
  validation {
    condition     = (var.enable_private_dns == true || var.enable_private_dns == false )
    error_message = "DNS Support flag must be either true or false."
  }
}


# ---------------------------------------------------------------------------------------------------------------
# VPC SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------

# On-premises IP Range to be added to the spoke VPC security group
# ---------------------------------------------------------------------------------------------------------------

variable "on_premises_cidrs" {
  description = "On-premises or non VPC network range"
  type    = list(string)
  default = [ "172.16.0.0/16", "172.17.0.0/16", "172.18.0.0/16", "172.19.0.0/16", "172.20.0.0/16", "172.22.0.0/16" ]
}

variable "security_grp_traffic_pattern" {
  type = map(bool)
  default = {
    database                = true
    web                     = true
    kafka_zookeeper         = false
    elasticsearch           = false
    apache_spark            = false

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