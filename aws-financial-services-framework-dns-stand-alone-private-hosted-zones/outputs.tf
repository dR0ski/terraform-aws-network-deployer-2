output "private-hosted-zone-id"{
        value = concat(aws_route53_zone.private_hosted_zone_1.*.zone_id, [null])[0]
}