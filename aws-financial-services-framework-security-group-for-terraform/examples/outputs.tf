
output "aws_region" {
  value = var.aws_region
}

output "vpc_cidr_block" {
  value = aws_vpc.spoke_vpc.cidr_block
}


output "non_routable_security_group_id" {
  value = aws_security_group.non_routable_security_group.id
  
}


output "web_routable_security_group_id" {
  value = concat(aws_security_group.web_edge_security_group.*.id, [null])[0]
}


output "database_routable_security_group_id" {
  value = concat(aws_security_group.database_edge_security_group.*.id, [null])[0]
}


output "kafka_routable_security_group_id" {
  value = concat(aws_security_group.kafka_zookeeper_edge_security_group.*.id, [null])[0]
}


output "elastic_search_routable_security_group_id" {
  value = concat(aws_security_group.elasticsearch_edge_security_group.*.id, [null])[0]
}


output "apache_spark_routable_security_group_id" {
  value = concat(aws_security_group.apache_spark_edge_security_group.*.id, [null])[0]
}