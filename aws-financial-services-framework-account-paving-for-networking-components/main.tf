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

# ---------------------------------------------------------------------------------------------------------------
# AWS Lambda Function | Adds Network Events to the EventBus that was created for Networking Events
# ---------------------------------------------------------------------------------------------------------------
module "fsf-vpc-network-operations-put-event-lambda-fn" {
  source  = "../aws-financial-services-network-ops-put-event-lambda-fn"
  depends_on = [module.fsf-vpc-network-operations-lambda-fn]
  vpc_type =  var.vpc_type
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
# AWS Lambda Function | Performs Networking Tasks for Transit Gateway, Centralized DNS and VPC Endpoints operations
# ---------------------------------------------------------------------------------------------------------------
module "fsf-vpc-network-operations-lambda-fn" {
  source  = "../aws-financial-services-network-ops-lambda-fn"
  vpc_type =  var.vpc_type
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
# AWS EventBridge EventBus Creation | Built with EventBus Rules that triggers the Network Operations Lambda Function
# ---------------------------------------------------------------------------------------------------------------
module "fsf-vpc-network-operations-eventbus" {
  source  = "../aws-financial-services-framework-eventbridge-network-bus"
  vpc_type =  var.vpc_type
  network-ops-lambda-fn-name = module.fsf-vpc-network-operations-lambda-fn.network-ops-lambda-fn-name
  network-ops-lambda-fn-arn = module.fsf-vpc-network-operations-lambda-fn.network-ops-lambda-fn-arn
  network-ops-lambda-fn-id = module.fsf-vpc-network-operations-lambda-fn.network-ops-lambda-fn-id
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
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTransitGatewayRoute",
                "ec2:ReplaceTransitGatewayRoute"
            ],
            "Resource": "arn:aws:ec2:*:*:transit-gateway-attachment/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTransitGatewayRoute",
                "ec2:ReplaceTransitGatewayRoute"
            ],
            "Resource": "arn:aws:ec2:*:*:transit-gateway-route-table/*"
        }
    ]
}

*/