output "ipv4_igw_id" {
  value = concat(aws_internet_gateway.igw_ipv4.*.id)
}

output "ipv6_igw_id" {
  value = concat(aws_egress_only_internet_gateway.igw_ipv6.*.id)

}