# ---------------------------------------------------------------------------------------------------------------
# VPC ID
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_id" {}


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
  validation {
    # The condition here identifies if the variable contains one of the AWS Regions specified. This list can be reduced.
    condition = can(regex("Development|dev|DEVELOPMENT|development|DEV|UAT|User Acceptance Testing|TEST|Production|PROD|PRODUCTION|SANDBOX|SandBox|Sandbox|Sand-box|Sand-Box|Shared Services|SHARED SERVICES|SHARED-SERVICES|Shared-Services|shared services|shared-services|shared_services|SHARED_SERVICES|Shared_Services|packet_inspection|packet inspection|packet-inspection|Packet Inspection|Packet-inspection|Packet-Inspection|Packet_Inspection|PACKET INSPECTION", var.environment_type))
    error_message = "Please enter a valid environment type."
  }
  
}


variable "subnet_type" {
  type = map(bool)
  default = {
    aws_routable                      = true
    externally_routable               = true
    transit_gateway_subnet            = true
  }
}


# ---------------------------------------------------------------------------------------------------------------
# Transit Gateway Association Task Map
# ---------------------------------------------------------------------------------------------------------------
variable "transit_gateway_association_instructions" {
  type = map(bool)
  default = {
    create_transit_gateway_association                        = false
    access_shared_services_vpc                                = false
    perform_east_west_packet_inspection                       = false
    allow_onprem_access_to_entire_vpc_cidr_range              = false
    allow_onprem_access_to_externally_routable_vpc_cidr_range = false

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
# Decision to make a subnet a local zone subnet or not 
# ---------------------------------------------------------------------------------------------------------------
variable "local_zone_subnet" {
  type = map(bool)
  default = {
    enabled              = false
  }
}


# ---------------------------------------------------------------------------------------------------------------
# Module: AWS-FSF-ADD-ROUTE
# ---------------------------------------------------------------------------------------------------------------

# Bool Map that controls the addition of routes with the AWS Transit Gateway as the next hop infrastructure
# ---------------------------------------------------------------------------------------------------------------
variable "route_table" {
  type = map(bool)
  default = {
    aws_routable_table          = false
    tgw_table                   = false
    external_table              = false
  }
}


variable "next_hop_infra" {
  type = map(bool)
  default = {
    tgw   = true
  }
}


# VPC Route Table ID 
# ---------------------------------------------------------------------------------------------------------------
variable "aws_route_table_id"{
    description = "Holds the ID of the route table for aws_routable subbnetss"
    type = string
    default = "aws_route_table_id"

}

variable "external_route_table_id"{
    description = "Holds the ID of the route table for aws_routable subbnetss"
    type = string
    default = "external_oute_table_id"

}

# Not used in this module 
# ---------------------------------------------------------------------------------------------------------------

variable "tgw_route_table_id"{
    description = "Holds the ID of the route table for the TGW route table "
    type = string
    default = "tgw_route_table_id"

}

# Next Hop Infrastructure ID
# ---------------------------------------------------------------------------------------------------------------
variable "tgw_nexthopinfra_id"{
    description = "Holds the ID of the route table for aws_routable subbnetss"
    type = string
    default = "tgw-xyz"

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

