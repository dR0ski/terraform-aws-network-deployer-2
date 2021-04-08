output "vpc_id" {
  value = aws_vpc.spoke_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.spoke_vpc.cidr_block
}

output "aws_region" {
  value = var.aws_region
}

output "routable_subnets" {
  value = "${aws_subnet.private-subnet.*.id}"
}

output "externally_routable_subnets" {
  value = "${aws_subnet.externally_routable_subnet.*.id}"
}

output "transit_gateway_subnets" {
  value = "${aws_subnet.transit_gateway_attachment_subnet.*.id}"
}