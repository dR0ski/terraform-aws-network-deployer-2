#---------------------------------------------------------------------
# SHARED SERVICES VPC | Outputs
#---------------------------------------------------------------------
output "shared_services_vpc_id" {
  value = concat(module.shared_services_vpc.*.vpc_id, [null])[0]
}

output "shared_services_vpc_cidr" {
  value = concat(module.shared_services_vpc.*.vpc_cidr_block, [null])[0]
}

output "shared_services_aws_routable_subnet_id" {
  value = concat(module.shared_services_vpc.*.this_aws_routable_subnets, [null])[0]
}

output "shared_services_externally_routable_subnet_id" {
  value = concat(module.shared_services_vpc.*.this_externally_routable_subnets, [null])[0]
}

output "shared_services_transit_gateway_subnet_id" {
  value = concat(module.shared_services_vpc.*.this_transit_gateway_subnets, [null])[0]
}

//output "shared_services_networkops_eventbus_arn" {
//  value = concat(module.shared_services_vpc.*.this_eventbridge_networkops_eventbus_arn, [null])[0]
//}



#---------------------------------------------------------------------
# SPOKE VPC | Outputs
#---------------------------------------------------------------------
output "spoke_vpc_id" {
  value = concat(module.spoke_vpc.*.vpc_id, [null])[0]
}

output "spoke_vpc_cidr" {
  value = concat(module.spoke_vpc.*.vpc_cidr_block, [null])[0]
}

output "spoke_vpc_aws_routable_subnet_id" {
  value = concat(module.spoke_vpc.*.this_aws_routable_subnets, [null])[0]
}

output "spoke_vpc_externally_routable_subnet_id" {
  value = concat(module.spoke_vpc.*.this_externally_routable_subnets, [null])[0]
}

output "spoke_vpc_transit_gateway_subnet_id" {
  value = concat(module.spoke_vpc.*.this_transit_gateway_subnets, [null])[0]
}

//output "spoke_vpc_networkops_eventbus_arn" {
//  value = concat(module.spoke_vpc.*.this_eventbridge_networkops_eventbus_arn, [null])[0]
//}



#---------------------------------------------------------------------
# NETWORK PAVING COMPONENTS | Outputs
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# EventBridge EventBus Output Value |
#---------------------------------------------------------------------
output "vpc_network_operations_eventbus_arn" {
  value = concat(module.pave_account_with_network_orchestration_components.*.vpc_network_operations_eventbus_arn, [null])[0]
}

#---------------------------------------------------------------------
# AWS Lambda | Network Operations Lambda Function Outputs
#---------------------------------------------------------------------
output "vpc-network-operations-lambda-fn-name" {
  value = concat(module.pave_account_with_network_orchestration_components.*.vpc-network-operations-lambda-fn-name, [null])[0]
}

output "vpc-network-operations-lambda-fn-arn" {
  value = concat(module.pave_account_with_network_orchestration_components.*.vpc-network-operations-lambda-fn-arn, [null])[0]
}

output "vpc-network-operations-lambda-fn-id" {
  value = concat(module.pave_account_with_network_orchestration_components.*.vpc-network-operations-lambda-fn-id, [null])[0]
}

#---------------------------------------------------------------------
# AWS Lambda | Network Operations Put Event Lambda Function Output
#---------------------------------------------------------------------
output "vpc-network-operations-put-event-lambda-fn-name" {
  value = concat(module.pave_account_with_network_orchestration_components.*.vpc-network-operations-put-event-lambda-fn-name, [null])[0]
}
