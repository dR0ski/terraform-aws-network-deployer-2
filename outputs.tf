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

output "shared_services_networkops_eventbus_arn" {
  value = concat(module.shared_services_vpc.*.this_eventbridge_networkops_eventbus_arn, [null])[0]
}



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

output "spoke_vpc_networkops_eventbus_arn" {
  value = concat(module.spoke_vpc.*.this_eventbridge_networkops_eventbus_arn, [null])[0]
}
