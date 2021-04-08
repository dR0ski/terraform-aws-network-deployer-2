# Adding a data source for the provision account number
data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.aws_region
  version = "~> 2.7"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_cloudwatch_log_group" "vpc_flowlog_cloudwatch_log_group" {
  name  = "vpc_flow_log"
  count = var.enabled == true ? 1 : 0
}

//Create a VPC for unit tests.
resource "aws_vpc" "unit-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_iam_role" "vpc_flowlog_cloudwatch_role" {
  name  = "vpc_flowlog_cloudwatch_log_role"
  count = var.enabled == true ? 1 : 0
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cwlogpolicy" {
  name  = "loggingpolicy"
  count = var.enabled == true ? 1 : 0
  role  = aws_iam_role.vpc_flowlog_cloudwatch_role[count.index].name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*"

          ]
    }
  ]
}
EOF
}

resource "aws_flow_log" "flowlog" {
  count = var.enabled == true ? 1 : 0
  iam_role_arn    = aws_iam_role.vpc_flowlog_cloudwatch_role[count.index].arn
  log_destination = aws_cloudwatch_log_group.vpc_flowlog_cloudwatch_log_group[count.index].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.unit-vpc.id
}