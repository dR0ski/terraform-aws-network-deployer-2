output "transit_gateway_attachment_id" {
  value =  concat(aws_ec2_transit_gateway_vpc_attachment.spoke_vpc_transit_gateway_attachment.*.id, [null])[0]
}

output "eventbus_arn"{
  value =  var.eventbus_arn
}


