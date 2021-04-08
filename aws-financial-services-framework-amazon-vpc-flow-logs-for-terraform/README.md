# terraform-aws-fsf-vpc-flow-logs

Amazon Virtual Private Cloud (VPC) Flow Logs is a feature that enables you to capture information about the IP traffic going to and from network interfaces in your VPC. Flow log data can be published to Amazon CloudWatch Logs or Amazon S3. After you've created a flow log, you can retrieve and view its data in the chosen destination.
Flow logs can help you with a number of tasks, such as:

* Diagnosing overly restrictive security group rules
* Monitoring the traffic that is reaching your instance
* Determining the direction of the traffic to and from the network interfaces
* This module provisions an Amazon VPC (only). This module allows users to enable:

This terraform module creates an Amazon VPC Flow Logs implementation that stores all log data in AWS Cloud Logs. Amazon S3 as a destination for log data will be released in version two of this module.  

The enablement of the Amazon VPC FlowLogs is dependent on the "var.enabled". If "var.enabled=true" then the VPC FlowLogs Terraform module will build all the components for a fully-function VPC Flow Logs that is configured to capture ALL traffic type. 

This variable can be seen below:

```hcl-terraform
variable "enabled" {
	type  = bool
	validation {
		condition     = var.enabled == true
		error_message = "The enabled value must be set to true."
	}
}
```
To deploy this terraform module or incorpoorate it in another module, please see the below configuration.  

## Example usage
```hcl-terraform

provider "aws" {
	profile   = "default"
	region    = "us-east-2"
}


module "fsf-vpc-flow-logs" {
	source  = "app.terraform.io/aws-gfs-accelerate/fsf-vpc-flow-logs/aws"
	version = "0.0.1"
	vpc_id  = aws_vpc.spoke_vpc.id
	enabled = var.enable_vpc_flow_logs
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

Security in this module is enforced through IAM policies. These policies only allow a trimmed set of Actions and only within the AWS account in which the VPC lives.  

	
```hcl-terraform

resource "aws_iam_role_policy" "cwlogpolicy" {
	name  = "loggingpolicy"
	count = var.enabled == true ? 1 : 0
	role  = aws_iam_role.vpc_flowlog_cloudwatch_role[count.index].name
	policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents",
				"logs:DescribeLogGroups",
				"logs:DescribeLogStreams"
			],
			"Effect": "Allow",
			"Resource": [
					"arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*",
					"arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*"

					]
		}
	]
}
EOF
}

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

