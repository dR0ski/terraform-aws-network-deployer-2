variable "monitoring" {
  type = map(bool)
  default = {
    enable_vpc_flow_logs  = true
  }
}

//variable "vpc_id" {
//  type  = string
//  validation {
//    condition     = can(regex("^vpc-", var.vpc_id))
//    error_message = "The vpc_id value must be a valid VPC id, starting with \"vpc-\"."
//  }
//}

variable "enabled" {
  type  = bool
  validation {
    condition     = var.enabled == true
    error_message = "The enabled value must be set to true."
  }
}

variable "aws_region" {
  type    = string
  description = "The region where the vpc needs to be created."
}