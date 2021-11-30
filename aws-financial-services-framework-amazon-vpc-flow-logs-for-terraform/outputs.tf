output "flow_log_id" {
  value = concat(aws_flow_log.flowlog.*.id)
}
