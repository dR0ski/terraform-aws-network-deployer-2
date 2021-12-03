# ---------------------------------------------------------------------------------------------------------------
# DEPLOYMENT INSTRUCTIONS
# ---------------------------------------------------------------------------------------------------------------
# Before deploying any VPC(s), you are required to pave the account with three infrastructure that will be used to
# orchestrate networking activities within the AWS Region where the VPC(s) is/are needed.
# To pave the account, go to the "pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration" option
# in the variable "which_vpc_type_are_you_creating" and add true.

# Paving the account creates three resources. These are as follows
# ---------------------------------------------------------------------
# 1. AWS EventBridge EventBus: The name of this eventbus begins with "aws-fsf-network-operations-event-bus-"
# 2. AWS Lambda Function that orchestrates and performs networking tasks
# 3. AWS Lambda Function that writes events to the eventbus: The name of this function includes the words "fsf-network-event-writer"

# Make a note of the ARNs. You will need them for STEP 3.


######### STEP 1. ##############
# ---------------------------------------------------------------------------------------------------------------
# SOLUTION BUILD CONTROL | BOOLEAN MAP THAT CONTROLS THE TYPE OF VPC TO DEPLOY
# ---------------------------------------------------------------------------------------------------------------
# The variable "which_vpc_type_are_you_creating" controls if the deployment builds a spoke VPC, shared services VPC
# or paves the account with an eventbus and two lambda functions that performs networking tasks such as:
# A. Transit Gateway route table association and configuration
# B. Automatic association and integration with centralized resources.
# ---------------------------------------------------------------------------------------------------------------
#  # Add true besides the solution you would like to deploy.
#   1. Adding true for shared_services_vpc to deploy a shared services VPC
#   2. Adding true for spoke_vpc deploys a spoke VPC
#   3. Adding true for pave_networking_components_for_spoke_n_shared_services_integration to deploy
#      the eventbus and lambda functions that makes it possible for spoke VPCs to associate with
#      centralized resources inside the shared services VPC or security services VPC.
# ---------------------------------------------------------------------------------------------------------------
variable "which_vpc_type_are_you_creating" {
  type = map(bool)
  default = {
    shared_services_vpc     = false                                                   # Specify true or false
    spoke_vpc               = false                                                   # Specify true or false
    pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration  = false    # Specify true or false
  }
}

######### STEP 2. ##############
# ---------------------------------------------------------------------------------------------------------------
#  AWS TRANSIT GATEWAY IDENTIFIERS | TRANSIT GATEWAY & TRANSIT GATEWAY ROUTE TABLES
# ---------------------------------------------------------------------------------------------------------------
# If this deployment deploys a VPC that should be attached to a transit gateway, then please perform the below tasks
# ---------------------------------------------------------------------------------------------------------------
# 1. Please add the AWS Transit Gateway ID for the transit gateway to which this VPC should be attached
# 2. Please add the AWS Transit Gateway Route Table IDs for the above transit gateway
# ---------------------------------------------------------------------------------------------------------------
variable "transit_gateway_id" {default=""}
variable "transit_gateway_dev_route_table" {default=""}
variable "transit_gateway_uat_route_table" {default=""}
variable "transit_gateway_shared_svc_route_table" {default=""}
variable "transit_gateway_packet_inspection_route_table" {default=""}
variable "transit_gateway_prod_route_table" {default=""}


######### STEP 3. ##############
# ---------------------------------------------------------------------------------------------------------------
#  SHARED SERVICES IDENTIFIERS | TRANSIT GATEWAY & TRANSIT GATEWAY ROUTE TABLES
# ---------------------------------------------------------------------------------------------------------------
# If you are deploying a spoke VPC that should be integrated with the Shared Services VPC, then do the following:
# 1. Enter the Shared Services VPC ID
# 2. Enter the AWS ARN of the lambda function that puts events to the eventbus
# 3. Enter the AWS EventBus ARN that was created by the deployment of "pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration"
#
# If you are deploying a Shared Services VPC, then only enter the "put event" lambda function and the AWS EventBus ARN
# that was created by the deployment of "pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration"
#
# ---------------------------------------------------------------------------------------------------------------
variable "shared_services_vpc_id" {default=""}

variable "shared-services-vpc-network-operations-put-event-lambda-fn-name" {default = ""}

variable "shared_services_network_operations_eventbus_arn" {default = ""}


# ---------------------------------------------------------------------------------------------------------------
#  SPOKE IDENTIFIERS | TRANSIT GATEWAY & TRANSIT GATEWAY ROUTE TABLES
# ---------------------------------------------------------------------------------------------------------------
#
# If you are not deploying a spoke VPC then leave the next two variables blank.
#
# If you are deploying a spoke VPC then please fill in the next two variables.
#
# ---------------------------------------------------------------------------------------------------------------
variable "spoke-vpc-network-operations-put-event-lambda-fn-name" {default=""}

variable "spoke_vpc_network_operations_eventbus_arn" {default=""}


# ---------------------------------------------------------------------------------------------------------------
# NETWORK INTEGRATION ACTIONS |
# ---------------------------------------------------------------------------------------------------------------
#
#
#
#
# ---------------------------------------------------------------------------------------------------------------
######### MUST BE CONFIGURED ##############
variable "transit_gateway_association_instructions" {
  type = map(bool)
  default = {
    create_transit_gateway_association                        = false   # Specify true or false | Associates VPC with AWS Transit Gateway
    access_shared_services_vpc                                = false   # Specify true or false | Propagates VPC routes to Shared Services Route Table
    perform_east_west_packet_inspection                       = false   # Specify true or false | Propagates VPC routes to Packet Inspection Route Table for North-South Packet Inspection
    allow_onprem_access_to_entire_vpc_cidr_range              = false   # Specify true or false | Propagate Routes to On-premises Route Table
    allow_onprem_access_to_externally_routable_vpc_cidr_range = false   # Specify true or false | Propagate Routes to On-premises Route Table
  }
}

# ---------------------------------------------------------------------------------------------------------------
# Route 53 Private Hosted Zone |
# ---------------------------------------------------------------------------------------------------------------
# Controls whether a private hosted zone is created or not. It also controls the creation of route 53 resolver rules.
# ---------------------------------------------------------------------------------------------------------------
######### MUST BE CONFIGURED ##############
variable "route53_acts" {
  type = map(bool)
  default = {
    create_standalone_private_hosted_zone                                       = false  # Specify true or false
    create_private_hosted_zone_that_integrates_with_shared_services_or_dns_vpc  = false  # Specify true or false
    associate_with_dns_vpc_or_a_shared_services_vpc                             = false  # Specify true or false
    associate_with_private_hosted_zone_with_centralized_dns_solution            = false  # Specify true or false
    create_forwarding_rule_for_sub_domain                                       = false # Specify true or false
    create_forwarding_rule_for_domain                                           = false # Specify true or false
    share_forwarding_rule_with_aws_organization                                 = false # Specify true or false
  }
}


# ---------------------------------------------------------------------------------------------------------------
#  AWS ROUTE 53 RESOLVER DNS FIREWALL |
# ---------------------------------------------------------------------------------------------------------------
#
#
#
#
# ---------------------------------------------------------------------------------------------------------------
variable "route_53_resolver_firewall_actions" {
  type = map(bool)
  default = {
    resolver_firewall_resource_share_exists = true
  }
}

variable "route_53_resolver_firewall_group" {
  default = ""
}

variable "route_53_resolver_firewall_rule_group_association_priority"{
  default = 100
}

variable "route_53_resolver_firewall_rule_group_association_name" {
  default = ""
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
#
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
# AWS REGION | REGION CODE MAPPED TO REGION NAME
# ---------------------------------------------------------------------------------------------------------------
variable "aws_region"{
  default = ""
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

variable "vpc_env_type"{
  default="fsf"
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
  default = false # Specify true or false
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
  # default = "100.64.0.0/16"
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
  # default = "example.com"
}


variable "domain_name_servers" {
  default = ["127.0.0.1"]
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


variable "private_hosted_zone_name"{
  type = list(string)
  # default =  ["anaconda.aws-fsf-corp.com"]
}

# ---------------------------------------------------------------------------------------------------------------
########################################### SUBNET MODULE VARIABLES #############################################
# ---------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------
# Private Subnet Declaration
# ---------------------------------------------------------------------------------------------------------------
# DO NOT Make any changes to the below variable. Each option must be set to true and they are.
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
  default = ["127.0.0.1"]
}


# ---------------------------------------------------------------------------------------------------------------
# Map of port and security group attributes required for the creations of the Amazon VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
variable "public_subnets" {
  default = ["127.0.0.1"]
}


# ---------------------------------------------------------------------------------------------------------------
# Transit Gateway Attachment Subnet
# ---------------------------------------------------------------------------------------------------------------
variable "transit_gateway_subnets" {
  default = ["127.0.0.1"]
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

variable "default_deployment_route_configuration" {
  default = false
}

variable "additional_route_deployment_configuration" {
  default = false
}

variable "add_igw_route_to_externally_routable_route_tables" {
  default = false
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


variable "tgw_subnet_route_destination_for_public_nat_deployment"{
  description = "Contains the DEFAULT Route as a Destination IP for the tgw route table"
  default = ["0.0.0.0/0"]
}

variable "tgw_subnet_route_destination_for_private_nat_deployment"{
  description = "Contains the DEFAULT Route as a Destination IP for the tgw route table"
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
  default = [ "172.16.0.0/12", "192.168.0.0/16", "10.0.0.0/8" ]
}

# ---------------------------------------------------------------------------------------------------------------
# Route 53 Resolver DNS Firewall
# ---------------------------------------------------------------------------------------------------------------
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


variable "route_53_resolver_firewall_rule_priority" {
  type = map(number)
  default = {
    allow = 100
    deny  = 101
    alert = 102
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

variable "resolver_dns_firewall_ram_share_name" {default="aws_fsf_resolver_dns_firewall_ram_share"}
variable "allow_external_principals" {default=false}


# ---------------------------------------------------------------------------------------------------------------
#################################################### Internet Gateway ###########################################
# ---------------------------------------------------------------------------------------------------------------
variable "igw_decisions" {
  type = map(bool)
  default = {
    ipv4_internet_gateway = false
    ipv6_internet_gateway = false
  }
}


# ---------------------------------------------------------------------------------------------------------------
##################################################### Centralized NAT ######################################################
# ---------------------------------------------------------------------------------------------------------------
variable "byoip_id" {default = ""}

variable "create_private_nat_gateway" {default = false}

variable "create_public_nat_gateway" {default  = false}

variable "nat_decisions" {
  type = map(bool)
  default = {
    byoip                   = false
    create_internet_gateway = true
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
# ---------------------------------------------------------------------------------------------------------------
##################################################### TAGS ######################################################
# ---------------------------------------------------------------------------------------------------------------
####### MUST CONFIGURE #######
# Variables that makes up the AWS Tags assigned to the VPC on creation.
# ---------------------------------------------------------------------------------------------------------------

variable "Application_ID" {
  description = "The Application ID of the application that will be hosted inside this Amazon VPC."
  type = string
}

variable "Application_Name" {
  description = "The name of the application. Max 10 characters. Allowed characters [0-9A-Za-z]."
  type = string

}

variable "Business_Unit" {
  description = "The business unit or line of business to which this application belongs."
  type = string

}

variable "Environment_Type" {
  description = "The applications environment type. Allowed values are: DEV, UAT, PROD, Shared Services."
  type = string

}

variable "CostCenterCode" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string

}

variable "CreatedBy" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string

}

variable "Manager" {
  description = "CSI Billing Profile Number associated with application to be hosted in this vpc."
  type = string

}
