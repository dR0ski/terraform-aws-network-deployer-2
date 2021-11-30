output "nat_gateway_id_private"{
  value = concat(aws_nat_gateway.nat_gateway_private.*.id)
}

output "nat_gateway_id_public"{
  value = concat(aws_nat_gateway.nat_gateway_public.*.id)
}