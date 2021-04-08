# aws-financial-services-framework-vpc-endpoints-for-terraform

A VPC endpoint enables you to privately connect your VPC to supported AWS services and VPC endpoint services powered by AWS PrivateLink without requiring an internet gateway, NAT device, VPN connection, or AWS Direct Connect connection. Instances in your VPC do not require public IP addresses to communicate with resources in the service. Traffic between your VPC and the other service does not leave the Amazon network.

Endpoints are virtual devices. They are horizontally scaled, redundant, and highly available VPC components. They allow communication between instances in your VPC and services without imposing availability risks or bandwidth constraints on your network traffic.

This terraform module creates Amazon VPC endpoints for the following AWS services:

* S3
* DynamoDB
* Systems Manager (purpose built to facilitate shell access to EC2 instances.)
* SQS
* SNS
* ECS
* EC2
* Secrets Manager
* Key Management Service (KMS)
* EC2 Messages
* Systems Manager Messages
* ECS Telemetry
* ECS Agent

The endpoints created by this terraform module comes with a modified endpoint policy. The endpoint policy for each endpoint contains a curated list of API Actions and specific resources on which those actions can be enacted. For example, the Amazon S3 endpoint policy allows access to buckets inside the account and AWS package buckets only. 
The Amazon S3 endpoint policy is as follows:

```hcl-terraform
policy = <<POLICY
		{
		 "Statement": [{
								"Effect": "Allow",
								"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
								"Action": [
									 "s3:ListAllMyBuckets", 
									 "s3:ListBucket", 
									 "s3:GetObject", 
									 "s3:GetObjectVersion", 
									 "s3:PutObject"
								],
								"Resource": [
									"arn:aws:s3:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*",
									"arn:aws:s3:::packages.*.amazonaws.com/*",
									"arn:aws:s3:::repo.*.amazonaws.com/*",
									"arn:aws:s3:::patch-baseline-snapshot-${data.aws_caller_identity.current.account_id}:/*",
									"arn:aws:s3:::aws-ssm-${var.aws_region}/*"
								]
						}]
	 
		}
		POLICY
``` 
Each interface endpoint has Private DNS enabled by default and each gateway endpoint adds routes to both the routable and non-routable VPC route tables.

The deployment of an endpoint is controlled by the variable map '"variable" "endpoints"{}'. To deploy an endpoint, simply change the bool for the service to true as illustrated below.

```hcl-terraform
variable "endpoints" {
  type = map(bool)
  default = {
    s3_gateway          = true
    dynamodb            = false
    secrets_manager     = false
    kms                 = false
    ec2                 = false
    ec2_messages        = false
    ecs                 = false
    ecs_agent           = false
    ecs_telemetry       = false
    sts                 = false
    sns                 = false
    sqs                 = false
    ssm                 = false
    ssm_messages        = false
  }
}

```

## Example usage
The below example illustrates how to use this module to create endpoints for a specific Amazon VPC. 

```hcl-terraform
provider "aws" {
	profile   = "default"
	region    = "us-east-2"
}

variable "endpoints" {
  type = map(bool)
  default = {
    s3_gateway          = true
    dynamodb            = false
    secrets_manager     = false
    kms                 = false
    ec2                 = false
    ec2_messages        = false
    ecs                 = false
    ecs_agent           = false
    ecs_telemetry       = false
    sts                 = false
    sns                 = false
    sqs                 = false
    ssm                 = false
    ssm_messages        = false
  }
}

module "fsf-vpc-endpoints" {
  source                          = "app.terraform.io/aws-gfs-accelerate/fsf-vpc-endpoints/aws"
  version                         = "0.0.1"
  vpc_id                          = module.fsf-manual-spoke-vpc.vpc_id
  route_table_id                  = [ module.vpc-route-table.externally_routable_routing_table_id, module.vpc-route-table.aws_routable_routing_table_id]
  endpoint_security_group         = module.fsf-security-groups.non_routable_security_group_id
  endpoints                       = var.endpoints
  endpoint_subnet_ids             = module.fsf-vpc-subnets.externally_routable_subnets #Please add subent-ids from the subnet module here
  aws_region                      = var.aws_region
}
```

# Overview
This guide provides infrastructure and configuration information for using this Terraform module that is part of the Financial Service Framework. This document describes the AWS Financial Service Framework generally, of which this specific project is a part of, and then the Spoke VPC module specifically.

## AWS Financial Services Framework
The AWS Financial Service Framework (FSF) is a collection of software assets and documentation whose purpose it is to accelerate the pace at which financial services customers adopt usage of AWS. This acceleration is a function of providing software assets that instantiate AWS resources with the kind of considerations that are typically asked by customers in financial services. These considerations include for example:

*  Isolated VPCs with no internet gateways
*  Ubiquitous encryption with KMS CMKs wherever possible
*  The least permissive entitlements 
*  Segregation of duties through IAM

These software assets, some of which are encapsulated by opinionated , some of which instantiate Config Rules or Lambda Functions, are backed by the documentation required to satisfy not just technical questions but also those asked by an organization’s governance, risk, and compliance functions. Examples of the questions the FSF assets are prepared to answer include, for example: 

*  How do I know which controls are satisfied by this software asset?
*  How do I know that this control, which forces ELB access logging, is effective?
*  How do the controls listed as part of this installation map to frameworks such as NIST 800-53?

We believe that by producing software assets that achieve an outcome and explain the way in which their construction was decided we can accelerate the customer’s journey to AWS. One of the ways in which FSF accomplishes this is by publishing control design documents. Control design documents describe the logic employed by a particular control. For example, a control whose purpose it is to detect unencrypted kinesis streams, would be accompanied by a control design document that describes the logic of the code and how it makes that determination. This is done so that an auditor can test and then attest to the effectiveness of that control. In this example the document would explain that an auditor could test effectiveness by sampling a random number of kinesis streams, use the logic to make a conclusion as to whether the selected kinesis stream is encrypted, and then compare those conclusions to those that were automatically determined by the installed control for the same set of streams. Should the manual and automatic results be the same the auditor should feel comfortable attesting to the effectiveness of the control.

## AWS FSF: Terraform Modules

The AWS FSF project utilizes Terraform modules to enable organizations to use aws resources that have been well reasoned about. 

It is the goal of the FSF project to produce a complete library of Terraform modules whose purpose it is to allow our customers to enable the self-service provisioning of AWS assets by their developers. A fundamental tenet of the AWS FSF project is: customers derive the most value from AWS when developers can create and manage the assets required to build their application without depending on other teams to grant approvals or perform pre-requisite tasks on their behalf. AWS FSF is a mechanism for enabling that in a safe and repeatable way.

The Terraform modules in the AWS FSF project are preconfigured with defaults and constraints that are informed by design considerations typically sought after by our Financial Services customers.  This ensures that when your developers provision an AWS FSF Terraform Module, say for example an S3 Bucket, they get a bucket with properties such as:

* No public access
* AWS KMS CMK encryption enabled and required
* No ability to modify bucket policy

# Security

The Amazon VPC endpoints were created to keep traffic between your VPC and AWS services within the AWS Cloud. Thus, adding a layer of privacy to this communication. Amazon VPC endpoints comes with additional features that when used correctly can add another layer of security. Some of these features are as follows: 

* Amazon VPC Endpoint Policies for both Gateway Endpoints and Interface Endpoints. 
* Amazon VPC Interface Endpoints uses the IP space that is specified for the Amazon VPC in which the endpoint is deployed
* Amazon VPC Gateway Endpoints provides the ability for a customer to choose the route table to which its routes are added

This terraform module tune each of these features to add an additional layer of restriction around access control. Please see the below endpoint policy for the EC2 endpoint that is created by this module. 

```hcl-terraform
policy = <<POLICY
		{
		 "Statement": [
			{
					"Action": ["ec2:*"],
					"Effect": "Allow",
					"Principal":{"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
					"Resource": "*"
			},
			{
					"Action": [
							"ec2:CreateVolume"
					],
					"Effect": "Deny",
					"Principal":{"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
					"Resource": "*",
					"Condition": {
							"Bool": {
									"ec2:Encrypted": "false"
							}
					}
			},
			{
					"Action": [
							"ec2:RunInstances"
					],
					"Effect": "Deny",
					"Principal":{"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
					"Resource": "*",
					"Condition": {
							"Bool": {
									"ec2:Encrypted": "false"
							}
					}
			}]
	 
		}
		POLICY
```

# Cost

The infrastructure created from this module does not generate any cost. To better understand how customers are charged for other VPC components. Please see the below link. 
* AWS Amazon VPC: https://aws.amazon.com/vpc/pricing/ 

In order to use this module you'll need to supply the following assets:

*  S3 bucket to access
*  (optional) SSM parameters
*  (optional) Secrets Manager secrets
*  (optional) CloudWatch logs 
The costs associated with  these assets are documented here:
*  Amazon S3: https://aws.amazon.com/s3/pricing/
*  AWS Systems Manager Parameter Store: https://aws.amazon.com/systems-manager/pricing/
*  AWS Secrets Manager: https://aws.amazon.com/secrets-manager/pricing/
*  Amazon CloudWatch: https://aws.amazon.com/cloudwatch/pricing/

# Support

Requests for support should be submitted via git issues.

# Contributions

Contribution guidelines are currently in development. In the meantime requests can be made via git issues.

# License Summary

This sample code is made available under a * license. See the LICENSE file.

