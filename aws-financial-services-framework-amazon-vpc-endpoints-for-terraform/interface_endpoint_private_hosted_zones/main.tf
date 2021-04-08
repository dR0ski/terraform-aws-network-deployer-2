


# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "random_uuid" "uuid_lambda" { }

# ----------------------------------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "ec2_endpoint_phz" {
  name = "ec2.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ec2 == true  ? 1 : 0)
}

resource "aws_route53_record" "ec2_endpoint_a_record" {
  zone_id = aws_route53_zone.ec2_endpoint_phz[count.index].zone_id
  name    = "ec2.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ec2_endpoint_dns_hostname
    zone_id                = var.ec2_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ec2 == true  ? 1 : 0)

}
# ----------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "ec2_messages_endpoint_phz" {
  name = "ec2_messages.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ec2_messages == true  ? 1 : 0)
}

resource "aws_route53_record" "ec2_messages_endpoint_a_record" {
  zone_id = aws_route53_zone.ec2_messages_endpoint_phz[count.index].zone_id
  name    = "ec2_messages.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ec2_messages_endpoint_dns_hostname
    zone_id                = var.ec2_messages_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ec2_messages == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "ecs_endpoint_phz" {
  name = "ecs.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ecs == true  ? 1 : 0)

}

resource "aws_route53_record" "ecs_endpoint_a_record" {
  zone_id = aws_route53_zone.ecs_endpoint_phz[count.index].zone_id
  name    = "ecs.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ecs_endpoint_dns_hostname
    zone_id                = var.ecs_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ecs == true  ? 1 : 0)

}
# ----------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "ecs_agent_endpoint_phz" {
  name = "ecs_agent.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ecs_agent == true  ? 1 : 0)
}

resource "aws_route53_record" "ecs_agent_endpoint_a_record" {
  zone_id = aws_route53_zone.ecs_agent_endpoint_phz[count.index].zone_id
  name    = "ecs_agent.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ecs_agent_endpoint_dns_hostname
    zone_id                = var.ecs_agent_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ecs_agent == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "ecs_telemetry_endpoint_phz" {
  name = "ecs_telemetry.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ecs_telemetry == true  ? 1 : 0)
}

resource "aws_route53_record" "ecs_telemetry_endpoint_a_record" {
  zone_id = aws_route53_zone.ecs_telemetry_endpoint_phz[count.index].zone_id
  name    = "ecs_telemetry.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ecs_telemetry_endpoint_dns_hostname
    zone_id                = var.ecs_telemetry_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ecs_telemetry == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "sts_endpoint_phz" {
  name = "sts.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.sts == true  ? 1 : 0)
}

resource "aws_route53_record" "sts_a_record" {
  zone_id = aws_route53_zone.sts_endpoint_phz[count.index].zone_id
  name    = "sts.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.sts_endpoint_dns_hostname
    zone_id                = var.sts_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.sts == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "sns_endpoint_phz" {
  name = "sns.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.sns == true  ? 1 : 0)
}

resource "aws_route53_record" "sns_a_record" {
  zone_id = aws_route53_zone.sns_endpoint_phz[count.index].zone_id
  name    = "sns.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.sns_endpoint_dns_hostname
    zone_id                = var.sns_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.sns == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "sqs_endpoint_phz" {
  name = "sqs.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.sqs == true  ? 1 : 0)
}

resource "aws_route53_record" "sqs_a_record" {
  zone_id = aws_route53_zone.sqs_endpoint_phz[count.index].zone_id
  name    = "sqs.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.sqs_endpoint_dns_hostname
    zone_id                = var.sqs_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.sqs == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "kms_endpoint_phz" {
  name = "kms.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.kms == true  ? 1 : 0)
}

resource "aws_route53_record" "kms_a_record" {
  zone_id = aws_route53_zone.kms_endpoint_phz[count.index].zone_id
  name    = "kms.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.kms_endpoint_dns_hostname
    zone_id                = var.kms_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.kms == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "ssm_endpoint_phz" {
  name = "ssm.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ssm == true  ? 1 : 0)
}

resource "aws_route53_record" "ssm_a_record" {
  zone_id = aws_route53_zone.ssm_endpoint_phz[count.index].zone_id
  name    = "ssm.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ssm_endpoint_dns_hostname
    zone_id                = var.ssm_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ssm == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "ssm_messages_endpoint_phz" {
  name = "ssm_messages.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ssm_messages == true  ? 1 : 0)
}

resource "aws_route53_record" "ssm_messages_a_record" {
  zone_id = aws_route53_zone.ssm_messages_endpoint_phz[count.index].zone_id
  name    = "ssm_messages.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.ssm_messages_endpoint_dns_hostname
    zone_id                = var.ssm_messages_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.ssm_messages == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "secrets_manager_endpoint_phz" {
  name = "secrets_manager.${var.aws_region}.amazonaws.com"
  comment = var.private_hosted_zone_comment
  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.secrets_manager == true  ? 1 : 0)
}

resource "aws_route53_record" "secrets_manager_a_record" {
  zone_id = aws_route53_zone.secrets_manager_endpoint_phz[count.index].zone_id
  name    = "secrets_manager.${var.aws_region}.amazonaws.com"
  type    = "A"

  alias {
    name                   = var.secrets_manager_endpoint_dns_hostname
    zone_id                = var.secrets_manager_endpoint_dns_zone_id
    evaluate_target_health = true
  }
  count = (var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false && var.endpoints.secrets_manager == true  ? 1 : 0)
}
# ----------------------------------------------------------------------------------------------------------------------------------------------

data "archive_file" "zip"{
  type = "zip"
  source_file = "${path.module}/lambda_function.py" #"lambda_function.py"
  output_path = "${path.module}/lambda_function.zip" #"lambda_function.zip"
  count = var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false ? 1:0

}

locals {
  timestamp = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[- TZ:]/", "")
}


resource "aws_iam_policy" "route53_policy" {
  name = join("_", ["shared_svc_route53_actions", random_uuid.uuid_lambda.result])
  description = "IAM policy that allows Route 53 Private Hosted Zones to be listed and VPCs assciated."
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:AssociateVPCWithHostedZone",
        "route53:CreateVPCAssociationAuthorization",
        "route53:GetHostedZone",
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:GetHostedZoneCount",
        "route53:ListHostedZonesByName"
      ],
      "Resource": "*"
}]
}
EOF

  count = var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false ? 1:0
}
resource "aws_iam_role" "iam_for_lambda" {
  name = join("_", ["shared_svc_route53_assoc_fn", random_uuid.uuid_lambda.result])
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_iam_role_policy_attachment" "Route53ExecutionRole" {
  count = var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false ? 1:0
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.route53_policy[count.index].arn
}

resource "aws_lambda_function" "route53_association_lambda" {
  count = var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false ? 1:0

  filename      = data.archive_file.zip[count.index].output_path
  function_name = join("_", ["route53_assoc_fn", random_uuid.uuid_lambda.result])
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.zip[count.index].output_base64sha256
  runtime = "python3.8"
  timeout = 900
  memory_size = 512

//  environment {
//    variables = {
//      ec2_private_hosted_zone_id = aws_route53_zone.ec2_endpoint_phz[0].zone_id
//      ec2_messages_private_hosted_zone_id = aws_route53_zone.ec2_messages_endpoint_phz[0].zone_id
//      ecs_private_hosted_zone_id = aws_route53_zone.ecs_endpoint_phz[0].zone_id
//      ecs_agent_private_hosted_zone_id = aws_route53_zone.ecs_agent_endpoint_phz[0].zone_id
//      ecs_telemetry_private_hosted_zone_id = aws_route53_zone.ecs_telemetry_endpoint_phz[0].zone_id
//      sts_private_hosted_zone_id = aws_route53_zone.sts_endpoint_phz[0].zone_id
//      sns_private_hosted_zone_id = aws_route53_zone.sns_endpoint_phz[0].zone_id
//      sqs_private_hosted_zone_id =  aws_route53_zone.sqs_endpoint_phz[0].zone_id
//      secrets_manager_private_hosted_zone_id = aws_route53_zone.secrets_manager_endpoint_phz[0].zone_id
//      kms_private_hosted_zone_id = aws_route53_zone.kms_endpoint_phz[0].zone_id
//      ssm_private_hosted_zone_id =   aws_route53_zone.ssm_endpoint_phz[0].zone_id
//      ssm_messages_private_hosted_zone_id = aws_route53_zone.ssm_messages_endpoint_phz[0].zone_id
//        blue = "color"
//    }
//  }
}

# ----------------------------------------------------------------------------------------------------------
resource "aws_api_gateway_api_key" "route53_x_api_key" {
  name = base64sha512( join("_", [var.api_x_key, random_uuid.uuid_lambda.result]))
}


# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "route53_association_api"
}


resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}


resource "aws_api_gateway_request_validator" "validator_query" {
  name                        = "queryValidator"
  rest_api_id                 = aws_api_gateway_rest_api.api.id
  validate_request_body       = false
  validate_request_parameters = true
}


resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy"        = false
    "method.request.querystring.aws_region" = true
    "method.request.querystring.vpc_id" = true
  }

  request_validator_id = aws_api_gateway_request_validator.validator_query.id
  api_key_required = true
}


resource "aws_api_gateway_integration" "integration" {
  count = var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false ? 1:0
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.route53_association_lambda[count.index].invoke_arn
}


# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  count = var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false ? 1:0
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.route53_association_lambda[count.index].function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}


resource "aws_api_gateway_deployment" "route53_api_deployment" {
  count = var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false ? 1:0
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "dev"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_usage_plan" "route53_api_usage_plan" {
  count = var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false ? 1:0
  name = "usage_${aws_api_gateway_rest_api.api.name}"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_deployment.route53_api_deployment[count.index].stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "route53_association_api_usage_plan_key" {
  count = var.create_private_hosted_zones_for_endpoints == true && var.enable_private_dns == false ? 1:0
  key_id        = aws_api_gateway_api_key.route53_x_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.route53_api_usage_plan[count.index].id
}

