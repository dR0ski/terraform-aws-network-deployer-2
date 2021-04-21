#---------------------------------------------------------------------
# EventBridge EventBus Output Value |
#---------------------------------------------------------------------
output "vpc_network_operations_eventbus_arn" {
  value = module.fsf-vpc-network-operations-eventbus.eventbus_arn
}

#---------------------------------------------------------------------
# AWS Lambda | Network Operations Lambda Function Outputs
#---------------------------------------------------------------------
output "vpc-network-operations-lambda-fn-name" {
  value = module.fsf-vpc-network-operations-lambda-fn.network-ops-lambda-fn-name
}

output "vpc-network-operations-lambda-fn-arn" {
  value = module.fsf-vpc-network-operations-lambda-fn.network-ops-lambda-fn-arn
}

output "vpc-network-operations-lambda-fn-id" {
  value = module.fsf-vpc-network-operations-lambda-fn.network-ops-lambda-fn-id
}

#---------------------------------------------------------------------
# AWS Lambda | Network Operations Put Event Lambda Function Output
#---------------------------------------------------------------------
output "vpc-network-operations-put-event-lambda-fn-name" {
  value = module.fsf-vpc-network-operations-put-event-lambda-fn.network-ops-put-event-lambda-fn-name
}
