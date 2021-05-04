
# ----------------------------------------------------------------------------------------------------------------------------------------------
# AWS LAMBDA | AWS EventBridge EventBus passes the event payload to this FN. The function then completes the PHZ association process.
# EventBridge EventBus Events |
# ->
# ->
# ----------------------------------------------------------------------------------------------------------------------------------------------

data "aws_organizations_organization" "my_aws_organization" {}

# Object that contains a list of key value pairs that forms the tags added to a VPC on creation
# ---------------------------------------------------------------------------------------------------------------
resource "random_uuid" "uuid_a" { }

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


data "archive_file" "zip"{
  type = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}


locals {
  timestamp = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[- TZ:]/", "")
}


resource "aws_iam_policy" "route53_private_hosted_zone_assoc_policy" {
  name = join("_", ["${var.vpc_type}-phz-actions", random_uuid.uuid_a.result])    #   local.timestamp_sanitized
  description = "IAM policy that allows Route 53 Private Hosted Zones to be listed and VPCs assciated."
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "events:PutRule",
        "events:DeleteRule",
        "events:DescribeRule",
        "events:DisableRule",
        "events:EnableRule",
        "events:PutTargets",
        "events:RemoveTargets",
        "events:PutEvents"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals":
          {"aws:PrincipalOrgID": [ "${data.aws_organizations_organization.my_aws_organization.id}" ]
        }
      }
}]
}
EOF

}


resource "aws_iam_role" "iam_for_lambda" {
  name = join("_", ["${var.vpc_type}-phz-association", random_uuid.uuid_a.result])  # local.timestamp_sanitized
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
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.route53_private_hosted_zone_assoc_policy.arn
}

resource "aws_lambda_function" "route53_association_lambda" {

  filename      = data.archive_file.zip.output_path
  function_name = join("_", ["${var.vpc_type}-network-event-writer", random_uuid.uuid_a.result])  #  local.timestamp_sanitized
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.zip.output_base64sha256
  runtime = "python3.8"
  timeout = 900
  memory_size = 512
  tags = local.default_tags
}

# ----------------------------------------------------------------------------------------------------------