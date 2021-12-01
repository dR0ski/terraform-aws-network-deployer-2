# ---------------------------------------------------------------------------------------------------------------
# Map of route table decision
# ---------------------------------------------------------------------------------------------------------------
variable "route_table" {
  type = map(bool)
  default = {
    aws_routable_table          = true
    tgw_table                   = true
    external_table              = true
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
  default=false
}

variable "create_private_nat_gateway" {default = false}

variable "create_public_nat_gateway" {default  = false}

# VPC Route Table ID 
# ---------------------------------------------------------------------------------------------------------------
variable "aws_route_table_id"{
    description = "Holds the ID of the route table for aws_routable subbnets"
    type = string
    default = "aws_route_table_id"

}


variable "external_route_table_id"{
    description = "Holds the ID of the route table for externally routable subbnets"
    type = string
    default = "external_oute_table_id"
}


variable "tgw_route_table_id"{
    description = "Holds the ID of the route table for the transit gateway subbnets"
    type = string
    default = "tgw_route_table_id"

}

# Next Hop Infrastructure ID
# ---------------------------------------------------------------------------------------------------------------
variable "tgw_nexthopinfra_id"{
    description = "Holds the ID of the route table for aws_routable subbnet"
    type = string
    default = "tgw-xyz"

}

variable "nat_gw_nexthop_infra_id"{
  description = "Holds the ID of the nat gateway"
  type = string
  default = "nat-gw-xyz"

}

variable "igw_nexthop_infra_id"{
  description = "Holds the ID of the internet gateway"
  type = string
  default = "igw-abc-123"
}

# TGW Destination CIDR Block 
# ---------------------------------------------------------------------------------------------------------------
variable "tgw_aws_route_destination"{
  description = "Contains the Destination IP/s for the AWS Routable subnets"
  default = ["0.0.0.0/0"]

}

variable "tgw_external_route_destination"{
  description = "Contains the Destination IP/s for the externally routable subnets"
  default = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/12"]

}

variable "tgw_subnet_route_destination"{
  description = "Contains the Destination IP/s for the tgw route table"
  default = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "100.64.0.0/12"]
}

variable "blanket_default_route_destination"{
     description = "Holds the ID of the route table for aws_routable subbnetss"
     default = ["0.0.0.0/0"]
}

variable "tgw_subnet_route_destination_for_public_nat_deployment"{
  description = "Contains the DEFAULT Route as a Destination IP for the tgw route table"
  default = ["0.0.0.0/0"]
}

variable "tgw_subnet_route_destination_for_private_nat_deployment"{
  description = "Contains the DEFAULT Route as a Destination IP for the tgw route table"
  default = ["10.1.1.1/32"]
}

variable "igw_destination_cidr_block" {
  description = "Contains the DEFAULT Route as a Destination IP for the tgw route table"
  default = "0.0.0.0/0"
}