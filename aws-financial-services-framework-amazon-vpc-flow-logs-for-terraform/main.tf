# Adding a data source for the provision account number
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  timestamp = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[- TZ:]/", "")
}


resource "random_uuid" "uuid_a" { }
resource "random_uuid" "uuid_b" { }
resource "random_uuid" "uuid_c" { }

resource "aws_cloudwatch_log_group" "vpc_flowlog_cloudwatch_log_group" {
  name  =  join("_", ["vpc_flow_log", random_uuid.uuid_a.result])
  count = var.enabled == true ? 1 : 0
}

resource "aws_iam_role" "vpc_flowlog_cloudwatch_role" {
  name  = join("_", ["flow_log_cw_log_role", random_uuid.uuid_a.result])
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
  name  = join("_", ["loggingpolicy", random_uuid.uuid_a.result])
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
  vpc_id          = var.vpc_id
}