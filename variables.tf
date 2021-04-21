# ---------------------------------------------------------------------------------------------------------------
# SOLUTION BUILD CONTROL | BOOLEAN MAP THAT CONTROLS THE TYPE OF VPC TO DEPLOY
# ---------------------------------------------------------------------------------------------------------------
# Add true besides the solution you would like to deploy.
#   1. Adding true for shared_services_vpc to deploy a shared services VPC
#   2. Adding true for spoke_vpc deploys a spoke VPC
#   3. Adding true for pave_networking_components_for_spoke_n_shared_services_integration to deploy
#      the eventbus and lambda functions that makes it possible for spoke VPCs to associate with
#      centralized resources inside the shared services VPC or security services VPC.
# ---------------------------------------------------------------------------------------------------------------

######### MUST BE CONFIGURED ##############
variable "which_vpc_type_are_you_creating" {
  type = map(bool)
  default = {
    shared_services_vpc     = false    # Specify true or false
    spoke_vpc               = false    # Specify true or false
    # pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration  = true    # Specify true or false
  }
}

# ---------------------------------------------------------------------------------------------------------------
#  Terraform Backend Configuration for AWS Transit Gateway  |
# ---------------------------------------------------------------------------------------------------------------
variable "tf_backend_s3_bucket_aws_region"{
  default = "us-east-2"
  # Please fill in the aws S3 region where the bucket is being hosted
}

variable "tf_backend_s3_bucket_name"{
  default = "abc-s3-bucket"
  # Please fill in the aws S3 bucket name that you are using to store terraform state for your shared services
}


variable "tf_backend_state_file_s3_prefixpath_n_key_name"{
  default = "abc-transit-gateway-s3-prefix-n-key"
  # The S3 key or prefix+key for the terraform state file
}

# ---------------------------------------------------------------------------------------------------------------
# Shared Services State Persistence Configuration |
# ---------------------------------------------------------------------------------------------------------------
# This Terraform Backend is configured for Amazon S3 by default; however, you can replace this default config
# and replace it with yours.
# ---------------------------------------------------------------------------------------------------------------
variable "tf_shared_services_backend_s3_bucket_aws_region"{
  default = "us-east-2"
  # Please fill in the aws S3 region where the bucket is being hosted
}

variable "tf_shared_services_backend_s3_bucket_name"{
  default = "abc-s3-bucket"
  # Please fill in the aws S3 bucket name that you are using to store terraform state for your shared services
}

variable "tf_shared_services_backend_state_file_s3_prefixpath_n_key_name"{
  default = "abc-shared-services-prefix-n-key"
  # The S3 key or prefix+key for the terraform state file
}


# ---------------------------------------------------------------------------------------------------------------
# Transit Gateway Association Task Map
# ---------------------------------------------------------------------------------------------------------------
######### MUST BE CONFIGURED ##############
variable "transit_gateway_association_instructions" {
  type = map(bool)
  default = {
    create_transit_gateway_association                        = false   # true //Associates VPC with AWS Transit Gateway
    access_shared_services_vpc                                = false   # true //Propagates VPC routes to Shared Services Route Table
    perform_east_west_packet_inspection                       = false   # Specify true or false
    allow_onprem_access_to_entire_vpc_cidr_range              = false   # Specify true or false
    allow_onprem_access_to_externally_routable_vpc_cidr_range = false   # Specify true or false

  }
}


# ---------------------------------------------------------------------------------------------------------------
# AWS VPC SECURITY GROUP | Decision Map | Adding true creates the security that you want
# ---------------------------------------------------------------------------------------------------------------
#   ####### Only enable the security that is needed
# ---------------------------------------------------------------------------------------------------------------
######### MUST BE CONFIGURED ##############
variable "security_grp_traffic_pattern" {
  type = map(bool)
  default = {
    database                = true  # Specify true or false
    web                     = true  # Specify true or false
    kafka_zookeeper         = false # Specify true or false
    elasticsearch           = false # Specify true or false
    apache_spark            = false # Specify true or false
  }
}

# ---------------------------------------------------------------------------------------------------------------
# VPC ENDPOINTS
# ---------------------------------------------------------------------------------------------------------------
# VPC Endpoint Boolean Map
# ---------------------------------------------------------------------------------------------------------------
######### MUST BE CONFIGURED IF YOU ARE DEPLOYING A STAND ALONE SPOKE VPC. ##############
#########        DO NOT CONFIGURE IF DEPLOYING A SHARED SERVICES VPC     ##############
# ---------------------------------------------------------------------------------------------------------------
variable "endpoints" {
  type = map(bool)
  default = {
    s3_gateway          = true  # Specify true or false
    dynamodb            = true  # Specify true or false
    secrets_manager     = false # Specify true or false
    kms                 = false # Specify true or false
    ec2                 = false # Specify true or false
    ec2_messages        = false # Specify true or false
    ecs                 = false # Specify true or false
    ecs_agent           = false # Specify true or false
    ecs_telemetry       = false # Specify true or false
    sts                 = false # Specify true or false
    sns                 = false # Specify true or false
    sqs                 = false # Specify true or false
    ssm                 = false # Specify true or false
    ssm_messages        = false # Specify true or false
  }
}

# ---------------------------------------------------------------------------------------------------------------
# Route 53 Private Hosted Zone |
# Controls whether a private hosted zone is created or not. It also controls the creation of route 53 resolver rules.
# ---------------------------------------------------------------------------------------------------------------
######### MUST BE CONFIGURED ##############
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


variable "vpc_env_type"{
  default="fsf"
}


# ---------------------------------------------------------------------------------------------------------------
# AWS REGION | REGION CODE MAPPED TO REGION NAME
# ---------------------------------------------------------------------------------------------------------------
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
    south_africa      = "af-south-1"
    hong_kong         = "ap-east-1"
    mumbai            = "ap-south-1"
    osaka_local       = "ap-northeast-3"
    seoul             = "ap-northeast-2"
    singapore         = "ap-southeast-1"
    sydney            = "ap-southeast-2"
    tokyo             = "ap-northeast-1"
    frankfurt         = "eu-central-1"
    milan             = "eu-south-1"
    paris             = "eu-west-3"
    stockholm         = "eu-north-1"
    middle_east       = "me-south-1"
    sao_paulo         = "sa-east-1"
  }
}


variable "rule_type" {
  type    = string
  description = "The AWS Route 53 resolver rule type can either be FORWARD|SYSTEM|RECURSIVE."
  default = "FORWARD"
  validation {
    # The condition here identifies if the variable contains one of the AWS Regions specified. This list can be reduced.
    condition = can(regex("FORWARD|SYSTEM|RECURSIVE", var.rule_type))
    error_message = "Please enter a valid AWS Route 53 resolver rule type."
  }
}

# ---------------------------------------------------------------------------------------------------------------
#  Controls Resource Deployment for VPC TYPES
# ---------------------------------------------------------------------------------------------------------------

# VPC TYPE
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_type" {
  type = map(bool)
  default = {
    spoke_vpc               = true  # Specify true or false
    shared_services         = false # Specify true or false
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
    is_centralized_interface_endpoints          = false # Specify true or false
    associate_with_private_hosted_zones         = false # Specify true or false
  }
}


variable "attach_to_centralize_dns_solution"{
  default= false # Specify true or false
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
    dhcp_options          = true  # Specify true or false
    custom_dhcp_options   = false # Specify true or false
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
########################################### SUBNET MODULE VARIABLES #############################################
# ---------------------------------------------------------------------------------------------------------------



# Private Subnet Declaration
# ---------------------------------------------------------------------------------------------------------------

variable "subnet_type" {
  type = map(bool)
  default = {
    aws_routable                      = true # Specify true or false
    externally_routable               = true # Specify true or false
    transit_gateway_subnet            = true # Specify true or false
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
    aws_routable_table          = true  # Specify true or false
    tgw_table                   = false # Specify true or false
    external_table              = true  # Specify true or false
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
  default = false
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
