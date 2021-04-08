data "aws_caller_identity" "current" {}

# Declare the data source
# ---------------------------------------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
	state = "available"
}
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
	profile   = "default"
	region    = "eu-west-3"
}



# The Spoke VPC creation
# ---------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "spoke_vpc" {
	cidr_block                            = var.vpc_cidr_block
	instance_tenancy                      = var.instance_tenancy
	enable_dns_support                    = var.dns_support
	enable_dns_hostnames                  = var.dns_host_names
	assign_generated_ipv6_cidr_block      = var.enable_aws_ipv6_cidr_block
}

# Externally Routable Subnet Declaration
# ---------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "externally_routable_subnet" {
	count = length(var.public_subnets)>0 ? 1:0
	vpc_id                                  = aws_vpc.spoke_vpc.id
	cidr_block                              = var.public_subnets[count.index]
	availability_zone                       = data.aws_availability_zones.available.names[count.index]
	assign_ipv6_address_on_creation         = var.assign_ipv6_address_on_creation
	map_public_ip_on_launch                 = var.map_public_ip_on_launch

	tags = {
		Name = "Externally_Routable_Subnet_${count.index}"
		Type = "Externally_Routable_Subnet_UNIT_TEST"
		Environment = var.environment_type
	}

}

# Creates VPC Routing Table(s)
# ---------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "private-routing-table" {
	vpc_id =  aws_vpc.spoke_vpc.id
	tags = {
		Name = "AWS_Routing_Table_UNIT_TEST"
		Type = "AWS_Routable"
		Environment = var.environment_type
	}
}

# Creates VPC Security Group
# ---------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "endpoint_security_group" {
	name        = "allow_tls"
	description = "Allow TLS inbound traffic"
	vpc_id      = aws_vpc.spoke_vpc.id

	ingress {
		description = "ALL Traffic for VPC CIDRs"
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = [aws_vpc.spoke_vpc.cidr_block]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "ALL Traffic for VPC CIDRs"
	}
}


# VPC Endpoints
# ---------------------------------------------------------------------------------------------------------------

# S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3_ep" {
	vpc_id        =  aws_vpc.spoke_vpc.id
	service_name  = "com.amazonaws.${var.aws_region}.s3"
	policy = <<POLICY
		{
		 "Statement": [{
								"Effect": "Allow",
								"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
								"Action": [
									 "s3:ListAllMyBuckets",
									 "s3:ListBucket",
									 "s3:GetObject",
									 "s3:GetObjectVersion",
									 "s3:PutObject"
								],
								"Resource": [
									"arn:aws:s3:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*",
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
	count        = var.endpoints.s3_gateway == true ? 1 : 0
	route_table_id  = aws_route_table.private-routing-table.id
	vpc_endpoint_id = aws_vpc_endpoint.s3_ep[0].id

}
#-----------------------------------------------------------------------------------------------------------------


# DynamoDB VPC Endpoint
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "dynamodb_ep" {
	vpc_id        =  aws_vpc.spoke_vpc.id
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
	count        = var.endpoints.dynamodb == true ? 1 : 0
	route_table_id  = aws_route_table.private-routing-table.id
	vpc_endpoint_id = aws_vpc_endpoint.dynamodb_ep[0].id



}
#-----------------------------------------------------------------------------------------------------------------

# EC2 Endpoint
#-----------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "ec2_endpoint" {
	vpc_id            =  aws_vpc.spoke_vpc.id
	service_name      = "com.amazonaws.${var.aws_region}.ec2"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]
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
		aws_security_group.endpoint_security_group.id
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
	vpc_id            =  aws_vpc.spoke_vpc.id
	service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]
	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
	vpc_id            =  aws_vpc.spoke_vpc.id
	service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
	vpc_id            =  aws_vpc.spoke_vpc.id
	service_name      = "com.amazonaws.${var.aws_region}.ssm"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
	vpc_id            =  aws_vpc.spoke_vpc.id
	service_name      = "com.amazonaws.${var.aws_region}.kms"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
	vpc_id        =  aws_vpc.spoke_vpc.id
	service_name  = "com.amazonaws.${var.aws_region}.secretsmanager"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
									"secretsmanager:ListSecrets",
									"secretsmanager:ListSecretVersionIds"
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
	vpc_id        =  aws_vpc.spoke_vpc.id
	service_name  = "com.amazonaws.${var.aws_region}.ecs"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
	vpc_id        =  aws_vpc.spoke_vpc.id
	service_name  = "com.amazonaws.${var.aws_region}.ecs-agent"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
	vpc_id        =  aws_vpc.spoke_vpc.id
	service_name  = "com.amazonaws.${var.aws_region}.ecs-telemetry"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
	vpc_id        =  aws_vpc.spoke_vpc.id
	service_name  = "com.amazonaws.${var.aws_region}.sns"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

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
		aws_security_group.endpoint_security_group.id
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
	vpc_id        =  aws_vpc.spoke_vpc.id
	service_name  = "com.amazonaws.${var.aws_region}.sqs"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
	vpc_id        =  aws_vpc.spoke_vpc.id
	service_name  = "com.amazonaws.${var.aws_region}.sts"
	vpc_endpoint_type = "Interface"
	subnet_ids = [aws_subnet.externally_routable_subnet[count.index].id]

	security_group_ids = [
		aws_security_group.endpoint_security_group.id
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
	vpc_id 										= aws_vpc.spoke_vpc.id
	endpoints 									= var.endpoints
	ec2_endpoint_dns_hostname 					= aws_vpc_endpoint.ec2_endpoint[0].dns_entry.0.dns_name
	ec2_endpoint_dns_zone_id 					= aws_vpc_endpoint.ec2_endpoint[0].dns_entry.0.hosted_zone_id
	ec2_messages_endpoint_dns_hostname 			= aws_vpc_endpoint.ec2messages_endpoint[0].dns_entry.0.dns_name
	ec2_messages_endpoint_dns_zone_id 			= aws_vpc_endpoint.ec2messages_endpoint[0].dns_entry.0.hosted_zone_id
	ecs_endpoint_dns_hostname 					= aws_vpc_endpoint.ecs_endpoint[0].dns_entry.0.dns_name
	ecs_endpoint_dns_zone_id 					= aws_vpc_endpoint.ecs_endpoint[0].dns_entry.0.hosted_zone_id
	ecs_agent_endpoint_dns_hostname 			= aws_vpc_endpoint.ecs_agent_endpoint[0].dns_entry.0.dns_name
	ecs_agent_endpoint_dns_zone_id 				= aws_vpc_endpoint.ecs_agent_endpoint[0].dns_entry.0.hosted_zone_id
	ecs_telemetry_endpoint_dns_hostname 		= aws_vpc_endpoint.ecs_telemetry_endpoint[0].dns_entry.0.dns_name
	ecs_telemetry_endpoint_dns_zone_id 			= aws_vpc_endpoint.ecs_telemetry_endpoint[0].dns_entry.0.hosted_zone_id
	sts_endpoint_dns_hostname 					= aws_vpc_endpoint.sts_endpoint[0].dns_entry.0.dns_name
	sts_endpoint_dns_zone_id 					= aws_vpc_endpoint.sts_endpoint[0].dns_entry.0.hosted_zone_id
	sns_endpoint_dns_hostname 					= aws_vpc_endpoint.sns_endpoint[0].dns_entry.0.dns_name
	sns_endpoint_dns_zone_id 					= aws_vpc_endpoint.sns_endpoint[0].dns_entry.0.hosted_zone_id
	sqs_endpoint_dns_hostname 					= aws_vpc_endpoint.sqs_endpoint[0].dns_entry.0.dns_name
	sqs_endpoint_dns_zone_id 					= aws_vpc_endpoint.sqs_endpoint[0].dns_entry.0.hosted_zone_id
	ssm_endpoint_dns_hostname 					= aws_vpc_endpoint.ssm_endpoint[0].dns_entry.0.dns_name
	ssm_endpoint_dns_zone_id 					= aws_vpc_endpoint.ssm_endpoint[0].dns_entry.0.hosted_zone_id
	ssm_messages_endpoint_dns_hostname 			= aws_vpc_endpoint.ssmmessages_endpoint[0].dns_entry.0.dns_name
	ssm_messages_endpoint_dns_zone_id 			= aws_vpc_endpoint.ssmmessages_endpoint[0].dns_entry.0.hosted_zone_id
	kms_endpoint_dns_hostname 					= aws_vpc_endpoint.kms_endpoint[0].dns_entry.0.dns_name
	kms_endpoint_dns_zone_id 					= aws_vpc_endpoint.kms_endpoint[0].dns_entry.0.hosted_zone_id
	secrets_manager_endpoint_dns_hostname 		= aws_vpc_endpoint.secretsmanager_endpoint[0].dns_entry.0.dns_name
	secrets_manager_endpoint_dns_zone_id 		= aws_vpc_endpoint.secretsmanager_endpoint[0].dns_entry.0.hosted_zone_id
}