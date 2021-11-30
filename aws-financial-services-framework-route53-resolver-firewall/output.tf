output "route_53_resolver_dns_firewall_ram_share_arn" {
  value = concat(aws_route53_resolver_firewall_config.route_53_resolver_dns_firewall_config.*.id)
}


output "resolver_firewall_domain_list_allow" {
  value = concat( aws_route53_resolver_firewall_domain_list.route_53_resolver_firewall_domain_allow_list.*.id)
}


output "resolver_firewall_domain_list_deny" {
  value = concat( aws_route53_resolver_firewall_domain_list.route_53_resolver_firewall_domain_deny_list.*.id)
}


output "resolver_firewall_domain_list_alert" {
  value = concat( aws_route53_resolver_firewall_domain_list.route_53_resolver_firewall_domain_alert_list.*.id)
}


output "resolver_firewall_rule_group" {
  value = concat( aws_route53_resolver_firewall_rule_group.route_53_resolver_firewall_rule_group.*.id)
}


output "resource_association" {
  value = concat(aws_ram_resource_association.resolver_firewall_rule_group_ram_share_association.*.resource_share_arn)
}


output "resolver_firewall_rule_allow" {
  value = concat( aws_route53_resolver_firewall_rule.route_53_resolver_firewall_allow_rule.*.id)
}


output "resolver_firewall_rule_deny" {
  value = concat( aws_route53_resolver_firewall_rule.route_53_resolver_firewall_deny_rule.*.id)
}


output "resolver_firewall_rule_alert" {
  value = concat( aws_route53_resolver_firewall_rule.route_53_resolver_firewall_alert_rule.*.id)
}