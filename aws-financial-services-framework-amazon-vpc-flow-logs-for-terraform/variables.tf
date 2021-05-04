variable "monitoring" {
  type = map(bool)
  default = {
    enable_vpc_flow_logs  = true
  }
}


# VPC ID of VPC for which Flowlogs is being enabled
# ---------------------------------------------------------------------------------------------------------------
variable "vpc_id" {
  type  = string
  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "The vpc_id value must be a valid VPC id, starting with \"vpc-\"."
  }
}


# Flag that decides if VPC Flowlogs is enabled or disabled.
# ---------------------------------------------------------------------------------------------------------------

variable "enabled" {
  type  = bool
  default = true
  validation {
    condition     = (var.enabled == true)
    error_message = "VPC Flowlogs must be enabled. Therefore, enable_vpc_flow_logs must be set to true."
  }
}


# AWS Region decalration
# ---------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  type    = string
  validation {
    # The condition here identifies if the variable contains one of the AWS Regions specified. This list can be reduced.
    condition = can(regex("us-east-2|us-east-1|us-west-1|us-west-2|af-south-1|ap-east-1|ap-south-1|ap-northeast-3|ap-northeast-2|ap-southeast-1|ap-southeast-2|ap-northeast-1|ca-central-1|eu-central-1|eu-west-1|eu-west-2|eu-south-1|eu-west-3|eu-north-1|me-south-1|sa-east-1", var.aws_region))
    error_message = "ERROR: Operating System must be Windows OR Linux."
  }

}
