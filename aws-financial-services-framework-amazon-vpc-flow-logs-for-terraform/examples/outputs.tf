output "aws_region" {
  value = var.aws_region
}

output "flow_log_id" {
  value = aws_flow_log.flowlog[0].id
}

output "vpc_id" {
  value = aws_vpc.unit-vpc.id
}
