/*
 ---------------------------------------------------------------------------------------------------------------
 AWS Transit Gateway Terraform Module State | -------> Loaded from Amazon S3
 ---------------------------------------------------------------------------------------------------------------

This data source loads the terraform state file from the terraform backend where it is stored.In this case the
backend used is Amazon S3. If you use a different backend then please change the backend configuration
to match your backend.

If you dont have a back then please comment out this data source block.

*/

data "terraform_remote_state" "transit_gateway_network" {
  backend = "s3"
  config = {
    # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
    bucket = var.tf_backend_s3_bucket_name
    # Please populate with the key name the terraform.tfstate file for your transit_gateway
    key = var.tf_backend_state_file_s3_prefixpath_n_key_name
    # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
    region = var.tf_backend_s3_bucket_aws_region
  }
}


data "terraform_remote_state" "shared_services_network" {
  backend = "s3"
  config = {
    # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
    bucket = var.tf_shared_services_backend_s3_bucket_name
    # Please populate with the key name the terraform.tfstate file for your transit_gateway
    key = var.tf_shared_services_backend_state_file_s3_prefixpath_n_key_name
    # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
    region = var.tf_shared_services_backend_s3_bucket_aws_region
  }
}

# ---------------------------------------------------------------------------------------------------------------

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

locals {
  region_name                           = lookup(var.aws_region_names, var.aws_region, "what?")
  tgw_id                                = join("_", [local.region_name, "transit_gateway_id"])
  tgw_dev_route_table                   = join("_", [local.region_name,"tgw_development_route_table_id"])
  tgw_uat_route_table                   = join("_", [local.region_name,"tgw_uat_route_table_id"])
  tgw_shared_svc_route_table            = join("_", [local.region_name,"tgw_shared_services_route_table_id"])
  tgw_packet_inspection_route_table     = join("_", [local.region_name,"tgw_packet_inspection_route_table_id"])
  tgw_prod_route_table                  = join("_", [local.region_name,"tgw_production_route_table_id"])
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Route 53 Private Hosted Zone Put Event
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-phz-put-event" {
  source  = "../aws-financial-services-network-ops-put-event-lambda-fn"
  depends_on = [module.fsf-spoke-vpc-network-operations-lambda-fn]
  vpc_id                              = data.terraform_remote_state.shared_services_network.outputs.shared_services_vpc_id
  private_hosted_zone_id              = module.fsf-spoke-dns-private-hosted-zones.private-hosted-zone-id
  vpc_region                          = var.aws_region
  eventbus_arn                        = data.terraform_remote_state.shared_services_network.outputs.shared_services_networkops_eventbus_arn
  vpc_type                            =  var.vpc_env_type
  route53_acts                        = var.route53_acts
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Route 53 Resolver Inbound Endpoint
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-vpc-network-operations-lambda-fn" {
  source  = "../aws-financial-services-network-ops-lambda-fn"
  vpc_type =  var.vpc_env_type
}

# ---------------------------------------------------------------------------------------------------------------
# AWS Route 53 Resolver Inbound Endpoint
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-vpc-network-operations-eventbus" {
  source  = "../aws-financial-services-framework-eventbridge-network-bus"
  vpc_type =  var.vpc_env_type
  network-ops-lambda-fn-name = module.fsf-spoke-vpc-network-operations-lambda-fn.network-ops-lambda-fn-name
  network-ops-lambda-fn-arn = module.fsf-spoke-vpc-network-operations-lambda-fn.network-ops-lambda-fn-arn
  network-ops-lambda-fn-id = module.fsf-spoke-vpc-network-operations-lambda-fn.network-ops-lambda-fn-id
}

# ---------------------------------------------------------------------------------------------------------------
# The Spoke VPC creation
# ---------------------------------------------------------------------------------------------------------------
module "spoke_vpc" {
  source = "../aws-financial-services-framework-spoke-vpc-for-terraform"
  aws_region = var.aws_region
  vpc_cidr_block                            = var.vpc_cidr_block
  instance_tenancy                          = var.instance_tenancy
  dns_support                               = var.dns_support
  dns_host_names                             = var.dns_host_names
  enable_aws_ipv6_cidr_block                = var.enable_aws_ipv6_cidr_block
  # Tags
  # -------
  Application_ID                            = var.Application_ID
  Application_Name                          = var.Application_Name
  Business_Unit                             = var.Business_Unit
  CostCenterCode                            = var.CostCenterCode
  CreatedBy                                 = var.CreatedBy
  Manager                                   = var.Manager
  Environment_Type                          = var.Environment_Type

}

# ---------------------------------------------------------------------------------------------------------------
# Imports the VPC FlowLog module
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-vpc-flow-logs" {
  source  = "../aws-financial-services-framework-amazon-vpc-flow-logs-for-terraform"
  vpc_id  = module.spoke_vpc.vpc_id
  enabled = var.enable_vpc_flow_logs
  aws_region= var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------
# Create a standard or custom DHCP Optionset
# ---------------------------------------------------------------------------------------------------------------
module "fsf-vpc-spoke-dhcp-options" {
  source               = "../aws-financial-services-framework-dhcp-terraform"
  vpc_id               = module.spoke_vpc.vpc_id
  aws_region           = var.aws_region
  Application_ID       = var.Application_ID
  Application_Name     = var.Application_Name
  Business_Unit        = var.Business_Unit
  CostCenterCode       = var.CostCenterCode
  CreatedBy            = var.CreatedBy
  Manager              = var.Manager
  Environment_Type     = var.Environment_Type
  create_dhcp_options  = var.create_dhcp_options
}

# ---------------------------------------------------------------------------------------------------------------
# Spoke VPC | ---> Creates VPC Subnets
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-vpc-subnets" {
  source                      = "../aws-financial-services-framework-amazon-vpc-subnets-for-terraform"
  vpc_id                      = module.spoke_vpc.vpc_id
  subnet_type                 = var.subnet_type
  public_subnets              = var.public_subnets
  private_subnets             = var.private_subnets
  transit_gateway_subnets     = var.transit_gateway_subnets
  environment_type            = var.Environment_Type
}

# ---------------------------------------------------------------------------------------------------------------
# Spoke VPC | ---> Creates VPC Route Table & Perform Route Table Association
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-create-vpc-route-tables" {
  source                          = "../aws-financial-services-framework-amazon-vpc-route-table-for-terraform"
  vpc_id                          = module.spoke_vpc.vpc_id
  externally_routable_subnets     = module.fsf-spoke-vpc-subnets.externally_routable_subnets
  routable_subnets                = module.fsf-spoke-vpc-subnets.routable_subnets
  transit_gateway_subnets         = module.fsf-spoke-vpc-subnets.transit_gateway_subnets
  environment_type                = var.Environment_Type
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Transit Gateway | This module submits a TGW association request then automatically configure TGW route tables
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke_vpc-transit-gateway-association" {
  source                                            = "../aws-financial-services-framework-transit-gateway-association-spoke"
  vpc_id                                            = module.spoke_vpc.vpc_id
  environment_type                                  = var.Environment_Type
  transit_gateway_id                                = lookup(data.terraform_remote_state.transit_gateway_network.outputs, local.tgw_id, "transit gateway ID not found")        #paris_transit_gateway_id
  transit_gateway_dev_route_table_id                = lookup(data.terraform_remote_state.transit_gateway_network.outputs, local.tgw_dev_route_table, "transit gateway dev route table not found")
  transit_gateway_uat_route_table_id                = lookup(data.terraform_remote_state.transit_gateway_network.outputs, local.tgw_uat_route_table, "transit gateway uat route table not found")
  transit_gateway_shared_services_route_table_id    = lookup(data.terraform_remote_state.transit_gateway_network.outputs, local.tgw_shared_svc_route_table, "transit gateway shared services route table not found")
  transit_gateway_packet_inspection_route_table_id  = lookup(data.terraform_remote_state.transit_gateway_network.outputs, local.tgw_packet_inspection_route_table, "transit gateway packet inspection route table not found")
  transit_gateway_production_route_table_id         = lookup(data.terraform_remote_state.transit_gateway_network.outputs, local.tgw_prod_route_table, "transit gateway prod route table not found")
  transit_gateway_subnets                           = module.fsf-spoke-vpc-subnets.transit_gateway_subnets # "${aws_subnet.transit_gateway_attachment_subnet.*.id}"
  create_transit_gateway_association                = var.transit_gateway_association_instructions.create_transit_gateway_association
  transit_gateway_subnets_exist                     = module.fsf-spoke-vpc-subnets.tgw_routable_enabled  # var.subnet_type.transit_gateway_subnet
  access_shared_services_vpc                        = var.transit_gateway_association_instructions.access_shared_services_vpc
  perform_east_west_packet_inspection               = var.transit_gateway_association_instructions.perform_east_west_packet_inspection
  route53_association_lambda_fn_name                = module.fsf-spoke-phz-put-event.network-ops-put-event-lambda-fn-name
  eventbus_arn                                      = data.terraform_remote_state.shared_services_network.outputs.shared_services_networkops_eventbus_arn
}


# ---------------------------------------------------------------------------------------------------------------
# Add Route Module
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-vpc-add-route" {
  source                          = "../aws-financial-services-framework-add-routes"
  aws_route_table_id              = module.fsf-spoke-create-vpc-route-tables.aws_routable_routing_table_id
  external_route_table_id         = module.fsf-spoke-create-vpc-route-tables.externally_routable_routing_table_id
  tgw_aws_route_destination       = var.tgw_aws_route_destination
  tgw_external_route_destination  = var.tgw_external_route_destination
  tgw_nexthopinfra_id             = lookup(data.terraform_remote_state.transit_gateway_network.outputs, local.tgw_id, "transit gateway ID not found")     #ENTER TGW ID    : THIS COULD BE A MODULE REFERENCE OR MANUALLY ENTERED ID : IF CREATE TGW ROUTE IS TRUE
  route_table                     = var.route_table
  next_hop_infra                  = var.next_hop_infra
}

# ---------------------------------------------------------------------------------------------------------------
# Create VPC Endpoint(s) Modules
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-vpc-endpoints" {
  source                                    = "../aws-financial-services-framework-amazon-vpc-endpoints-for-terraform"
  vpc_id                                    = module.spoke_vpc.vpc_id
  route_table_id                            = module.fsf-spoke-create-vpc-route-tables.externally_routable_routing_table_id
  endpoint_security_group                   = module.fsf-spoke-vpc-security-groups.non_routable_security_group_id
  endpoints                                 = var.endpoints
  endpoint_subnet_ids                       = module.fsf-spoke-vpc-subnets.externally_routable_subnets #Please add subnet-ids from the subnet module here
  aws_region                                = var.aws_region
  environment_type                          = var.Environment_Type
  create_private_hosted_zones_for_endpoints = var.create_private_hosted_zones_for_endpoints
  enable_private_dns                        = var.enable_private_dns
}

# ---------------------------------------------------------------------------------------------------------------
# Create VPC Security Group Modules
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-vpc-security-groups" {
  source                          = "../aws-financial-services-framework-security-group-for-terraform"
  vpc_id                          = module.spoke_vpc.vpc_id
  vpc_cidr_block                  = module.spoke_vpc.vpc_cidr_block
  environment_type                = var.Environment_Type
  on_premises_cidrs               = var.on_premises_cidrs
  security_grp_traffic_pattern    = var.security_grp_traffic_pattern
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Route 53 | Creates Private Hosted Zone(s)
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-dns-private-hosted-zones" {
  source  = "../aws-financial-services-framework-dns-private-hosted-zones"
  vpc_id                              = module.spoke_vpc.vpc_id
  private_hosted_zone_name            = ["anaconda.aws-fsf-corp.com"]
  vpc_region                          = var.aws_region
  eventbus_arn                        = data.terraform_remote_state.shared_services_network.outputs.shared_services_networkops_eventbus_arn
  shared_services_vpc_id              = data.terraform_remote_state.shared_services_network.outputs.shared_services_vpc_id
  route53_acts                        = var.route53_acts
  route53_association_lambda_fn_name  = module.fsf-spoke-phz-put-event.network-ops-put-event-lambda-fn-name
  rule_type                           = var.rule_type
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Route 53 | Creates Resolver Endpoints
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-vpc-dns" {
  source  = "../aws-financial-services-framework-dns-resolvers"
  external_security_id                = module.fsf-spoke-vpc-security-groups.non_routable_security_group_id
  externally_routable_subnet_id       = module.fsf-spoke-vpc-subnets.routable_subnets
  vpc_id                              = module.spoke_vpc.vpc_id
  resolver_query_logging_destination  = ""
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Lambda | Invoking the FN that adds the creation of this PHZ as an event in the Shared Service EventBus
# ---------------------------------------------------------------------------------------------------------------
data "aws_lambda_invocation" "hi_centralized_asset_assoc_me_with_your_endpoints" {
  count = (var.is_centralize_interface_endpoints_available.is_centralized_interface_endpoints==true && var.is_centralize_interface_endpoints_available.associate_with_private_hosted_zones==true) ? 1:0
  depends_on = [module.spoke_vpc, module.fsf-spoke-vpc-subnets, module.fsf-spoke-vpc-security-groups, module.fsf-spoke-vpc-network-operations-eventbus, module.fsf-spoke-phz-put-event]
  function_name = module.fsf-spoke-phz-put-event.network-ops-put-event-lambda-fn-name
  input = <<JSON
  {
    "event_type": "centralized_interface_endpoints_association_request",
    "vpc_id": "${module.spoke_vpc.vpc_id}",
    "vpc_region": "${var.aws_region}",
    "eventbus_arn": "${data.terraform_remote_state.shared_services_network.outputs.shared_services_networkops_eventbus_arn}",
    "spoke_eventbus_arn": "${module.fsf-spoke-vpc-network-operations-eventbus.eventbus_arn}"
  }
JSON

}


# ---------------------------------------------------------------------------------------------------------------
# AWS Lambda | Invoking the FN that adds the creation of this PHZ as an event in the Shared Service EventBus
# ---------------------------------------------------------------------------------------------------------------
data "aws_lambda_invocation" "hi_centralized_asset_assoc_me_with_your_dns_resource_shares" {
  count = (var.attach_to_centralize_dns_solution==true) ? 1:0
  depends_on = [module.spoke_vpc, module.fsf-spoke-vpc-subnets, module.fsf-spoke-vpc-security-groups, module.fsf-spoke-vpc-network-operations-eventbus, module.fsf-spoke-phz-put-event, data.aws_lambda_invocation.hi_centralized_asset_assoc_me_with_your_endpoints]
  function_name = module.fsf-spoke-phz-put-event.network-ops-put-event-lambda-fn-name
  input = <<JSON
  {
    "event_type": "centralized_dns_association_request",
    "vpc_id": "${module.spoke_vpc.vpc_id}",
    "vpc_region": "${var.aws_region}",
    "eventbus_arn": "${module.fsf-spoke-vpc-network-operations-eventbus.eventbus_arn}"
  }
JSON

}
