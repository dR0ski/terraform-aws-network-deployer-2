#---------------------------------------------------------------------
# VPC ID
#---------------------------------------------------------------------
output "vpc_id" {
  value = module.spoke_vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.spoke_vpc.vpc_cidr_block
}

output "aws_region" {
  value = var.aws_region
}

output "this_vpc_flow_log_id" {
  value = module.fsf-spoke-vpc-flow-logs.flow_log_id
}


#---------------------------------------------------------------------
# Subnet IDs
#---------------------------------------------------------------------
output "this_aws_routable_subnets" {
  value = module.fsf-spoke-vpc-subnets.routable_subnets
}

output "this_externally_routable_subnets" {
  value = module.fsf-spoke-vpc-subnets.externally_routable_subnets
}

output "this_transit_gateway_subnets" {
  value = module.fsf-spoke-vpc-subnets.transit_gateway_subnets
}

#---------------------------------------------------------------------
# Route Table IDs
#---------------------------------------------------------------------
output "this_aws_routable_routing_table_id" {
  value = module.fsf-spoke-create-vpc-route-tables.aws_routable_routing_table_id
}

output "this_externally_routable_routing_table_id" {
  value = module.fsf-spoke-create-vpc-route-tables.externally_routable_routing_table_id
}

output "this_tgw_attachment_routing_table_id" {
  value = module.fsf-spoke-create-vpc-route-tables.tgw_attachment_routing_table_id
}

#---------------------------------------------------------------------
# EventBridge EventBus Info |
#---------------------------------------------------------------------
output "this_eventbridge_networkops_eventbus_arn" {
  value = data.terraform_remote_state.this_account_network_paving_components.outputs.vpc_network_operations_eventbus_arn # module.fsf-spoke-vpc-network-operations-eventbus.eventbus_arn
}