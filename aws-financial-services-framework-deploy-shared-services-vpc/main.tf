/*
 ---------------------------------------------------------------------------------------------------------------
 Shared Services Sub-module  |
 ---------------------------------------------------------------------------------------------------------------
This Network Services VPC is built to centrally distribute AWS network services. Today, these services includes:
  1. Centralized DNS
  2. Centralized Interface Endpoints
  3. Centrally Distributed Route 53 DNS Firewall Group & Rules
  4. Centralized NAT (which includes centralized private & public NAT)
As a network engineer, you do not have to touch or modify this module unless the dependencies defined here isn't
sufficient.

If these dependencies are sufficient, then please configure your network deployment from the "deploy" submodule.
*/

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
  tgw_id                                = var.transit_gateway_id                                  # join("_", [local.region_name, "transit_gateway_id"])
  tgw_dev_route_table                   = var.transit_gateway_dev_route_table                     # join("_", [local.region_name,"tgw_development_route_table_id"])
  tgw_uat_route_table                   = var.transit_gateway_uat_route_table                     # join("_", [local.region_name,"tgw_uat_route_table_id"])
  tgw_shared_svc_route_table            = var.transit_gateway_shared_svc_route_table              # join("_", [local.region_name,"tgw_shared_services_route_table_id"])
  tgw_packet_inspection_route_table     = var.transit_gateway_packet_inspection_route_table       # join("_", [local.region_name,"tgw_packet_inspection_route_table_id"])
  tgw_prod_route_table                  = var.transit_gateway_prod_route_table                    # join("_", [local.region_name,"tgw_production_route_table_id"])
}

# ---------------------------------------------------------------------------------------------------------------
# The Spoke VPC creation
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc" {
  source = "../aws-financial-services-framework-spoke-vpc-for-terraform"
  aws_region = var.aws_region
  vpc_cidr_block                            = var.vpc_cidr_block
  instance_tenancy                          = var.instance_tenancy
  dns_support                               = var.dns_support
  dns_host_names                            = var.dns_host_names
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
module "fsf-shared-services-vpc-flow-logs" {
  source        = "../aws-financial-services-framework-amazon-vpc-flow-logs-for-terraform"
  vpc_id        = module.fsf-shared-services-vpc.vpc_id
  enabled       = var.enable_vpc_flow_logs
  aws_region    = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------
# Create a standard or custom DHCP Optionset
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc-dhcp-options" {
  source               = "../aws-financial-services-framework-dhcp-terraform"
  vpc_id               = module.fsf-shared-services-vpc.vpc_id
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
module "fsf-shared-services-vpc-subnets" {
  source                      = "../aws-financial-services-framework-amazon-vpc-subnets-for-terraform"
  vpc_id                      = module.fsf-shared-services-vpc.vpc_id
  subnet_type                 = var.subnet_type
  public_subnets              = var.public_subnets
  private_subnets             = var.private_subnets
  transit_gateway_subnets     = var.transit_gateway_subnets
  environment_type            = var.Environment_Type
}

# ---------------------------------------------------------------------------------------------------------------
# Spoke VPC | ---> Creates VPC Route Table & Perform Route Table Association
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-create-vpc-route-tables" {
  source                          = "../aws-financial-services-framework-amazon-vpc-route-table-for-terraform"
  vpc_id                          = module.fsf-shared-services-vpc.vpc_id
  externally_routable_subnets     = module.fsf-shared-services-vpc-subnets.externally_routable_subnets
  routable_subnets                = module.fsf-shared-services-vpc-subnets.routable_subnets
  transit_gateway_subnets         = module.fsf-shared-services-vpc-subnets.transit_gateway_subnets
  environment_type                = var.Environment_Type
}

# ---------------------------------------------------------------------------------------------------------------
# AWS Transit Gateway | This module submits a TGW association request then automatically configure TGW route tables
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc-transit-gateway-association" {
  source                                            = "../aws-financial-services-framework-transit-gateway-association-n-route-configuration"
  count = var.transit_gateway_association_instructions.create_transit_gateway_association==true  ? 1:0
  vpc_id                                            = module.fsf-shared-services-vpc.vpc_id
  environment_type                                  = var.Environment_Type
  transit_gateway_id                                = local.tgw_id # lookup(data.terraform_remote_state.transit_gateway_network[0].outputs, local.tgw_id, "transit gateway ID not found")        #paris_transit_gateway_id
  transit_gateway_dev_route_table_id                = local.tgw_dev_route_table # lookup(data.terraform_remote_state.transit_gateway_network[0].outputs, local.tgw_dev_route_table, "transit gateway dev route table not found")
  transit_gateway_uat_route_table_id                = local.tgw_uat_route_table # lookup(data.terraform_remote_state.transit_gateway_network[0].outputs, local.tgw_uat_route_table, "transit gateway uat route table not found")
  transit_gateway_shared_services_route_table_id    = local.tgw_shared_svc_route_table          # lookup(data.terraform_remote_state.transit_gateway_network[0].outputs, local.tgw_shared_svc_route_table, "transit gateway shared services route table not found")
  transit_gateway_packet_inspection_route_table_id  = local.tgw_packet_inspection_route_table   # lookup(data.terraform_remote_state.transit_gateway_network[0].outputs, local.tgw_packet_inspection_route_table, "transit gateway packet inspection route table not found")
  transit_gateway_production_route_table_id         = local.tgw_prod_route_table                # lookup(data.terraform_remote_state.transit_gateway_network[0].outputs, local.tgw_prod_route_table, "transit gateway prod route table not found")
  transit_gateway_subnets                           = module.fsf-shared-services-vpc-subnets.transit_gateway_subnets # "${aws_subnet.transit_gateway_attachment_subnet.*.id}"
  create_transit_gateway_association                = var.transit_gateway_association_instructions.create_transit_gateway_association
  transit_gateway_subnets_exist                     = module.fsf-shared-services-vpc-subnets.tgw_routable_enabled  # var.subnet_type.transit_gateway_subnet
  access_shared_services_vpc                        = var.transit_gateway_association_instructions.access_shared_services_vpc
  perform_east_west_packet_inspection               = var.transit_gateway_association_instructions.perform_east_west_packet_inspection
  route53_association_lambda_fn_name                = var.shared-services-vpc-network-operations-put-event-lambda-fn-name # data.terraform_remote_state.shared_services_network_paving_components.outputs.vpc-network-operations-put-event-lambda-fn-name # module.fsf-shared-services-network-put-event-lambda-fn.network-ops-put-event-lambda-fn-name
  # EVENT BUS ARN FOR THE TGW ACCOUNT NETWORKING COMPONENTS.
  eventbus_arn                                      = var.shared_services_network_operations_eventbus_arn # data.terraform_remote_state.shared_services_network_paving_components.outputs.vpc_network_operations_eventbus_arn # module.fsf-shared-services-vpc-network-operations-eventbus.eventbus_arn
}

# ---------------------------------------------------------------------------------------------------------------
# Add Route Module
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc-add-route" {
  source                          = "../aws-financial-services-framework-add-routes"
  count                                             = (var.transit_gateway_association_instructions.create_transit_gateway_association == true ? 1:0)
  depends_on                                        = [module.fsf-shared-services-vpc-subnets, module.fsf-shared-services-create-vpc-route-tables, module.fsf-shared-services-vpc-transit-gateway-association, module.fsf-shared-services-vpc-endpoints]
  aws_route_table_id                                = module.fsf-shared-services-create-vpc-route-tables.aws_routable_routing_table_id
  external_route_table_id                           = module.fsf-shared-services-create-vpc-route-tables.externally_routable_routing_table_id
  tgw_route_table_id                                = module.fsf-shared-services-create-vpc-route-tables.tgw_attachment_routing_table_id
  tgw_aws_route_destination                         = var.tgw_aws_route_destination
  tgw_external_route_destination                    = var.tgw_external_route_destination
  tgw_nexthopinfra_id                               = local.tgw_id
  route_table                                       = var.route_table
  next_hop_infra                                    = var.next_hop_infra
  default_deployment_route_configuration            = var.default_deployment_route_configuration
  add_igw_route_to_externally_routable_route_tables = var.add_igw_route_to_externally_routable_route_tables
}

# ---------------------------------------------------------------------------------------------------------------
# Create VPC Endpoint(s) Modules
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc-endpoints" {
  source                                    = "../aws-financial-services-framework-amazon-vpc-endpoints-for-terraform"
  vpc_id                                    = module.fsf-shared-services-vpc.vpc_id
  route_table_id                            = module.fsf-shared-services-create-vpc-route-tables.externally_routable_routing_table_id
  endpoint_security_group                   = module.fsf-shared-services-vpc-security-groups.non_routable_security_group_id
  endpoints                                 = var.endpoints
  endpoint_subnet_ids                       = module.fsf-shared-services-vpc-subnets.externally_routable_subnets #Please add subnet-ids from the subnet module here
  aws_region                                = var.aws_region
  environment_type                          = var.Environment_Type
  create_private_hosted_zones_for_endpoints = var.create_private_hosted_zones_for_endpoints
  enable_private_dns                        = var.enable_private_dns
  api_x_key                                 = var.api_x_key
}

# ---------------------------------------------------------------------------------------------------------------
# Create VPC Security Group Modules
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc-security-groups" {
  source                          = "../aws-financial-services-framework-security-group-for-terraform"
  vpc_id                          = module.fsf-shared-services-vpc.vpc_id
  vpc_cidr_block                  = module.fsf-shared-services-vpc.vpc_cidr_block
  environment_type                = var.Environment_Type
  on_premises_cidrs               = var.on_premises_cidrs
  security_grp_traffic_pattern    = var.security_grp_traffic_pattern
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Route 53 | Creates Resolver Endpoints && Private Hosted Zone(s)
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc-dns-resolvers" {
  source  = "../aws-financial-services-framework-dns-resolvers"
  external_security_id                = module.fsf-shared-services-vpc-security-groups.non_routable_security_group_id
  externally_routable_subnet_id       = module.fsf-shared-services-vpc-subnets.routable_subnets
  vpc_id                              = module.fsf-shared-services-vpc.vpc_id
  resolver_query_logging_destination  = ""
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
# Creates RAM Share for Resolver DNS Firewall -  Modules
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-resolver-dns-firewall-ram-share" {
  source                          = "../aws-financial-services-framework-route-53-resolver-dns-ram-share"
  resolver_dns_firewall_ram_share_name                              = var.resolver_dns_firewall_ram_share_name
  allow_external_principals                                         = var.allow_external_principals
  ram_actions                                                       = var.ram_actions
}

# ---------------------------------------------------------------------------------------------------------------
# Creates Route 53 Resolver Firewall Modules
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-route-53-resolver-firewall" {
  source = "../aws-financial-services-framework-route53-resolver-firewall"
  depends_on = [module.fsf-shared-services-resolver-dns-firewall-ram-share]
  vpc_id                                                            = module.fsf-shared-services-vpc.vpc_id
  firewall_fail_open                                                = var.firewall_fail_open
  domain_list_name                                                  = var.domain_list_name
  firewall_rule_group                                               = var.firewall_rule_group
  route_53_resolver_firewall_rule_name                              = var.route_53_resolver_firewall_rule_name
  route_53_resolver_firewall_rule_block_override_dns_type           = var.route_53_resolver_firewall_rule_block_override_dns_type
  route_53_resolver_firewall_rule_block_override_domain             = var.route_53_resolver_firewall_rule_block_override_domain     # Required if block_response is OVERRIDE
  route_53_resolver_firewall_rule_block_override_ttl                = var.route_53_resolver_firewall_rule_block_override_ttl           # Required if block_response is OVERRIDE
  route_53_resolver_firewall_rule_block_response                    = var.route_53_resolver_firewall_rule_block_response    # Required if action is BLOCK
  route_53_resolver_firewall_rule_priority                          = var.route_53_resolver_firewall_rule_priority            # Required
  firewall_rule_group_association_priority                          = var.firewall_rule_group_association_priority            # Required - Provide a num <> "100" and "9900"
  firewall_rule_group_association_name                              = var.firewall_rule_group_association_name
  resource_share_arn                                                = module.fsf-shared-services-resolver-dns-firewall-ram-share.route_53_resolver_dns_firewall_ram_share_arn
  domain_list                                                       = var.domain_list
  action_type                                                       = var.action_type
  ram_actions                                                       = var.ram_actions
  # --------------------------------------------------------------------------------------------------------------------
  # TAGS
  # --------------------------------------------------------------------------------------------------------------------
  Application_ID                                                    = var.Application_ID
  Application_Name                                                  = var.Application_Name
  Business_Unit                                                     = var.Business_Unit
  Environment_Type                                                  = var.Environment_Type
  CostCenterCode                                                    = var.CostCenterCode
  CreatedBy                                                         = var.CreatedBy
  Manager                                                           = var.Manager
}

# ---------------------------------------------------------------------------------------------------------------
# Adds an Internet Gateway
# ---------------------------------------------------------------------------------------------------------------
module "internet-gateway-deployment"{
  source = "../aws-financial-services-framework-internet-gateway"
  count = var.igw_decisions.ipv4_internet_gateway==true ? 1:0
  vpc_id = module.fsf-shared-services-vpc.vpc_id
  igw_decisions = var.igw_decisions
}

# ---------------------------------------------------------------------------------------------------------------
# Add Route Module
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc-add-route-igw-default-route" {
  source                                                  = "../aws-financial-services-framework-add-routes"
  count                                                   = var.add_igw_route_to_externally_routable_route_tables==true && var.igw_decisions.ipv4_internet_gateway==true ? 1:0
  depends_on                                              = [module.internet-gateway-deployment]
  external_route_table_id                                 = module.fsf-shared-services-create-vpc-route-tables.externally_routable_routing_table_id
  default_deployment_route_configuration                  = false
  additional_route_deployment_configuration               = false
  igw_nexthop_infra_id                                    = module.internet-gateway-deployment[0].ipv4_igw_id[0]
  igw_destination_cidr_block                              = var.igw_destination_cidr_block
  add_igw_route_to_externally_routable_route_tables       = var.add_igw_route_to_externally_routable_route_tables
}

# ---------------------------------------------------------------------------------------------------------------
# Add Centralized NAT Functionality Module
# ---------------------------------------------------------------------------------------------------------------
module "fsf-centralized-private-nat"{
  source="../aws-financial-services-framework-internet-egress-n-nat-functionality"
  count                         = var.create_private_nat_gateway==true && var.nat_gateway_connectivity_type.private==true && var.nat_decisions.create_nat_gateway==true ? 1:0
  vpc_id                        = module.fsf-shared-services-vpc.vpc_id
  byoip_id                      = ""
  subnet_id                     = module.fsf-shared-services-vpc-subnets.externally_routable_subnets
  number_of_azs_to_deploy_to    = var.number_of_azs_to_deploy_to
  nat_decisions                 = var.nat_decisions
  nat_gateway_connectivity_type = var.nat_gateway_connectivity_type
  create_private_nat_gateway    = var.create_private_nat_gateway
  # --------------------------------------------------------------------------------------------------------------------
  # TAGS
  # --------------------------------------------------------------------------------------------------------------------
  Application_ID              = var.Application_ID
  Application_Name            = var.Application_Name
  Business_Unit               = var.Business_Unit
  Environment_Type            = var.Environment_Type
  CostCenterCode              = var.CostCenterCode
  CreatedBy                   = var.CreatedBy
  Manager                     = var.Manager
}


# ---------------------------------------------------------------------------------------------------------------
# Add Route Module
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc-add-route-private-nat" {
  source                                                  = "../aws-financial-services-framework-add-routes"
  count                                                   = var.create_private_nat_gateway==true && var.nat_gateway_connectivity_type.private==true && var.nat_decisions.create_nat_gateway==true && var.additional_route_deployment_configuration==true ? 1:0
  depends_on                                              = [module.fsf-centralized-private-nat]
  tgw_route_table_id                                      = module.fsf-shared-services-create-vpc-route-tables.tgw_attachment_routing_table_id
  default_deployment_route_configuration                  = false
  additional_route_deployment_configuration               = var.additional_route_deployment_configuration
  nat_gw_nexthop_infra_id                                 = module.fsf-centralized-private-nat[count.index].nat_gateway_id_private[count.index]
  tgw_subnet_route_destination_for_private_nat_deployment = var.tgw_subnet_route_destination_for_private_nat_deployment
  create_private_nat_gateway                              = var.create_private_nat_gateway
}

module "fsf-centralized-public-nat"{
  source="../aws-financial-services-framework-internet-egress-n-nat-functionality"
  count                         = var.create_public_nat_gateway==true &&  var.nat_gateway_connectivity_type.private==true && var.nat_decisions.create_nat_gateway==true ? 1:0
  vpc_id                        = module.fsf-shared-services-vpc.vpc_id
  byoip_id                      = ""
  subnet_id                     = module.fsf-shared-services-vpc-subnets.externally_routable_subnets
  number_of_azs_to_deploy_to    = var.number_of_azs_to_deploy_to
  nat_decisions                 = var.nat_decisions
  nat_gateway_connectivity_type = var.nat_gateway_connectivity_type
  create_public_nat_gateway     = var.create_public_nat_gateway
  # --------------------------------------------------------------------------------------------------------------------
  # TAGS
  # --------------------------------------------------------------------------------------------------------------------
  Application_ID              = var.Application_ID
  Application_Name            = var.Application_Name
  Business_Unit               = var.Business_Unit
  Environment_Type            = var.Environment_Type
  CostCenterCode              = var.CostCenterCode
  CreatedBy                   = var.CreatedBy
  Manager                     = var.Manager
}

# ---------------------------------------------------------------------------------------------------------------
# Add Route Module
# ---------------------------------------------------------------------------------------------------------------
module "fsf-shared-services-vpc-add-route-public-nat" {
  source                                                  = "../aws-financial-services-framework-add-routes"
  count                                                   = (var.create_public_nat_gateway==true && var.nat_decisions.create_nat_gateway == true && var.nat_gateway_connectivity_type.public == true && var.additional_route_deployment_configuration==true ? 1:0)
  depends_on                                              = [module.fsf-centralized-private-nat]
  tgw_route_table_id                                      = module.fsf-shared-services-create-vpc-route-tables.tgw_attachment_routing_table_id
  default_deployment_route_configuration                  = false
  additional_route_deployment_configuration               = var.additional_route_deployment_configuration
  nat_gw_nexthop_infra_id                                 = module.fsf-centralized-public-nat[count.index].nat_gateway_id_public[count.index]
  tgw_subnet_route_destination_for_public_nat_deployment  = var.tgw_subnet_route_destination_for_public_nat_deployment
  create_public_nat_gateway                               = var.create_public_nat_gateway
}

