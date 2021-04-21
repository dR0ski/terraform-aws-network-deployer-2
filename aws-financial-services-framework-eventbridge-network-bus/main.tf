# ----------------------------------------------------------------------------------------------------------------------------------------------
# AWS LAMBDA | AWS EventBridge EventBus passes the event payload to this FN. The function then completes the PHZ association process.
# EventBridge EventBus Events |
# ->
# ->
# ----------------------------------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------
# Data source that extrapolates the Organizations ARN the account belongs to
# ---------------------------------------------------------------------------------------------------------------
data "aws_organizations_organization" "my_aws_organization" {}

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

locals {
  timestamp = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[- TZ:]/", "")
}


resource "aws_cloudwatch_event_bus" "network_event_bus" {
  name = "aws-fsf-network-operations-event-bus-${var.vpc_type}"
  tags = local.default_tags
}


resource "aws_cloudwatch_event_permission" "OrganizationAccess" {
  principal      = "*"
  statement_id   = "OrganizationAccess"
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  condition {
    key   = "aws:PrincipalOrgID"
    type  = "StringEquals"
    value = data.aws_organizations_organization.my_aws_organization.id
  }
}


# -----------------------------------------------------------------------------------------------------------------
# AWS EventBridge EventBus Rule | -> Rule for Associating Spoke PHZ with Shared/DNS VPC
# -----------------------------------------------------------------------------------------------------------------


resource "aws_cloudwatch_event_rule" "private-hosted-zone-association-initiated" {
  name           = "associate-with-private-hosted-zone-event"
  description    = "Event for initiating the association with spoke private hosted zone."
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  event_pattern  = <<EOF
{
  "source": ["aws-fsf-network-ops.associate-with-spoke-private-hosted-zone-event"]
}
EOF
}


resource "aws_cloudwatch_event_target" "complete_route53_phz_target" {
  rule           = aws_cloudwatch_event_rule.private-hosted-zone-association-initiated.name
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  target_id      = var.network-ops-lambda-fn-id   # aws_lambda_function.route53_association_lambda.id
  arn            = var.network-ops-lambda-fn-arn  # aws_lambda_function.route53_association_lambda.arn
}



# -----------------------------------------------------------------------------------------------------------------
# AWS EventBridge EventBus Rule |
# -----------------------------------------------------------------------------------------------------------------
# -> Rule for Associating Spoke VPC with the matching AWS TGW Route table
# -> Route table propagation is also performed
# -----------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "tgw_route_table_association_propagation_rule" {
  name           = "transit-gateway-route-table-association-n-propagation-rule"
  description    = "Routes events for a spoke VPC association with a matching AWS TGW route table."
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  event_pattern  = <<EOF
{
  "source": ["aws-fsf-network-ops.route-table-associate-n-route-propagation-event"]
}
EOF
}


resource "aws_cloudwatch_event_target" "tgw_route_table_association_propagation_target" {
  rule           = aws_cloudwatch_event_rule.tgw_route_table_association_propagation_rule.name
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  target_id      = var.network-ops-lambda-fn-id
  arn            = var.network-ops-lambda-fn-arn
}


# 'aws-fsf-network-ops.interface-endpoints-association-event'


# -----------------------------------------------------------------------------------------------------------------
# AWS EventBridge EventBus Rule | -> Rule for Initiating the Association of Spoke w/ Centralized Interface Endpoints
# -----------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "centralized-interface-endpoint-association-initiated-rule" {
  name           = "associate-spoke-vpc-with-centralized-interface-endpoints-rule"
  description    = "Event for initiating the association of spoke VPCs with centralized Interface VPC Endpoints."
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  event_pattern  = <<EOF
{
  "source": ["aws-fsf-network-ops.interface-endpoints-association-event"]
}
EOF
}


resource "aws_cloudwatch_event_target" "provide-spoke-vpc-with-available-endpoint-hosted-zone-id" {
  rule           = aws_cloudwatch_event_rule.centralized-interface-endpoint-association-initiated-rule.name
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  target_id      = var.network-ops-lambda-fn-id   # aws_lambda_function.route53_association_lambda.id
  arn            = var.network-ops-lambda-fn-arn  # aws_lambda_function.route53_association_lambda.arn
}

# -----------------------------------------------------------------------------------------------------------------
# AWS EventBridge EventBus Rule | -> Rule for Spoke VPC Lambda FN to Complete Centralized Interface Endpoints Assoc.
# -----------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "centralized-interface-endpoint-assoc-completion-rule" {
  name           = "complete-spoke-vpc-assoc-with-centralized-endpoints-rule"
  description    = "Event triggers the completion of the association of the spoke VPCs with the centralized Interface VPC Endpoints."
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  event_pattern  = <<EOF
{
  "source": ["aws-fsf-network-ops.interface-endpoints-association-completion-event"]
}
EOF
}


resource "aws_cloudwatch_event_target" "complete-spoke-vpc-assoc-with-available-interface-endpoints" {
  rule           = aws_cloudwatch_event_rule.centralized-interface-endpoint-assoc-completion-rule.name
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  target_id      = var.network-ops-lambda-fn-id   # aws_lambda_function.route53_association_lambda.id
  arn            = var.network-ops-lambda-fn-arn  # aws_lambda_function.route53_association_lambda.arn
}


# -----------------------------------------------------------------------------------------------------------------
# AWS EventBridge EventBus Rule | -> Request All Available Centralized DNS Resource Shares
# -----------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "centralized-dns-resolver-rule-association-request-rule" {
  name           = "requests-centralized-dns-resource-share-rule"
  description    = "Event requests a list of all resource shares."
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  event_pattern  = <<EOF
{
  "source": ["aws-fsf-network-ops.dns-resolver-rule-association-request-event"]
}
EOF
}


resource "aws_cloudwatch_event_target" "complete-centralized-dns-resolver-rule-association-request-event" {
  rule           = aws_cloudwatch_event_rule.centralized-dns-resolver-rule-association-request-rule.name
  event_bus_name = aws_cloudwatch_event_bus.network_event_bus.name
  target_id      = var.network-ops-lambda-fn-id   # aws_lambda_function.route53_association_lambda.id
  arn            = var.network-ops-lambda-fn-arn  # aws_lambda_function.route53_association_lambda.arn
}


# -----------------------------------------------------------------------------------------------------------------
# Lambda Permission Addition
# -----------------------------------------------------------------------------------------------------------------

resource "aws_lambda_permission" "allow_eventbridge_rule_update_route_53_a_record_with_vpce_hostname" {
  statement_id  = "associate-with-private-hosted-zone-event"
  action        = "lambda:InvokeFunction"
  function_name = var.network-ops-lambda-fn-name # aws_lambda_function.route53_association_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.private-hosted-zone-association-initiated.arn
}


resource "aws_lambda_permission" "allow_eventbridge_rule_trigger_lambda_function_for_tgw_ops" {
  statement_id  = "transit-gateway-route-table-association-n-propagation-permission"
  action        = "lambda:InvokeFunction"
  function_name = var.network-ops-lambda-fn-name # aws_lambda_function.route53_association_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.tgw_route_table_association_propagation_rule.arn
}


resource "aws_lambda_permission" "allow_eventbridge_rule_trigger_lambda_function_for_endpoint_assoc_ops" {
  statement_id  = "initiates-the-spoke-vpc-assoc-with-available-centralized-interface-endpoints-permission"
  action        = "lambda:InvokeFunction"
  function_name = var.network-ops-lambda-fn-name # aws_lambda_function.route53_association_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.centralized-interface-endpoint-association-initiated-rule.arn
}


resource "aws_lambda_permission" "allow_eventbridge_rule_trigger_lambda_function_for_endpoint_assoc_completion_ops" {
  statement_id  = "completes-the-spoke-vpc-assoc-with-available-centralized-interface-endpoints-permission"
  action        = "lambda:InvokeFunction"
  function_name = var.network-ops-lambda-fn-name # aws_lambda_function.route53_association_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.centralized-interface-endpoint-assoc-completion-rule.arn
}


resource "aws_lambda_permission" "allow_eventbridge_rule_trigger_lambda_function_for_dns_resource_shares_ops" {
  statement_id  = "completes-the-association-with-dns-resolver-rule-permission"
  action        = "lambda:InvokeFunction"
  function_name = var.network-ops-lambda-fn-name # aws_lambda_function.route53_association_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.centralized-dns-resolver-rule-association-request-rule.arn
}