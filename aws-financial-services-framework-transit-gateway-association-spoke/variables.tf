
variable "vpc_id" {}

variable "eventbus_arn"{}

variable "vpc_type" {
  type = map(bool)
  default = {
    spoke_vpc               = true
    shared_services         = false
  }
}

variable "route53_association_lambda_fn_name" {default = "X"}

variable "transit_gateway_default_route_table_association" { 
    default = false
    validation {
        condition     = (var.transit_gateway_default_route_table_association == false)
        error_message = "This association should never result in an automatic association with the AWS TGW default route table."
    }
}

variable "transit_gateway_default_route_table_propagation"{ 
    default = false
    validation {
        condition     = (var.transit_gateway_default_route_table_propagation == false)
        error_message = "This the routes from this VPC should never automatically propagate to the AWS TGW default route table."
    }
}

variable "transit_gateway_subnets"{
    default = []
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

variable "transit_gateway_subnets_exist" {
  default = true
  validation {
    condition     = (var.transit_gateway_subnets_exist == true || var.transit_gateway_subnets_exist == false)
    error_message = "Transit_gateway_subnets_exist can either be true or false."
  }
}

variable "create_transit_gateway_association" {
  default = true
  validation {
    condition     = (var.create_transit_gateway_association == true || var.create_transit_gateway_association == false)
    error_message = "Create_transit_gateway_association can either be true or false."
  }
}

variable "access_shared_services_vpc" {
  default = true
  validation {
    condition     = (var.access_shared_services_vpc == true || var.access_shared_services_vpc == false)
    error_message = "Access_shared_services_vpc can either be true or false."
  }
}

variable "perform_east_west_packet_inspection" {
  default = false
  validation {
    condition     = (var.perform_east_west_packet_inspection == true || var.perform_east_west_packet_inspection == false)
    error_message = "Perform_east_west_packet_inspection can either be true or false."
  }
}


variable "route_isolation" {
  default = true
  validation {
    condition     = (var.route_isolation == true || var.route_isolation == false)
    error_message = "Perform route_isolation can either be true or false."
  }
}


variable "transit_gateway_id" {}
variable "transit_gateway_dev_route_table_id" {}
variable "transit_gateway_uat_route_table_id" {}
variable "transit_gateway_shared_services_route_table_id" {}
variable "transit_gateway_packet_inspection_route_table_id" {}
variable "transit_gateway_production_route_table_id" {}