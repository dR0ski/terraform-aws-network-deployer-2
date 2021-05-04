# ---------------------------------------------------------------------------------------------------------------
# VPC ID
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_id" {}


# VPC Environment Type
# ---------------------------------------------------------------------------------------------------------------
variable "environment_type" {
  description = "Envrionment Type"
  type    = string
  default = "Development"

}


variable "routable_subnets" {}

variable "externally_routable_subnets" {}

variable "transit_gateway_subnets" {}