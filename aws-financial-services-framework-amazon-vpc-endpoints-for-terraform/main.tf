data "aws_caller_identity" "current" {}
#-----------------------------------------------------------------------------------------------------------------

# Creates data sources that provide access to subnets based on the tags attached to them
# ---------------------------------------------------------------------------------------------------------------
//data "aws_subnet_ids" "aws_routable_subnet_id" {
//  vpc_id = var.vpc_id
//
//  tags = {
//   Type = "AWS_Routable_Subnet"
//  }
//}

//data "aws_subnet_ids" "externally_routable_subnet_id" {
//  vpc_id = var.vpc_id
//
//  tags = {
//    Type = "Externally_Routable_Subnet"
//  }
//}


# VPC Endpoints 
# ---------------------------------------------------------------------------------------------------------------

# S3 VPC Endpoint 
resource "aws_vpc_endpoint" "s3_ep" {
	vpc_id        = var.vpc_id
	service_name  = "com.amazonaws.${var.aws_region}.s3"
	policy = <<POLICY
		{
		 "Statement": [{
								"Effect": "Allow",
								"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
								"Action": [
									 "s3:Get*",
									 "s3:List*",
									 "s3:PutObject"
								],
								"Resource": [
									"arn:aws:s3::${data.aws_caller_identity.current.account_id}:*",
									"arn:aws:s3:::packages.*.amazonaws.com/*",
									"arn:aws:s3:::repo.*.amazonaws.com/*",
									"arn:aws:s3:::patch-baseline-snapshot-${data.aws_caller_identity.current.account_id}:/*",
									"arn:aws:s3:::aws-ssm-${var.aws_region}/*"
								]
						}]
	 
		}
		POLICY
	count        = var.endpoints.s3_gateway == true ? 1 : 0
	tags = {
		Name = "spokeVPC_s3"
		Environment = var.environment_type
	}
	
}


#-----------------------------------------------------------------------------------------------------------------
# S3 VPC Endpoint Route Table Association
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint_route_table_association" "s3_ep_association" {
  depends_on 	  = [aws_vpc_endpoint.s3_ep]
  count = var.endpoints.s3_gateway == true ? 1:0
  route_table_id  = var.route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3_ep[0].id
  
}
#-----------------------------------------------------------------------------------------------------------------


# DynamoDB VPC Endpoint 
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "dynamodb_ep" {
	vpc_id        = var.vpc_id
	service_name  = "com.amazonaws.${var.aws_region}.dynamodb"
	policy = <<POLICY
		{
		 "Statement": [{
								"Effect": "Allow",
								"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
								"Action": [
										"dynamodb:GetItem",
										"dynamodb:PutItem",
										"dynamodb:Scan",
										"dynamodb:Query"
								],
								"Resource": ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/*/index/*"]
						}]
	 
		}
		POLICY
	count        = var.endpoints.dynamodb == true ? 1 : 0
	tags = {
		Name = "spokeVPC_dynamodb"
		Environment = var.environment_type
	}
}

#-----------------------------------------------------------------------------------------------------------------
# VPC DynamoDB Endpoint Route Table Association 
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint_route_table_association" "dynamodb_ep_association" { 
	depends_on 	  = [aws_vpc_endpoint.dynamodb_ep]
	count = var.endpoints.dynamodb == true ? 1 : 0
	route_table_id  = var.route_table_id
	vpc_endpoint_id = aws_vpc_endpoint.dynamodb_ep[0].id
}

#-----------------------------------------------------------------------------------------------------------------

# EC2 Endpoint
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ec2_endpoint" {
	vpc_id            = var.vpc_id
	service_name      = "com.amazonaws.${var.aws_region}.ec2"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids
	policy = <<POLICY
		{
		 "Statement": [
			{
					"Action": ["ec2:*"],
					"Effect": "Allow",
					"Principal":{"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
					"Resource": "*"
			},
			{
					"Action": [
							"ec2:CreateVolume"
					],
					"Effect": "Deny",
					"Principal":{"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
					"Resource": "*",
					"Condition": {
							"Bool": {
									"ec2:Encrypted": "false"
							}
					}
			},
			{
					"Action": [
							"ec2:RunInstances"
					],
					"Effect": "Deny",
					"Principal":{"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
					"Resource": "*",
					"Condition": {
							"Bool": {
									"ec2:Encrypted": "false"
							}
					}
			}]
	 
		}
		POLICY
	count        = var.endpoints.ec2 == true ? 1 : 0
	security_group_ids = [
		var.endpoint_security_group,
	]

	private_dns_enabled = var.enable_private_dns
	tags = {
		Name = "spokeVPC_ec2"
		Environment = var.environment_type
	}
}



# EC2 Messages Endpoint
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ec2messages_endpoint" {
	vpc_id            = var.vpc_id
	service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids
	security_group_ids = [
		var.endpoint_security_group,
	]

	private_dns_enabled = var.enable_private_dns
	count        = var.endpoints.ec2_messages == true ? 1 : 0
	tags = {
		Name = "spokeVPC_ec2_messages"
		Environment = var.environment_type
	}
}

# SSM Messages Endpoint
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ssmmessages_endpoint" {
	vpc_id            = var.vpc_id
	service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids

	security_group_ids = [
		var.endpoint_security_group,
	]

	private_dns_enabled = var.enable_private_dns
	count        = var.endpoints.ssm_messages == true ? 1 : 0
	tags = {
		Name = "spokeVPC_ssm_messages"
		Environment = var.environment_type 
	}
}


# SSM Endpoint
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ssm_endpoint" {
	vpc_id            = var.vpc_id
	service_name      = "com.amazonaws.${var.aws_region}.ssm"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids

	security_group_ids = [
		var.endpoint_security_group,
	]

	private_dns_enabled = var.enable_private_dns
	count        = var.endpoints.ssm == true ? 1 : 0
	tags = {
		Name = "spokeVPC_ssm"
		Environment = var.environment_type
	}
}

# KMS Endpoint 
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "kms_endpoint" {
	vpc_id            = var.vpc_id
	service_name      = "com.amazonaws.${var.aws_region}.kms"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids

	security_group_ids = [
		var.endpoint_security_group,
	]

	private_dns_enabled = var.enable_private_dns
	count        = var.endpoints.kms == true ? 1 : 0
	tags = {
		Name = "spokeVPC_kms"
		Environment = var.environment_type
	}
}

# Secrets Manager Endpoint 
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "secretsmanager_endpoint" {
	vpc_id        = var.vpc_id
	service_name  = "com.amazonaws.${var.aws_region}.secretsmanager"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids

	security_group_ids = [
		var.endpoint_security_group,
	]
	private_dns_enabled = var.enable_private_dns
	policy = <<POLICY
		{
		 "Statement": [{
								"Effect": "Allow",
								"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
								"Action": [
									"secretsmanager:DescribeSecret",
									"secretsmanager:GetRandomPassword",
									"secretsmanager:GetSecretValue",
                                    "secretsmanager:ListSecretVersionIds",
                                    "secretsmanager:ListSecretVersionIds",
                                    "secretsmanager:CancelRotateSecret",
                                    "secretsmanager:CreateSecret",
                                    "secretsmanager:DeleteResourcePolicy",
                                    "secretsmanager:DeleteSecret",
                                    "secretsmanager:GetRandomPassword",
                                    "secretsmanager:GetResourcePolicy",
                                    "secretsmanager:GetSecretValue",
                                    "secretsmanager:ListSecrets",
                                    "secretsmanager:ListSecretVersionIds",
                                    "secretsmanager:PutResourcePolicy",
                                    "secretsmanager:PutSecretValue",
                                    "secretsmanager:RemoveRegionsFromReplication",
                                    "secretsmanager:ReplicateSecretToRegions",
                                    "secretsmanager:RestoreSecret",
                                    "secretsmanager:RotateSecret",
                                    "secretsmanager:StopReplicationToReplica",
                                    "secretsmanager:UpdateSecret",
                                    "secretsmanager:UpdateSecretVersionStage"
								],
								"Resource": ["arn:aws:secretsmanager::${data.aws_caller_identity.current.account_id}:*"]
						}]
	 
		}
		POLICY
	count        = var.endpoints.secrets_manager == true ? 1 : 0
	tags = {
		Name = "spokeVPC_secrets_manager"
		Environment = var.environment_type
	}
}


# ECS Endpoint 
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ecs_endpoint" {
	vpc_id        = var.vpc_id
	service_name  = "com.amazonaws.${var.aws_region}.ecs"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids

	security_group_ids = [
		var.endpoint_security_group,
	]
	private_dns_enabled = var.enable_private_dns
	count        = var.endpoints.ecs == true ? 1 : 0
	tags = {
		Name = "spokeVPC_ecs"
		Environment = var.environment_type
	}
}

# ECS Agent Endpoint 
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ecs_agent_endpoint" {
	vpc_id        = var.vpc_id
	service_name  = "com.amazonaws.${var.aws_region}.ecs-agent"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids

	security_group_ids = [
		var.endpoint_security_group,
	]
	private_dns_enabled = var.enable_private_dns
	count        = var.endpoints.ecs_agent == true ? 1 : 0
	tags = {
		Name = "spokeVPC_ecs_agent"
		Environment = var.environment_type
	}
}

# ECS Telemetry
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ecs_telemetry_endpoint" {
	vpc_id        = var.vpc_id
	service_name  = "com.amazonaws.${var.aws_region}.ecs-telemetry"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids

	security_group_ids = [
		var.endpoint_security_group,
	]
	private_dns_enabled = var.enable_private_dns
	count        = var.endpoints.ecs_telemetry == true ? 1 : 0
	tags = {
		Name = "spokeVPC_ecs_telemetry"
		Environment = var.environment_type
	}
}


# SNS Endpoint 
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sns_endpoint" {
	vpc_id        = var.vpc_id
	service_name  = "com.amazonaws.${var.aws_region}.sns"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids

	policy = <<POLICY
		{
		 "Statement": [{
								"Effect": "Allow",
								"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
								"Action": [
									"sns:Subscribe",
									"sns:Unsubscribe",
									"sns:Publish",
									"sns:ListTopics"
								],
								"Resource": ["arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
						}]
	 
		}
		POLICY
	count        = var.endpoints.sns == true ? 1 : 0
	security_group_ids = [
		var.endpoint_security_group,
	]
	private_dns_enabled = var.enable_private_dns
	tags = {
		Name = "spokeVPC_sns"
		Environment = var.environment_type
	}
}

# SQS Endpoint 
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sqs_endpoint" {
	vpc_id        = var.vpc_id
	service_name  = "com.amazonaws.${var.aws_region}.sqs"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids

	security_group_ids = [
		var.endpoint_security_group,
	]
	private_dns_enabled = var.enable_private_dns
	policy = <<POLICY
		{
		 "Statement": [{
								"Effect": "Allow",
								"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
								"Action": [
									"sqs:ListQueues",
									"sqs:ListQueueTags",
									"sqs:ReceiveMessage",
									"sqs:SendMessageBatch",
									"sqs:SendMessage",
									"sqs:GetQueueUrl",
									"sqs:GetQueueAttributes",
									"sqs:DeleteMessage",
									"sqs:ChangeMessageVisibility",
									"sqs:ChangeMessageVisibilityBatch"
								],
								"Resource": ["arn:aws:sqs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
						}]
	 
		}
		POLICY
	count        = var.endpoints.sqs == true ? 1 : 0
	tags = {
		Name = "spokeVPC_sqs"
		Environment = var.environment_type
	}
}

# STS Endpoint
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "sts_endpoint" {
	vpc_id        = var.vpc_id
	service_name  = "com.amazonaws.${var.aws_region}.sts"
	vpc_endpoint_type = "Interface"
	subnet_ids = var.endpoint_subnet_ids
	
	security_group_ids = [
		var.endpoint_security_group,
	]
	private_dns_enabled = var.enable_private_dns
	policy = <<POLICY
		{
		 "Statement": [{
								"Effect": "Allow",
								"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
								"Action": "*",
								"Resource": ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:*"]
						}]
	 
		}
		POLICY
	count        = var.endpoints.sts == true ? 1 : 0
	tags = {
		Name = "spokeVPC_sts"
		Environment = var.environment_type
	}
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Transit Gateway | This module submits a TGW association request then automatically configure TGW route tables
# ---------------------------------------------------------------------------------------------------------------
module "terraform-aws-fsf-interface-endpoint-private-hosted-zone-creation" {
	source                                		= "./interface_endpoint_private_hosted_zones"
	create_private_hosted_zones_for_endpoints 	= var.create_private_hosted_zones_for_endpoints
	enable_private_dns 							= var.enable_private_dns
	aws_region 									= var.aws_region
	vpc_id 										= var.vpc_id
	endpoints 									= var.endpoints
	api_x_key 									= var.api_x_key
	ec2_endpoint_dns_hostname 					= concat(aws_vpc_endpoint.ec2_endpoint.*.dns_entry.0.dns_name, [null])[0]
	ec2_endpoint_dns_zone_id 					= concat(aws_vpc_endpoint.ec2_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	ec2_messages_endpoint_dns_hostname 			= concat(aws_vpc_endpoint.ec2messages_endpoint.*.dns_entry.0.dns_name, [null])[0]
	ec2_messages_endpoint_dns_zone_id 			= concat(aws_vpc_endpoint.ec2messages_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	ecs_endpoint_dns_hostname 					= concat(aws_vpc_endpoint.ecs_endpoint.*.dns_entry.0.dns_name, [null])[0]
	ecs_endpoint_dns_zone_id 					= concat(aws_vpc_endpoint.ecs_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	ecs_agent_endpoint_dns_hostname 			= concat(aws_vpc_endpoint.ecs_agent_endpoint.*.dns_entry.0.dns_name, [null])[0]
	ecs_agent_endpoint_dns_zone_id 				= concat(aws_vpc_endpoint.ecs_agent_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	ecs_telemetry_endpoint_dns_hostname 		= concat(aws_vpc_endpoint.ecs_telemetry_endpoint.*.dns_entry.0.dns_name, [null])[0]
	ecs_telemetry_endpoint_dns_zone_id 			= concat(aws_vpc_endpoint.ecs_telemetry_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	sts_endpoint_dns_hostname 					= concat(aws_vpc_endpoint.sts_endpoint.*.dns_entry.0.dns_name, [null])[0]
	sts_endpoint_dns_zone_id 					= concat(aws_vpc_endpoint.sts_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	sns_endpoint_dns_hostname 					= concat(aws_vpc_endpoint.sns_endpoint.*.dns_entry.0.dns_name, [null])[0]
	sns_endpoint_dns_zone_id 					= concat(aws_vpc_endpoint.sns_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	sqs_endpoint_dns_hostname 					= concat(aws_vpc_endpoint.sqs_endpoint.*.dns_entry.0.dns_name, [null])[0]
	sqs_endpoint_dns_zone_id 					= concat(aws_vpc_endpoint.sqs_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	ssm_endpoint_dns_hostname 					= concat(aws_vpc_endpoint.ssm_endpoint.*.dns_entry.0.dns_name, [null])[0]
	ssm_endpoint_dns_zone_id 					= concat(aws_vpc_endpoint.ssm_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	ssm_messages_endpoint_dns_hostname 			= concat(aws_vpc_endpoint.ssmmessages_endpoint.*.dns_entry.0.dns_name, [null])[0]
	ssm_messages_endpoint_dns_zone_id 			= concat(aws_vpc_endpoint.ssmmessages_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	kms_endpoint_dns_hostname 					= concat(aws_vpc_endpoint.kms_endpoint.*.dns_entry.0.dns_name, [null])[0]
	kms_endpoint_dns_zone_id 					= concat(aws_vpc_endpoint.kms_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]
	secrets_manager_endpoint_dns_hostname 		= concat(aws_vpc_endpoint.secretsmanager_endpoint.*.dns_entry.0.dns_name, [null])[0]
	secrets_manager_endpoint_dns_zone_id 		= concat(aws_vpc_endpoint.secretsmanager_endpoint.*.dns_entry.0.hosted_zone_id, [null])[0]

}