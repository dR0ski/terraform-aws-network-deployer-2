data "aws_caller_identity" "current" {}

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


variable "private_hosted_zone_comment" {
  description = "Comment to sort by"
  type    = string
  default = "Centralize-VPC-Interface-Endpoint-Managed-by-Terraform"

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

# VPC ID
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_id" {}

variable "endpoints" {
  type = map(bool)
  default = {
    s3_gateway          = true
    dynamodb            = true
    secrets_manager     = true
    kms                 = true
    ec2                 = true
    ec2_messages        = false
    ecs                 = false
    ecs_agent           = false
    ecs_telemetry       = false
    sts                 = true
    sns                 = true
    sqs                 = true
    ssm                 = false
    ssm_messages        = false
  }
}

# DNS Hostnames & DNS Zone ID
# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "ec2_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "ec2_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "ec2_messages_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "ec2_messages_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}


# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "ecs_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "ecs_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "ecs_agent_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "ecs_agent_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "ecs_telemetry_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "ecs_telemetry_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "sts_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "sts_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}


# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "sns_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "sns_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}


# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "sqs_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "sqs_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}


# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "ssm_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "ssm_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "ssm_messages_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "ssm_messages_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "kms_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "kms_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
variable "secrets_manager_endpoint_dns_hostname" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}

variable "secrets_manager_endpoint_dns_zone_id" {
  type    = string
  description = "VPC Endpoint Output of Endpoint DNS Hostname."
}


variable "api_x_key" {
  default = "eInSTeInXtHe0rY7rEltiv!ty"
}
