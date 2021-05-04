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
  shared-services-name = "fsf_shared_services"
  spoke-name = "fsf_spoke_vpc"
  shared-joint-name = join("_", [local.shared-services-name, random_uuid.uuid_a.result])
  spoke-joint-name = join("_", [local.spoke-name, random_uuid.uuid_a.result])
  pave-joint-name = join("_", ["fsf_network_paving", random_uuid.uuid_a.result])
}



# ---------------------------------------------------------------------------------------------------------------
# Pave Account with Network Orchestration Components
# ---------------------------------------------------------------------------------------------------------------
//noinspection ConflictingProperties
module "pave_account_with_network_orchestration_components" {
  source = "./aws-financial-services-framework-account-paving-for-networking-components"
  count = ((var.which_vpc_type_are_you_creating.pave_account_with_eventbus_n_lambda_fn_for_network_task_orchestration == true && var.which_vpc_type_are_you_creating.spoke_vpc ==false && var.which_vpc_type_are_you_creating.shared_services_vpc==false) ? 1:0)
  providers = {
    aws = aws.paris # Please look in the provider.tf file for all the pre-configured providers. Choose the one that matches your requirements.
  }

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
  providers = {
    aws = aws.paris # Please look in the provider.tf file for all the pre-configured providers. Choose the one that matches your requirements.
  }

  # ----------------------------------------------------------------------------------------------------
  # CIDR Range to be used for creating your VPC
  # ----------------------------------------------------------------------------------------------------
  vpc_cidr_block                        = "100.64.0.0/16"

  # ----------------------------------------------------------------------------------------------------
  # Creates subnets that will host your public resources like NAT Gateways, public facing load balancers.
  # At least 1 IP address must be present in this list for each subnet type being created.
  # ----------------------------------------------------------------------------------------------------
  public_subnets                        = ["100.64.1.0/24", "100.64.2.0/24", "100.64.3.0/24"]

  # ----------------------------------------------------------------------------------------------------
  # Creates subnet(s) for hosting private workloads
  # ----------------------------------------------------------------------------------------------------
  private_subnets                       = ["100.64.4.0/24", "100.64.5.0/24", "100.64.6.0/24"]

  # ----------------------------------------------------------------------------------------------------
  # Creates a subnet that will host your transit gateway attachment interfaces.
  # ----------------------------------------------------------------------------------------------------
  transit_gateway_subnets               = ["100.64.7.0/24", "100.64.8.0/24", "100.64.9.0/24"]

  # ----------------------------------------------------------------------------------------------------
  # Passes a list of IP addresses for on-premises resource to the security group module for uses in rules
  # ----------------------------------------------------------------------------------------------------
  on_premises_cidrs                     = var.on_premises_cidrs

  # ----------------------------------------------------------------------------------------------------
  # AWS Region where VPC is to be created
  # ----------------------------------------------------------------------------------------------------
  aws_region                            = var.aws_region.paris

  # ----------------------------------------------------------------------------------------------------
  # Terraform Data Source Configuration to Access Transit Gateway State Info
  # --------------------------------------------------------------------------
  # The three below variables configure passes the AWS S3 information where the TGW terraform state is hosted
  # ----------------------------------------------------------------------------------------------------
  tf_backend_s3_bucket_aws_region                 = var.tf_backend_s3_bucket_aws_region
  tf_backend_state_file_s3_prefixpath_n_key_name  = var.tf_backend_state_file_s3_prefixpath_n_key_name
  tf_backend_s3_bucket_name                       = var.tf_backend_s3_bucket_name


  # ----------------------------------------------------------------------------------------------------
  # Terraform Data Source Configuration to the Network Paving Components for this account
  # ----------------------------------------------------------------------------------------------------
  # The three below variables configure passes the AWS S3 information where the Shared Services Paving Components terraform state is hosted
  # ----------------------------------------------------------------------------------------------------
  tf_shared_services_network_paving_components_backend_s3_bucket_aws_region                = var.tf_shared_services_network_paving_components_backend_s3_bucket_aws_region
  tf_shared_services_network_paving_components_backend_s3_bucket_name                      = var.tf_shared_services_network_paving_components_backend_s3_bucket_name
  tf_shared_services_network_paving_components_backend_state_file_s3_prefixpath_n_key_name = var.tf_shared_services_network_paving_components_backend_state_file_s3_prefixpath_n_key_name



  # ----------------------------------------------------------------------------------------------------
  # TGW Association
  # ---------------
  # This boolean map provides instructions on whether this shared services VPC should be integrated with
  # an AWS TGW that was deployed by the global tgw solution that accompanies this solution
  # If an integration should take place then the instruction allows for attachment and
  # TGW route table configuration
  # ----------------------------------------------------------------------------------------------------
  transit_gateway_association_instructions  = var.transit_gateway_association_instructions

  # Tags
  # -------
  Application_ID                            = var.Application_ID
  Application_Name                          = local.shared-joint-name
  Business_Unit                             = var.Business_Unit
  CostCenterCode                            = var.CostCenterCode
  CreatedBy                                 = var.CreatedBy
  Manager                                   = var.Manager
  Environment_Type                          = "shared services"

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
  providers = {
    aws = aws.paris # Please look in the provider.tf file for all the pre-configured providers. Choose the one that matches your requirements.
  }

  # ----------------------------------------------------------------------------------------------------
  # CIDR Range to be used for creating your VPC
  # ----------------------------------------------------------------------------------------------------
  vpc_cidr_block                                = "100.65.0.0/16"

  # ----------------------------------------------------------------------------------------------------
  # Creates subnets that will host resources that can be accessed externally and that can initiate traffic to external entities.
  # At least 1 IP address must be present in this list for each subnet type being created.
  # ----------------------------------------------------------------------------------------------------
  public_subnets                                = ["100.65.1.0/24", "100.65.2.0/24", "100.65.3.0/24"]

  # ----------------------------------------------------------------------------------------------------
  # Creates subnet(s) for hosting private workloads
  # ----------------------------------------------------------------------------------------------------
  private_subnets                               = ["100.65.4.0/24", "100.65.5.0/24", "100.65.6.0/24"]

  # ----------------------------------------------------------------------------------------------------
  # Creates a subnet that will host your transit gateway attachment interfaces.
  # ----------------------------------------------------------------------------------------------------
  transit_gateway_subnets                       = ["100.65.7.0/24", "100.65.8.0/24", "100.65.9.0/24"]

  # ----------------------------------------------------------------------------------------------------
  # Passes a list of IP addresses for on-premises resource to the security group module for uses in rules
  # ----------------------------------------------------------------------------------------------------
  on_premises_cidrs                     = var.on_premises_cidrs

  # ----------------------------------------------------------------------------------------------------
  # AWS Region where VPC is to be created
  # ----------------------------------------------------------------------------------------------------
  aws_region                                    = var.aws_region.paris

  # ----------------------------------------------------------------------------------------------------
  # Passing the variables that configures the data source to the transit gateway backend
  # ----------------------------------------------------------------------------------------------------
  tf_backend_s3_bucket_aws_region                 = var.tf_backend_s3_bucket_aws_region
  tf_backend_state_file_s3_prefixpath_n_key_name  = var.tf_backend_state_file_s3_prefixpath_n_key_name
  tf_backend_s3_bucket_name                       = var.tf_backend_s3_bucket_name

  # ----------------------------------------------------------------------------------------------------
  # Shared Services VPC Association (Backend Data Source Configuration)
  # -----------------------------------------------------------------------
  # If you have deployed the shared services VPC then configure the below three variables. This configuration
  # allows the data source to pull the shared services state information via the backend that you configured.
  # ----------------------------------------------------------------------------------------------------
  tf_shared_services_backend_s3_bucket_aws_region                = var.tf_shared_services_backend_s3_bucket_aws_region
  tf_shared_services_backend_s3_bucket_name                      = var.tf_shared_services_backend_s3_bucket_name
  tf_shared_services_backend_state_file_s3_prefixpath_n_key_name = var.tf_shared_services_backend_state_file_s3_prefixpath_n_key_name

  # ----------------------------------------------------------------------------------------------------
  # Terraform Data Source Configuration to the Network Paving Components for Shared Services Account
  # ----------------------------------------------------------------------------------------------------
  # The three below variables configure passes the AWS S3 information where the Shared Services Paving Components terraform state is hosted
  # ----------------------------------------------------------------------------------------------------
  tf_shared_services_network_paving_components_backend_s3_bucket_aws_region                = var.tf_shared_services_network_paving_components_backend_s3_bucket_aws_region
  tf_shared_services_network_paving_components_backend_s3_bucket_name                      = var.tf_shared_services_network_paving_components_backend_s3_bucket_name
  tf_shared_services_network_paving_components_backend_state_file_s3_prefixpath_n_key_name = var.tf_shared_services_network_paving_components_backend_state_file_s3_prefixpath_n_key_name

  # ----------------------------------------------------------------------------------------------------
  # Terraform Data Source Configuration to the Network Paving Components for This Account
  # ----------------------------------------------------------------------------------------------------
  # The three below variables configure passes the AWS S3 information where This Account Paving Components terraform state is hosted
  # ----------------------------------------------------------------------------------------------------
  tf_this_account_network_paving_components_backend_s3_bucket_aws_region                = var.tf_this_account_network_paving_components_backend_s3_bucket_aws_region
  tf_this_account_network_paving_components_backend_s3_bucket_name                      = var.tf_this_account_network_paving_components_backend_s3_bucket_name
  tf_this_account_network_paving_components_backend_state_file_s3_prefixpath_n_key_name = var.tf_this_account_network_paving_components_backend_state_file_s3_prefixpath_n_key_name



  # ----------------------------------------------------------------------------------------------------
  # TGW Association (Backend Data Source Configuration)
  # -------------------------------------------------------
  # This boolean map provides instructions on whether this spoke VPC should be integrated with
  # an AWS TGW that was deployed by the global tgw solution that accompanies this solution
  # If an integration should take place then the instruction allows for attachment and
  # TGW route table configuration
  # ----------------------------------------------------------------------------------------------------
  transit_gateway_association_instructions      = var.transit_gateway_association_instructions

  # ----------------------------------------------------------------------------------------------------
  # VPC Endpoints
  # ---------------------
  # VPC Endpoints are an integral part of the VPC experience. The below endpoint specification
  # Passes a boolean map with the endpoints to be configure. By default on the Gateway Endpoints are
  # enabled for spoke VPCs
  # ----------------------------------------------------------------------------------------------------
  endpoints                                     = var.endpoints

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
  private_hosted_zone_name                      = ["anaconda.aws-fsf-corp.com"]

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

