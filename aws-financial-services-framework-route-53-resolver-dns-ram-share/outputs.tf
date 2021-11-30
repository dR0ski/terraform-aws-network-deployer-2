output "route_53_resolver_dns_firewall_ram_share_arn" {
  value = concat(aws_ram_resource_share.resolver_firewall_rules_group_ram_share.*.arn, [null])[0]
}
