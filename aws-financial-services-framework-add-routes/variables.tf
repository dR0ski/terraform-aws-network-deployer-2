# ---------------------------------------------------------------------------------------------------------------
# Map of route table decision
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
    tgw                 = true
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


variable "tgw_route_table_id"{
    description = "Holds the ID of the route table for aws_routable subbnetss"
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

# variable "tgw_route_destination"{
#     description = "Holds the ID of the route table for aws_routable subbnetss"
#     default = ["0.0.0.0/0"]

# }

