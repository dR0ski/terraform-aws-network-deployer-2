# VPC ID
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_id" {}

variable "deployment_type_name"{
  type = map(string)
  default = {
    type_spoke = "spoke_vpc"
    type_shared = "shared_services_vpc"
  }
}

variable "vpc_type" {
  type = map(bool)
  default = {
    spoke_vpc               = false
    shared_services         = false

  }
}
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

# VPC Endpoint Object List
# ---------------------------------------------------------------------------------------------------------------
variable "endpoints" {
  type = map(bool)
  default = {
    s3_gateway          = false
    dynamodb            = false
    secrets_manager     = false
    kms                 = false
    ec2                 = false
    ec2_messages        = false
    ecs                 = false
    ecs_agent           = false
    ecs_telemetry       = false
    sts                 = false
    sns                 = false
    sqs                 = false
    ssm                 = false
    ssm_messages        = false
  }
}


# AWS Region
# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  type    = string
  validation {
    # The condition here identifies if the variable contains one of the AWS Regions specified. This list can be reduced.
    condition = can(regex("us-east-2|us-east-1|us-west-1|us-west-2|af-south-1|ap-east-1|ap-south-1|ap-northeast-3|ap-northeast-2|ap-southeast-1|ap-southeast-2|ap-northeast-1|ca-central-1|eu-central-1|eu-west-1|eu-west-2|eu-south-1|eu-west-3|eu-north-1|me-south-1|sa-east-1", var.aws_region))
    error_message = "Please enter a valid AWS Regions."
  }

}


# Security Group Declaration
# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "endpoint_security_group" {
  type    = string
  description = "Security group to which the endpoints must be attached."
}


# AWS Route Table ID
# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "route_table_id" {}



# Endpoint Subnet IDs
# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "endpoint_subnet_ids"{}


# Environment Type
# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "environment_type" {
  type    = string
  description = "The environment type that the network is being created for. That is, DEV/PROD/UAT/SANDBOX."
  validation {
    # The condition here identifies if the variable contains one of the AWS Regions specified. This list can be reduced.
    condition = can(regex("Development|dev|DEVELOPMENT|development|DEV|UAT|User Acceptance Testing|TEST|Production|PROD|PRODUCTION|SANDBOX|SandBox|Sandbox|Sand-box|Sand-Box|Shared Services|SHARED SERVICES|SHARED-SERVICES|Shared-Services|shared services|shared-services|shared_services|SHARED_SERVICES|Shared_Services|packet_inspection|packet inspection|packet-inspection|Packet Inspection|Packet-inspection|Packet-Inspection|Packet_Inspection|PACKET INSPECTION", var.environment_type))
    error_message = "Please enter a valid environment type."
  }
}


variable "api_x_key" {
  default = "eInSTeInXtHe0rY7rEltiv!ty"
}
