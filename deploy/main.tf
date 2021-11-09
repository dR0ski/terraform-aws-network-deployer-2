##################################################################################################################
# This module deploys the transit gateway network that your business requires.
# To do this, simply configure the variables outlined in the terraform.tfvars file.
##################################################################################################################
module "deploy_aws_vpc_network"{
  source = "../"

  # ---------------------------------------------------------------------------------------------------------------
  #  PROVIDER | PROVIDER ALIAS DECIDED WHICH REGION THE INFRASTRUCTURE IS DEPLOYED
  # ---------------------------------------------------------------------------------------------------------------
  providers = {
    aws = aws.oregon # Please look in the provider.tf file for all the pre-configured providers. Choose the one that matches your requirements.
  }

  # ---------------------------------------------------------------------------------------------------------------
  #  ORCHESTRATION | TRANSIT GATEWAY & TRANSIT GATEWAY ROUTE TABLES
  # ---------------------------------------------------------------------------------------------------------------
  which_vpc_type_are_you_creating               = var.which_vpc_type_are_you_creating

  # ---------------------------------------------------------------------------------------------------------------
  #  AWS TRANSIT GATEWAY IDENTIFIERS | TRANSIT GATEWAY & TRANSIT GATEWAY ROUTE TABLES
  # ---------------------------------------------------------------------------------------------------------------
  transit_gateway_id                            = var.transit_gateway_id
  transit_gateway_dev_route_table               = var.transit_gateway_dev_route_table
  transit_gateway_uat_route_table               = var.transit_gateway_uat_route_table
  transit_gateway_shared_svc_route_table        = var.transit_gateway_shared_svc_route_table
  transit_gateway_packet_inspection_route_table = var.transit_gateway_packet_inspection_route_table
  transit_gateway_prod_route_table              = var.transit_gateway_prod_route_table

  # ---------------------------------------------------------------------------------------------------------------
  #  SHARED SERVICES IDENTIFIERS | TRANSIT GATEWAY & TRANSIT GATEWAY ROUTE TABLES
  # ---------------------------------------------------------------------------------------------------------------
  shared_services_vpc_id                                            = var.shared_services_vpc_id
  shared-services-vpc-network-operations-put-event-lambda-fn-name   = var.shared-services-vpc-network-operations-put-event-lambda-fn-name
  shared_services_network_operations_eventbus_arn                   = var.shared_services_network_operations_eventbus_arn

  # ---------------------------------------------------------------------------------------------------------------
  #  SPOKE IDENTIFIERS | TRANSIT GATEWAY & TRANSIT GATEWAY ROUTE TABLES
  # ---------------------------------------------------------------------------------------------------------------
  spoke-vpc-network-operations-put-event-lambda-fn-name             = var.spoke-vpc-network-operations-put-event-lambda-fn-name
  spoke_vpc_network_operations_eventbus_arn                         = var.spoke_vpc_network_operations_eventbus_arn

  # ---------------------------------------------------------------------------------------------------------------
  # Transit Gateway Association Task Map
  # ---------------------------------------------------------------------------------------------------------------
  transit_gateway_association_instructions                          = var.transit_gateway_association_instructions

  # ---------------------------------------------------------------------------------------------------------------
  # AWS VPC SECURITY GROUP | Decision Map | Adding true creates the security that you want
  # ---------------------------------------------------------------------------------------------------------------
  security_grp_traffic_pattern                                      = var.security_grp_traffic_pattern

  # ---------------------------------------------------------------------------------------------------------------
  # VPC ENDPOINTS
  # ---------------------------------------------------------------------------------------------------------------
  endpoints                                                         = var.endpoints

  # ---------------------------------------------------------------------------------------------------------------
  # Route 53 Private Hosted Zone |
  # Controls whether a private hosted zone is created or not. It also controls the creation of route 53 resolver rules.
  # ---------------------------------------------------------------------------------------------------------------
  route53_acts                                                      = var.route53_acts

  # ---------------------------------------------------------------------------------------------------------------
  # AWS REGION | REGION CODE MAPPED TO REGION NAME
  # ---------------------------------------------------------------------------------------------------------------
  aws_region                                                        = var.aws_region

  rule_type                                                         = var.rule_type

  # ---------------------------------------------------------------------------------------------------------------
  #  Controls Resource Deployment for VPC TYPES
  # ---------------------------------------------------------------------------------------------------------------

  # VPC TYPE
  # ---------------------------------------------------------------------------------------------------------------
  vpc_type                                                          = var.vpc_type

  vpc_type_string                                                   = var.vpc_type_string

  vpc_env_type                                                      = var.vpc_env_type


  # Decision to make associate with centralized Route53 Private Hosted Zone
  # ---------------------------------------------------------------------------------------------------------------
  is_centralize_interface_endpoints_available                       = var.is_centralize_interface_endpoints_available

  attach_to_centralize_dns_solution                                 = var.attach_to_centralize_dns_solution


  # ---------------------------------------------------------------------------------------------------------------
  ################################################## VPC VARIABLES ################################################
  # ---------------------------------------------------------------------------------------------------------------

  # VPC Tenancy Bool. There are two tenancy type [default, dedicated]
  # ---------------------------------------------------------------------------------------------------------------
  instance_tenancy = var.instance_tenancy

  # DNS_Support Bool Variable. This is used in the DHCP Option Set for the VPC
  # ---------------------------------------------------------------------------------------------------------------
  dns_support = var.dns_support


  # DNS_Hostname Bool Variable. This is used in the DHCP Option Set for the VPC
  # ---------------------------------------------------------------------------------------------------------------
  dns_host_names = var.dns_host_names

  # Primary VPC CIDR range that is allocated to the spoke VPC
  # ---------------------------------------------------------------------------------------------------------------
  vpc_cidr_block = var.vpc_cidr_block

  # Enable an AWS provided /56 IPv6 CIDR Block with /64 Subnet Ranges
  # ---------------------------------------------------------------------------------------------------------------
  enable_aws_ipv6_cidr_block = var.enable_aws_ipv6_cidr_block

  # VPC Flow enablement bool
  # ---------------------------------------------------------------------------------------------------------------
  enable_vpc_flow_logs = var.enable_vpc_flow_logs

  # ---------------------------------------------------------------------------------------------------------------
  ############################################### DHCP MODULE VARIBLES ############################################
  # ---------------------------------------------------------------------------------------------------------------

  # Amazon VPC DHCP Option Map: This map allows you to enable the type of DHCP Options to create and associate
  # ---------------------------------------------------------------------------------------------------------------
  create_dhcp_options = var.create_dhcp_options
  # Custom DHCP Options configuration parameters.
  # ---------------------------------------------------------------------------------------------------------------
  # (Optional) the suffix domain name to use by default when resolving non Fully Qualified Domain Names.
  # In other words, this is what ends up being the search value in the /etc/resolv.conf file.
  # Domain for Amazon Provided DNS
  custom_domain_name     = var.custom_domain_name
  domain_name_servers    = var.domain_name_servers
  ntp_servers            = var.ntp_servers
  netbios_name_servers   = var.netbios_name_servers
  netbios_node_type      = var.netbios_node_type

  private_hosted_zone_name  =  var.private_hosted_zone_name

  # ---------------------------------------------------------------------------------------------------------------
  ########################################### SUBNET MODULE VARIABLES #############################################
  # ---------------------------------------------------------------------------------------------------------------

  # Private Subnet Declaration
  # ---------------------------------------------------------------------------------------------------------------
  subnet_type = var.subnet_type



  # ---------------------------------------------------------------------------------------------------------------
  # Map of port and security group attributes required for the creations of the Amazon VPC Security Group
  # ---------------------------------------------------------------------------------------------------------------
  private_subnets = var.private_subnets

  # ---------------------------------------------------------------------------------------------------------------
  # Map of port and security group attributes required for the creations of the Amazon VPC Security Group
  # ---------------------------------------------------------------------------------------------------------------
  public_subnets = var.public_subnets

  # ---------------------------------------------------------------------------------------------------------------
  # Transit Gateway Attachment Subnet
  # ---------------------------------------------------------------------------------------------------------------
  transit_gateway_subnets = var.transit_gateway_subnets

  # ---------------------------------------------------------------------------------------------------------------
  # Module: AWS-FSF-ADD-ROUTE
  # ---------------------------------------------------------------------------------------------------------------

  # Bool Map that controls the addition of routes with the AWS Transit Gateway as the next hop infrastructure
  # ---------------------------------------------------------------------------------------------------------------
  route_table = var.route_table

  next_hop_infra = var.next_hop_infra


  # TGW Destination CIDR Block
  # ---------------------------------------------------------------------------------------------------------------
  tgw_aws_route_destination       = var.tgw_aws_route_destination
  tgw_external_route_destination  = var.tgw_external_route_destination


  # Not used in this module
  # ---------------------------------------------------------------------------------------------------------------
  tgw_route_destination = var.tgw_route_destination

  # Decision to create AWS Route 53 Private Hosted Zones
  # ---------------------------------------------------------------------------------------------------------------
  create_private_hosted_zones_for_endpoints = var.create_private_hosted_zones_for_endpoints

  # Enable Private DNS
  # ---------------------------------------------------------------------------------------------------------------
  enable_private_dns = var.enable_private_dns

  # ---------------------------------------------------------------------------------------------------------------
  # VPC SECURITY GROUPS
  # ---------------------------------------------------------------------------------------------------------------

  # On-premises IP Range to be added to the spoke VPC security group
  # ---------------------------------------------------------------------------------------------------------------
  on_premises_cidrs = var.on_premises_cidrs

  # ---------------------------------------------------------------------------------------------------------------
  ##################################################### TAGS ######################################################
  # ---------------------------------------------------------------------------------------------------------------
  ####### MUST CONFIGURE #######
  # Variables that makes up the AWS Tags assigned to the VPC on creation.
  # ---------------------------------------------------------------------------------------------------------------
  Application_ID    = var.Application_ID

  Application_Name  = var.Application_Name

  Business_Unit     = var.Business_Unit

  Environment_Type  = var.Environment_Type

  CostCenterCode    = var.CostCenterCode

  CreatedBy         = var.CreatedBy

  Manager           = var.Manager

}

