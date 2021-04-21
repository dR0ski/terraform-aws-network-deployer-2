/*
 ---------------------------------------------------------------------------------------------------------------
 AWS Transit Gateway Terraform Module State | -------> Loaded from Amazon S3
 ---------------------------------------------------------------------------------------------------------------

This data source loads the terraform state file from the terraform backend where it is stored.In this case the
backend used is Amazon S3. If you use a different backend then please change the backend configuration
to match your backend.

If you dont have a back then please comment out this data source block.

*/


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


# ---------------------------------------------------------------------------------------------------------------
# AWS Route 53 Private Hosted Zone Put Event
# ---------------------------------------------------------------------------------------------------------------
module "fsf-spoke-phz-put-event" {
  source  = "../aws-financial-services-network-ops-put-event-lambda-fn"
  depends_on = [module.fsf-spoke-vpc-network-operations-lambda-fn]

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

/*

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:Describe*",
                "ec2:AssociateDhcpOptions",
                "ec2:AssociateRouteTable",
                "ec2:AssociateSubnetCidrBlock",
                "ec2:AssociateVpcCidrBlock",
                "ec2:CreateDhcpOptions",
                "ec2:CreateFlowLogs",
                "ec2:CreateNetworkAcl",
                "ec2:CreateNetworkAcl",
                "ec2:CreateNetworkAclEntry",
                "ec2:CreateRouteTable",
                "ec2:CreateSubnet",
                "ec2:CreateVpc",
                "ec2:CreateVpcEndpointConnectionNotification",
                "ec2:DeleteFlowLogs",
                "ec2:DeleteSubnet",
                "ec2:DeleteVpc",
                "ec2:DeleteVpcEndpointConnectionNotifications",
                "ec2:DisassociateRouteTable",
                "ec2:DisassociateSubnetCidrBlock",
                "ec2:DisassociateVpcCidrBlock",
                "ec2:EnableEbsEncryptionByDefault",
                "ec2:ModifySubnetAttribute",
                "ec2:ModifyVpcAttribute",
                "ec2:ModifyVpcEndpointConnectionNotification",
                "ec2:ModifyVpcEndpointServicePermissions",
                "ec2:ModifyVpcPeeringConnectionOptions",
                "ec2:ModifyVpcTenancy",
                "ec2:MoveAddressToVpc",
                "ec2:ReplaceNetworkAclAssociation",
                "ec2:ReplaceNetworkAclEntry",
                "ec2:ReplaceRouteTableAssociation"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow",
            "Sid": "AllowVPCManagementWildcardOnlyActions"
        },
        {
            "Action": [
                "ec2:CreateRoute",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:CreateVpcEndpoint",
                "ec2:CreateVpcEndpointServiceConfiguration",
                "ec2:ModifyVpcEndpoint",
                "ec2:ModifyVpcEndpointServiceConfiguration",
                "ec2:ReplaceRoute"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:dhcp-options*",
                "arn:aws:ec2:*:*:network-acl*",
                "arn:aws:ec2:*:*:route-table*",
                "arn:aws:ec2:*:*:vpc*",
                "arn:aws:ec2:*:*:vpc-endpoint*",
                "arn:aws:ec2:*:*:vpc-endpoint-service*",
                "arn:aws:ec2:*:*:route-table*",
                "arn:aws:ec2:*:*:security-group*",
                "arn:aws:ec2:*:*:subnet*"
            ],
            "Effect": "Allow",
            "Sid": "AllowVPCManagementSpecificResources"
        }
    ]
}

*/