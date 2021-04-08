# terraform-aws-fsf-manual-spoke-vpc

Amazon Virtual Private Cloud (Amazon VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways. You can use both IPv4 and IPv6 in your VPC for secure and easy access to resources and applications.
You can easily customize the network configuration of your Amazon VPC. For example, you can create a public-facing subnet for your web servers that have access to the internet. You can also place your backend systems, such as databases or application servers, in a private-facing subnet with no internet access. You can use multiple layers of security, including security groups and network access control lists, to help control access to Amazon EC2 instances in each subnet.

This module provisions an Amazon VPC (only). This module allows users to enable:
 *  IPv6
 * VPC Flow Logs
 * DNS & DHCP Support
 * Change the tenancy type of the VPC
 
The enablement of the Amazon VPC FlowLogs is dependent on the VPC FlowLogs Terraform module. 
To enable VPC FlowLogs you must ensure the variable "enable_vpc_flow_logs" is set to true.  


Please see the below declarations of the VPC FlowLog dependency in both the main.tf and variables.tf file

variables.tf
```hcl-terraform
variable "enable_vpc_flow_logs" {
  description = "Whether vpc flow log should be enabled for this vpc."
  type    = bool
  default = true
}
```
main.tf
```hcl-terraform
module "fsf-vpc-flow-logs" {
  source  = "app.terraform.io/aws-gfs-accelerate/fsf-vpc-flow-logs/aws"
  version = "0.0.1"
  vpc_id  = aws_vpc.spoke_vpc.id
  enabled = var.enable_vpc_flow_logs
}

```
To create a VPC formed from the opinions in this module, please use the below example as a guide.
## Example usage

```hcl-terraform
provider "aws" {
  profile   = "default"
  region    = "us-east-2"
}

module "fsf-manual-spoke-vpc"{
  source                          = "app.terraform.io/aws-gfs-accelerate/fsf-manual-spoke-vpc/aws"
  version                         = "0.0.1"
  vpc_cidr_block                  = var.vpc_cidr_block
  dns_support                     = var.dns_support
  instance_tenancy                = var.instance_tenancy
  dns_host_names                  = var.dns_host_names
  enable_aws_ipv6_cidr_block      = var.enable_aws_ipv6_cidr_block
  enable_vpc_flow_logs            = var.monitoring.vpc_flow_log
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

Amazon VPC provides advanced security features, such as security groups and network access control lists, to enable inbound and outbound filtering at the instance and subnet level. In addition, you can store data in Amazon S3 and restrict access so that it’s only accessible from instances inside your VPC. For additional security, you can create dedicated instances that are physically isolated from other AWS accounts, at the hardware level.

This terraform module creates a logically isolated space in the AWS Cloud. No access paths or infrastructure exist in this space until defined by the implementation of other modules. This opinionated VPC for Financial Services customers is not built with a virtual gateway (VGW) or Internet (IGW).  
```hcl-terraform
resource "aws_vpc" "spoke_vpc" {}
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

