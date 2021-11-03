##################################################################################################################
# This module deploys the transit gateway network that your business requires.
# To do this, simply configure the variables outlined in the terraform.tfvars file.
##################################################################################################################
module "deploy_aws_vpc_network"{
  source = "../"
  ################################################################################################################
  # AWS VPC CONFIGURATIONS
  ################################################################################################################



  ################################################################################################################
  # AWS TAGS
  ################################################################################################################
  Business_Unit                                     = var.Business_Unit
  Environment_Type                                  = var.Environment_Type
  CostCenterCode                                    = var.CostCenterCode
  CreatedBy                                         = var.CreatedBy
  Manager                                           = var.Manager
}

