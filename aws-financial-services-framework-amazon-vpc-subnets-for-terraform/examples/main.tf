provider "aws" {
  profile   = "default"
  region    = "eu-west-3"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Object that contains a list of key value pairs that forms the tags added to a VPC on creation
# ---------------------------------------------------------------------------------------------------------------
locals {
  default_tags = {
    Name                 = var.Application_Name
    Application_ID       = var.Application_ID
    Application_Name     = var.Application_Name
    Business_Unit        = var.Business_Unit
    CostCenterCode       = var.CostCenterCode
    CreatedBy            = var.CreatedBy
    Manager              = var.Manager
    Environment_Type     = var.Environment_Type
  }
}


# The Spoke VPC creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "spoke_vpc" {
  cidr_block                            = var.vpc_cidr_block
  instance_tenancy                      = var.instance_tenancy
  enable_dns_support                    = var.dns_support
  enable_dns_hostnames                  = var.dns_host_names
  assign_generated_ipv6_cidr_block      = var.enable_aws_ipv6_cidr_block
  tags                                  = local.default_tags
}




# Declare the data source
# ---------------------------------------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}


# AWS Routable Subnet Declaration
# ---------------------------------------------------------------------------------------------------------------
# Private Subnet Declaration
# ---------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "private-subnet" {
  count = (
  length(data.aws_availability_zones.available.names) >= length(var.private_subnets) && var.subnet_type.aws_routable == true ? length(var.private_subnets) : (
  length(var.private_subnets) > length(data.aws_availability_zones.available.names) && var.subnet_type.aws_routable == true ? length(data.aws_availability_zones.available.names) : 0
  )
  )
  vpc_id                                  = aws_vpc.spoke_vpc.id
  cidr_block                              = var.private_subnets[count.index]
  availability_zone                       = data.aws_availability_zones.available.names[count.index]
  assign_ipv6_address_on_creation         = var.assign_ipv6_address_on_creation
  tags = {
    Name = "AWS_Routable_Subnet_${count.index}"
    Type = "AWS_Routable_Subnet"
    Environment = var.environment_type
  }

}


# Externally Routable Subnet Declaration
# ---------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "externally_routable_subnet" {
  count = (
  length(data.aws_availability_zones.available.names) >= length(var.private_subnets) && var.subnet_type.externally_routable == true ? length(var.private_subnets) : (
  length(var.private_subnets) > length(data.aws_availability_zones.available.names) && var.subnet_type.externally_routable == true ? length(data.aws_availability_zones.available.names) : 0
  )
  )
  vpc_id                                  = aws_vpc.spoke_vpc.id
  cidr_block                              = var.public_subnets[count.index]
  availability_zone                       = data.aws_availability_zones.available.names[count.index]
  assign_ipv6_address_on_creation         = var.assign_ipv6_address_on_creation
  map_public_ip_on_launch                 = var.map_public_ip_on_launch

  tags = {
    Name = "Externally_Routable_Subnet_${count.index}"
    Type = "Externally_Routable_Subnet"
    Environment = var.environment_type
  }

}


# Transit Gateway Routable Subnet Declaration
# ---------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "transit_gateway_attachment_subnet" {
  count = (
  length(data.aws_availability_zones.available.names) >= length(var.transit_gateway_subnets) && var.subnet_type.transit_gateway_subnet == true ? length(var.transit_gateway_subnets) : (
  length(var.transit_gateway_subnets) > length(data.aws_availability_zones.available.names) && var.subnet_type.transit_gateway_subnet == true ? length(data.aws_availability_zones.available.names) : 0
  )
  )
  vpc_id                                  = aws_vpc.spoke_vpc.id
  cidr_block                              = var.transit_gateway_subnets[count.index]
  availability_zone                       = data.aws_availability_zones.available.names[count.index]
  assign_ipv6_address_on_creation         = var.assign_ipv6_address_on_creation
  map_public_ip_on_launch                 = var.map_public_ip_on_launch

  tags = {
    Name = "TGW_Attachment_Subnet_${count.index}"
    Type = "TGW_Attachment_Subnet"
    Environment = var.environment_type
  }

}
