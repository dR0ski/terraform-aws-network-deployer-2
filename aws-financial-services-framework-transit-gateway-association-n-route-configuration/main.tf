# ---------------------------------------------------------------------------------------------------------------
# AWS Transit Gateway Terraform Module State | -------> Loaded from Amazon S3
# ---------------------------------------------------------------------------------------------------------------
//data "terraform_remote_state" "transit_gateway_network" {
//  backend = "s3"
//  config = {
//    # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
//    bucket = "aws-fsf-team-terraform-state-storage"
//    # Please populate with the key name the terraform.tfstate file for your transit_gateway
//    key = "aws-fsf-terraform-network-state/transit-gateway/terraform.tfstate"
//    # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
//    region = "us-east-2"
//  }
//}
# ---------------------------------------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------------------------------------
# AWS Transit Gateway Route Table Association | -------> Associates VPC with TGW Route Table based on env tag 
# ---------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_vpc_transit_gateway_attachment" {
  count = ( var.transit_gateway_subnets_exist == true && var.create_transit_gateway_association == true ? 1 : 0)
  subnet_ids = var.transit_gateway_subnets
  #tolist(data.aws_subnet_ids.subnet_list.ids)
  transit_gateway_id = var.transit_gateway_id
  # data.terraform_remote_state.transit_gateway_network.outputs.transit_gateway_id
  vpc_id = var.vpc_id
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
}


# ---------------------------------------------------------------------------------------------------------------
# AWS Lambda | Invoking the FN that adds the creation of this PHZ as an event in the Shared Service EventBus
# ---------------------------------------------------------------------------------------------------------------
data "aws_lambda_invocation" "route53_private_hosted_zone_association" {
  count = (var.create_transit_gateway_association==true && var.transit_gateway_subnets_exist == true && (var.access_shared_services_vpc == true || var.perform_east_west_packet_inspection==true) ? 1:0)
  function_name = var.route53_association_lambda_fn_name
  input = <<JSON
  {

    "event_type": "tgw_route_table_association_n_propagation",
    "transit_gateway_attachment_id": "${aws_ec2_transit_gateway_vpc_attachment.spoke_vpc_transit_gateway_attachment[count.index].id}",
    "eventbus_arn": "${var.eventbus_arn}",
    "transit_gateway_id": "${var.transit_gateway_id}",
    "transit_gateway_dev_route_table_id": "${var.transit_gateway_dev_route_table_id}",
    "transit_gateway_uat_route_table_id": "${var.transit_gateway_uat_route_table_id}",
    "transit_gateway_shared_services_route_table_id": "${var.transit_gateway_shared_services_route_table_id}",
    "transit_gateway_packet_inspection_route_table_id": "${var.transit_gateway_packet_inspection_route_table_id}",
    "transit_gateway_production_route_table_id": "${var.transit_gateway_production_route_table_id}",
    "access_shared_services_vpc":"${var.access_shared_services_vpc}",
    "perform_east_west_packet_inspection":"${var.perform_east_west_packet_inspection}",
    "environment_type": "${var.environment_type}"

}
JSON

}


