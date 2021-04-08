output "vpc_id" {
  value = aws_vpc.spoke_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.spoke_vpc.cidr_block 
}

//output "aws_region" {
//  value = var.aws_region
//}