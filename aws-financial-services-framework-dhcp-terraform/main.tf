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


# OPTION SET 1: This is a standard DHCP Options
# ---------------------------------------------------------------------------------------------------------------
resource "aws_vpc_dhcp_options" "us_east_1_dhcp_options" {
  count               = (var.create_dhcp_options.dhcp_options == true && var.create_dhcp_options.custom_dhcp_options == false && var.aws_region=="us-east-1"  ? 1 :0 )
  domain_name         = "ec2.internal" 
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = local.default_tags
}

resource "aws_vpc_dhcp_options_association" "us_east_1_dhcp_association" {
  count           = (var.create_dhcp_options.dhcp_options == true && var.create_dhcp_options.custom_dhcp_options == false && var.aws_region=="us-east-1"  ? 1 :0 )
  dhcp_options_id = aws_vpc_dhcp_options.us_east_1_dhcp_options[count.index].id
  vpc_id          = var.vpc_id
}


resource "aws_vpc_dhcp_options" "region_other_standard_dhcp_options" {
  count               = (var.create_dhcp_options.dhcp_options == true && var.create_dhcp_options.custom_dhcp_options == false && var.aws_region!="us-east-1"  ? 1 :0 )
  domain_name         = join("", [var.aws_region,".compute.internal"]) 
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = local.default_tags
}

resource "aws_vpc_dhcp_options_association" "region_other_standard_dhcp_association" {
  count           = (var.create_dhcp_options.dhcp_options == true && var.create_dhcp_options.custom_dhcp_options == false && var.aws_region!="us-east-1"  ? 1 :0 )
  dhcp_options_id = aws_vpc_dhcp_options.region_other_standard_dhcp_options[count.index].id
  vpc_id          = var.vpc_id
}


# OPTION SET 2: This creates a custom DHCP Options
# ---------------------------------------------------------------------------------------------------------------
resource "aws_vpc_dhcp_options" "custom_dhcp_options" {
  domain_name          = var.custom_domain_name 
  domain_name_servers  = var.domain_name_servers
  ntp_servers          = var.ntp_servers
  netbios_name_servers = var.netbios_name_servers
  netbios_node_type    = var.netbios_node_type
  count                = (var.create_dhcp_options.dhcp_options == true && var.create_dhcp_options.custom_dhcp_options == true  ? 1 : 0)
  tags                 = local.default_tags
}

resource "aws_vpc_dhcp_options_association" "custom_dhcp_association" {
  count           = (var.create_dhcp_options.dhcp_options == true && var.create_dhcp_options.custom_dhcp_options == true  ? 1 : 0)
  dhcp_options_id = aws_vpc_dhcp_options.custom_dhcp_options[count.index].id
  vpc_id          = var.vpc_id
}