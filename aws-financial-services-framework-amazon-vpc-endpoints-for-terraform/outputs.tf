# --------------------------------------------------------------------------------------
# VPC Endpoint IDs
# --------------------------------------------------------------------------------------
output "vpc_endpoint_s3" {
  value = concat(aws_vpc_endpoint.s3_ep.*.id)
}

output "vpc_endpoint_dynamodb" {
  value = concat(aws_vpc_endpoint.dynamodb_ep.*.id)
}

output "vpc_endpoint_ec2" {
  value = concat(aws_vpc_endpoint.ec2_endpoint.*.id)
}

output "vpc_endpoint_sqs" {
  value = concat(aws_vpc_endpoint.sqs_endpoint.*.id)
}

output "vpc_endpoint_sns" {
  value = concat(aws_vpc_endpoint.sns_endpoint.*.id)
}

output "vpc_endpoint_kms" {
  value = concat(aws_vpc_endpoint.kms_endpoint.*.id)
}

output "vpc_endpoint_secrets_manager" {
  value = concat(aws_vpc_endpoint.secretsmanager_endpoint.*.id)
}

output "vpc_endpoint_sts" {
  value = concat(aws_vpc_endpoint.sts_endpoint.*.id)
}

# --------------------------------------------------------------------------------------
# VPC Endpoint IDs
# --------------------------------------------------------------------------------------
output "vpc_endpoint_ec2_dns_hostname" {
  value = concat(aws_vpc_endpoint.ec2_endpoint.*.dns_entry.0.dns_name)
}

output "vpc_endpoint_ec2_dns_hosted_zone_id" {
  # value = aws_vpc_endpoint.ec2_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.ec2_endpoint.*.dns_entry.0.hosted_zone_id)
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
output "ec2_messages_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.ec2messages_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.ec2messages_endpoint.*.dns_entry.0.dns_name)
}

output "ec2_messages_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.ec2messages_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.ec2messages_endpoint.*.dns_entry.0.hosted_zone_id)
}


# ----------------------------------------------------------------------------------------------------------------------------------------------
output "ecs_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.ecs_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.ecs_endpoint.*.dns_entry.0.dns_name)
}

output "ecs_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.ecs_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.ecs_endpoint.*.dns_entry.0.hosted_zone_id)
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
output "ecs_agent_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.ecs_agent_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.ecs_agent_endpoint.*.dns_entry.0.dns_name)
}

output "ecs_agent_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.ecs_agent_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.ecs_agent_endpoint.*.dns_entry.0.hosted_zone_id)
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
output "ecs_telemetry_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.ecs_telemetry_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.ecs_telemetry_endpoint.*.dns_entry.0.dns_name)
}

output "ecs_telemetry_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.ecs_telemetry_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.ecs_telemetry_endpoint.*.dns_entry.0.hosted_zone_id)
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
output "sts_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.sts_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.sts_endpoint.*.dns_entry.0.dns_name)
}

output "sts_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.sts_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.sts_endpoint.*.dns_entry.0.hosted_zone_id)
}


# ----------------------------------------------------------------------------------------------------------------------------------------------
output "sns_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.sns_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.sns_endpoint.*.dns_entry.0.dns_name)
}

output "sns_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.sns_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.sns_endpoint.*.dns_entry.0.hosted_zone_id)
}


# ----------------------------------------------------------------------------------------------------------------------------------------------
output "sqs_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.sqs_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.sqs_endpoint.*.dns_entry.0.dns_name)
}

output "sqs_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.sqs_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.sqs_endpoint.*.dns_entry.0.hosted_zone_id)
}


# ----------------------------------------------------------------------------------------------------------------------------------------------
output "ssm_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.ssm_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.ssm_endpoint.*.dns_entry.0.dns_name)
}

output "ssm_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.ssm_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.ssm_endpoint.*.dns_entry.0.hosted_zone_id)
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
output "ssm_messages_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.ssmmessages_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.ssmmessages_endpoint.*.dns_entry.0.dns_name)
}

output "ssm_messages_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.ssmmessages_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.ssmmessages_endpoint.*.dns_entry.0.hosted_zone_id)
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
output "kms_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.kms_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.kms_endpoint.*.dns_entry.0.dns_name)
}

output "kms_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.kms_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.kms_endpoint.*.dns_entry.0.hosted_zone_id)
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
output "secrets_manager_endpoint_dns_hostname" {
  # value    = aws_vpc_endpoint.secretsmanager_endpoint[0].dns_entry.0.dns_name
  value = concat(aws_vpc_endpoint.secretsmanager_endpoint.*.dns_entry.0.dns_name)
}

output "secrets_manager_endpoint_dns_zone_id" {
  # value    = aws_vpc_endpoint.secretsmanager_endpoint[0].dns_entry.0.hosted_zone_id
  value = concat(aws_vpc_endpoint.secretsmanager_endpoint.*.dns_entry.0.hosted_zone_id)
}

# ----------------------------------------------------------------------------------------------------------------------------------------------
output "api_x_key" {
  value = module.terraform-aws-fsf-interface-endpoint-private-hosted-zone-creation.api_x_key_output
}

