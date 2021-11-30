/*
THINGS TO DO
------------------------------------------------------------------------------------------------------------------
Please do the following before deploying this solution:

1. Open the backend.tf file and configure your backend where your Terraform state should be stored.
2. Open the variables.tf file and enable the
3. If you have deployed the global transit gateway solution that accompanies this solution then
   please configure the following variables inside the variables.tf file:
    •	tf_backend_s3_bucket_aws_region
    •	tf_backend_state_file_s3_prefixpath_n_key_name
    •	tf_backend_s3_bucket_name
------------------------------------------------------------------------------------------------------------------
*/

# ---------------------------------------------------------------------------------------------------------------
# Object that contains a list of key value pairs that forms the tags added to a VPC on creation
# ---------------------------------------------------------------------------------------------------------------
resource "random_uuid" "uuid_a" { }

locals{
  shared-services-name     = "fsf_shared_services"
  spoke-name               = "fsf_spoke_vpc"
  shared-joint-name        = join("_", [local.shared-services-name, random_uuid.uuid_a.result])
  spoke-joint-name         = join("_", [local.spoke-name, random_uuid.uuid_a.result])
  pave-joint-name          = join("_", ["fsf_network_paving", random_uuid.uuid_a.result])
}


# ---------------------------------------------------------------------------------------------------------------
# Pave Account with Network Orchestration Components
# ---------------------------------------------------------------------------------------------------------------
//noinspection ConflictingProperties
module "pave_account_with_network_orchestration_components" {
  source = "./aws-financial-services-framework-account-paving-for-networking-components"
  count = ((var.which_vpc_type_are_you_creating.pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration == true && var.which_vpc_type_are_you_creating.spoke_vpc ==false && var.which_vpc_type_are_you_creating.shared_services_vpc==false) ? 1:0)

  # ----------------------------------------------------------------------------------------------------
  # VPC Type specifies the type of VPC being created. This is used in the EventBus and Lambda FNs
  # ----------------------------------------------------------------------------------------------------
  vpc_type                                  = var.vpc_env_type

  # ----------------------------------------------------------------------------------------------------
  # Tags
  # ----------------------------------------------------------------------------------------------------
  Application_ID                            = var.Application_ID
  Application_Name                          = local.pave-joint-name
  Business_Unit                             = var.Business_Unit
  CostCenterCode                            = var.CostCenterCode
  CreatedBy                                 = var.CreatedBy
  Manager                                   = var.Manager
  Environment_Type                          = var.Environment_Type
}


# ---------------------------------------------------------------------------------------------------------------
# Creates Shared Services VPC
# ---------------------------------------------------------------------------------------------------------------
//noinspection ConflictingProperties
module "shared_services_vpc" {
  source = "./aws-financial-services-framework-deploy-shared-services-vpc"
  count = ((var.which_vpc_type_are_you_creating.shared_services_vpc == true) ? 1:0)

  # ----------------------------------------------------------------------------------------------------
  # CIDR Range to be used for creating your VPC
  # ----------------------------------------------------------------------------------------------------
  vpc_cidr_block                        = var.vpc_cidr_block

  # ----------------------------------------------------------------------------------------------------
  # Creates subnets that will host your public resources like NAT Gateways, public facing load balancers.
  # At least 1 IP address must be present in this list for each subnet type being created.
  # ----------------------------------------------------------------------------------------------------
  public_subnets                        = var.public_subnets

  # ----------------------------------------------------------------------------------------------------
  # Creates subnet(s) for hosting private workloads
  # ----------------------------------------------------------------------------------------------------
  private_subnets                       = var.private_subnets

  # ----------------------------------------------------------------------------------------------------
  # Creates a subnet that will host your transit gateway attachment interfaces.
  # ----------------------------------------------------------------------------------------------------
  transit_gateway_subnets               = var.transit_gateway_subnets

  # ----------------------------------------------------------------------------------------------------
  # Passes a list of IP addresses for on-premises resource to the security group module for uses in rules
  # ----------------------------------------------------------------------------------------------------
  on_premises_cidrs                     = var.on_premises_cidrs

  # ----------------------------------------------------------------------------------------------------
  # Instructs the security group module on which preconfigured security groups to create
  # ----------------------------------------------------------------------------------------------------
  security_grp_traffic_pattern          = var.security_grp_traffic_pattern

  # ----------------------------------------------------------------------------------------------------
  # AWS Region where VPC is to be created
  # ----------------------------------------------------------------------------------------------------
  aws_region                            = var.aws_region

  # ----------------------------------------------------------------------------------------------------
  # TGW Association
  # ---------------
  # This boolean map provides instructions on whether this shared services VPC should be integrated with
  # an AWS TGW that was deployed by the global tgw solution that accompanies this solution
  # If an integration should take place then the instruction allows for attachment and
  # TGW route table configuration
  # ----------------------------------------------------------------------------------------------------
  transit_gateway_association_instructions  = var.transit_gateway_association_instructions

  transit_gateway_id                                = var.transit_gateway_id
  transit_gateway_dev_route_table                   = var.transit_gateway_dev_route_table
  transit_gateway_uat_route_table                   = var.transit_gateway_uat_route_table
  transit_gateway_shared_svc_route_table            = var.transit_gateway_shared_svc_route_table
  transit_gateway_packet_inspection_route_table     = var.transit_gateway_shared_svc_route_table
  transit_gateway_prod_route_table                  = var.transit_gateway_prod_route_table

  # ----------------------------------------------------------------------------------------------------
  # Network Paved Infrastructure
  # ----------------------------------------------------------------------------------------------------
  shared-services-vpc-network-operations-put-event-lambda-fn-name   = var.shared-services-vpc-network-operations-put-event-lambda-fn-name
  shared_services_network_operations_eventbus_arn                   = var.shared_services_network_operations_eventbus_arn

  # ----------------------------------------------------------------------------------------------------
  # Route 53 Resolver DNS Firewall Implementation
  # ----------------------------------------------------------------------------------------------------
  firewall_fail_open                                                = var.firewall_fail_open
  domain_list_name                                                  = var.domain_list_name
  firewall_rule_group                                               = var.firewall_rule_group
  route_53_resolver_firewall_rule_name                              = var.route_53_resolver_firewall_rule_name
  route_53_resolver_firewall_rule_block_override_dns_type           = var.route_53_resolver_firewall_rule_block_override_dns_type
  route_53_resolver_firewall_rule_block_override_domain             = var.route_53_resolver_firewall_rule_block_override_domain     # Required if block_response is OVERRIDE
  route_53_resolver_firewall_rule_block_override_ttl                = var.route_53_resolver_firewall_rule_block_override_ttl           # Required if block_response is OVERRIDE
  route_53_resolver_firewall_rule_block_response                    = var.route_53_resolver_firewall_rule_block_response    # Required if action is BLOCK
  route_53_resolver_firewall_rule_priority                          = var.route_53_resolver_firewall_rule_priority          # Required
  firewall_rule_group_association_priority                          = var.firewall_rule_group_association_priority          # Required - Provide a num <> "100" and "9900"
  firewall_rule_group_association_name                              = var.firewall_rule_group_association_name
  domain_list                                                       = var.domain_list
  action_type                                                       = var.action_type
  ram_actions                                                       = var.ram_actions

  # ----------------------------------------------------------------------------------------------------
  # Internet Gateway Asset
  # ----------------------------------------------------------------------------------------------------
  igw_decisions              = var.igw_decisions

  # ----------------------------------------------------------------------------------------------------
  # Centralized NAT Assets
  # ----------------------------------------------------------------------------------------------------
  byoip_id                      = var.byoip_id
  number_of_azs_to_deploy_to    = var.number_of_azs_to_deploy_to
  nat_decisions                 = var.nat_decisions
  nat_gateway_connectivity_type = var.nat_gateway_connectivity_type
  create_private_nat_gateway    = var.create_private_nat_gateway
  create_public_nat_gateway     = var.create_public_nat_gateway

  # ----------------------------------------------------------------------------------------------------
  # Route Addition
  # ----------------------------------------------------------------------------------------------------
  default_deployment_route_configuration                  = var.default_deployment_route_configuration
  additional_route_deployment_configuration               = var.additional_route_deployment_configuration
  tgw_subnet_route_destination_for_private_nat_deployment = var.tgw_subnet_route_destination_for_private_nat_deployment


  # ----------------------------------------------------------------------------------------------------
  # Tags
  # ----------------------------------------------------------------------------------------------------
  Application_ID                            = var.Application_ID
  Application_Name                          = local.shared-joint-name
  Business_Unit                             = var.Business_Unit
  CostCenterCode                            = var.CostCenterCode
  CreatedBy                                 = var.CreatedBy
  Manager                                   = var.Manager
  Environment_Type                          = var.Environment_Type
}

/*
---------------------------------------------------------------------------------------------------------------
Creates a Spoke VPC

THINGS TO DO
------------------------------------------------------------------------------------------------------------------
If you have deployed a shared services VPC and you would like to integrate the spoke VPC
   with this shared services VPC then please configure the following variables in the variable.tf file:

    a. tf_shared_services_backend_s3_bucket_aws_region
    b. tf_shared_services_backend_s3_bucket_name
    c. tf_shared_services_backend_state_file_s3_prefixpath_n_key_name

Assumptions:
1. The shared services VPC you are integrating with was built by the shared services feature found in this solution.
2. AWS S3 is your terraform backend.

---------------------------------------------------------------------------------------------------------------*/

//noinspection ConflictingProperties
module "spoke_vpc" {
  source = "./aws-financial-services-framework-deploy-spoke-vpc"
  count = ((var.which_vpc_type_are_you_creating.spoke_vpc == true) ? 1:0)

  # ----------------------------------------------------------------------------------------------------
  # CIDR Range to be used for creating your VPC
  # ----------------------------------------------------------------------------------------------------
  vpc_cidr_block                                  = var.vpc_cidr_block

  # ----------------------------------------------------------------------------------------------------
  # Creates subnets that will host resources that can be accessed externally and that can initiate traffic to external entities.
  # At least 1 IP address must be present in this list for each subnet type being created.
  # ----------------------------------------------------------------------------------------------------
  public_subnets                                  = var.public_subnets

  # ----------------------------------------------------------------------------------------------------
  # Creates subnet(s) for hosting private workloads
  # ----------------------------------------------------------------------------------------------------
  private_subnets                                 = var.private_subnets

  # ----------------------------------------------------------------------------------------------------
  # Creates a subnet that will host your transit gateway attachment interfaces.
  # ----------------------------------------------------------------------------------------------------
  transit_gateway_subnets                         = var.transit_gateway_subnets

  # ----------------------------------------------------------------------------------------------------
  # Passes a list of IP addresses for on-premises resource to the security group module for uses in rules
  # ----------------------------------------------------------------------------------------------------
  on_premises_cidrs                               = var.on_premises_cidrs

  # ----------------------------------------------------------------------------------------------------
  # Instructs the security group module on which preconfigured security groups to create
  # ----------------------------------------------------------------------------------------------------
  security_grp_traffic_pattern                    = var.security_grp_traffic_pattern

  # ----------------------------------------------------------------------------------------------------
  # AWS Region where VPC is to be created
  # ----------------------------------------------------------------------------------------------------
  aws_region                                      = var.aws_region

  # ----------------------------------------------------------------------------------------------------
  # TGW Association (Backend Data Source Configuration)
  # -------------------------------------------------------
  # This boolean map provides instructions on whether this spoke VPC should be integrated with
  # an AWS TGW that was deployed by the global tgw solution that accompanies this solution
  # If an integration should take place then the instruction allows for attachment and
  # TGW route table configuration
  # ----------------------------------------------------------------------------------------------------
  transit_gateway_association_instructions          = var.transit_gateway_association_instructions

  transit_gateway_id                                = var.transit_gateway_id
  transit_gateway_dev_route_table                   = var.transit_gateway_dev_route_table
  transit_gateway_uat_route_table                   = var.transit_gateway_uat_route_table
  transit_gateway_shared_svc_route_table            = var.transit_gateway_shared_svc_route_table
  transit_gateway_packet_inspection_route_table     = var.transit_gateway_shared_svc_route_table
  transit_gateway_prod_route_table                  = var.transit_gateway_prod_route_table

  # ----------------------------------------------------------------------------------------------------
  # Network Paved Infrastructure
  # ----------------------------------------------------------------------------------------------------
  shared_services_vpc_id                                   = var.shared_services_vpc_id
  shared_services_network_operations_eventbus_arn          = var.shared_services_network_operations_eventbus_arn
  spoke-vpc-network-operations-put-event-lambda-fn-name    = var.spoke-vpc-network-operations-put-event-lambda-fn-name
  spoke_vpc_network_operations_eventbus_arn                = var.spoke_vpc_network_operations_eventbus_arn

  # ----------------------------------------------------------------------------------------------------
  # Route 53 Resolver
  # ----------------------------------------------------------------------------------------------------
  route_53_resolver_firewall_actions                           = var.route_53_resolver_firewall_actions
  route_53_resolver_firewall_group                             = var.route_53_resolver_firewall_group
  route_53_resolver_firewall_rule_group_association_priority   = var.route_53_resolver_firewall_rule_group_association_priority
  route_53_resolver_firewall_rule_group_association_name       = var.route_53_resolver_firewall_rule_group_association_name



  # ----------------------------------------------------------------------------------------------------
  # VPC Endpoints
  # ----------------------------------------------------------------------------------------------------
  # VPC Endpoints are an integral part of the VPC experience. The below endpoint specification
  # Passes a boolean map with the endpoints to be configure. By default on the Gateway Endpoints are
  # enabled for spoke VPCs
  # ----------------------------------------------------------------------------------------------------
  endpoints                                                   = var.endpoints

  # ----------------------------------------------------------------------------------------------------
  # Integrating with Centralized VPC Endpoints (If Available)
  # ---------------------------------------------------------
  # is_centralize_interface_endpoints_available boolean map. It controls integration of this spoke VPC with any
  # available centralized interface endpoint in the shared services account.
  # Both items in this map has to be true to trigger this association
  # Automatic association between the spoke VPC and the shared services VPC only occurs of the shared services VPC
  # was deployed by this solution.
  # ----------------------------------------------------------------------------------------------------
  is_centralize_interface_endpoints_available   = var.is_centralize_interface_endpoints_available

  # ----------------------------------------------------------------------------------------------------
  # Centralized DNS Integration
  # ----------------------------------
  # This solution has provisions built in it to deploy a centralized DNS solution. This solution is deployable
  # in the shared services VPC only. That said, spoke VPCs built by the solution allows for easy integration.
  # The below boolean variable is used to trigger this integration
  # ----------------------------------------------------------------------------------------------------
  attach_to_centralize_dns_solution             = var.attach_to_centralize_dns_solution

  # ----------------------------------------------------------------------------------------------------
  # Private Hosted Zone Creation
  # route53_acts is an instruction set that tells terraform to create a private hosted zone for this VPC or not
  # If a private hosted zone is to be created, then should instructions be sent to the shared services pipeline
  # to makes this private hosted zone centrally available to all VPC.

  # private_hosted_zone_name is list variable that contains one or more hosted zones to be created.
  # ----------------------------------------------------------------------------------------------------
  route53_acts                                  = var.route53_acts
  rule_type                                     = var.rule_type
  private_hosted_zone_name                      = var.private_hosted_zone_name

  # Tags
  # -------
  Application_ID                            = var.Application_ID
  Application_Name                          = local.spoke-joint-name
  Business_Unit                             = var.Business_Unit
  CostCenterCode                            = var.CostCenterCode
  CreatedBy                                 = var.CreatedBy
  Manager                                   = var.Manager
  Environment_Type                          = var.Environment_Type
}

