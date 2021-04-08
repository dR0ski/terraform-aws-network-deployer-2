#---------------------------------------------------------------------
# SHARED SERVICES VPC | Outputs
#---------------------------------------------------------------------
output "shared_services_vpc_id" {
  value = module.shared_services_vpc.vpc_id
}

output "shared_services_vpc_cidr" {
  value = module.shared_services_vpc.vpc_cidr_block
}

output "shared_services_aws_routable_subnet_id" {
  value = module.shared_services_vpc.this_aws_routable_subnets
}

output "shared_services_externally_routable_subnet_id" {
  value = module.shared_services_vpc.this_externally_routable_subnets
}

output "shared_services_transit_gateway_subnet_id" {
  value = module.shared_services_vpc.this_transit_gateway_subnets
}

output "shared_services_networkops_eventbus_arn" {
  value = module.shared_services_vpc.this_eventbridge_networkops_eventbus_arn
}


