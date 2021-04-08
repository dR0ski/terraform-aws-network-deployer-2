# terraform-aws-fsf-vpc-subnets

Amazon Virtual Private Cloud (Amazon VPC) supports IPv4 & IPv6 CIDR ranges. While IPv6 CIDR ranges are optional, IPv4 CIDR ranges are mandatory. Amazon VPCs supports from the largest, a /16 to the smallest, /28.
 

 This terraform module creates three categories of IPv4 subnets: 
 * AWS Routable
 * Externally Routable
 * Transit Gateway specific subnets
 
## AWS Routable Subnets 

An AWS Routable subnet is only routable within the AWS Cloud. The AWS Route Table to which  this subnet is attached has only a local route. The Security group that was created for this subnet only allow routing among the subnets inside the VPC. This subnet can be created from the primary VPC CIDR or secondary CIDR range(s).


## Externally Routable Subnets 

An Externally Routable subnet is routable inside the AWS Cloud and on-premises. However, it is not routable on the public INternet. The AWS Route Table to which these subnets are attached has two types of routes; local routes and transit gateway routes. There are no AWS Internet Gateway(s) (IGW) created in the spoke VPC and as such no default route to an IGW in the route table. 


## Transit Gateway Specific Subnet

A transit gateway (tgw) specific subnet is created for AWS Transit Gateway attachment interfaces as prescribed by the AWS best practices guideline for AWS and as such should be stated as the subnet of choice during the transit gateway attachmnet creation request. A tgw spefific interface i created in each availability zone in the AWS Regions. 

## Creating Subnets
In the variables.tf file is a variable map labled subnet_type. This map has the three subnets specified as listed below. Simply flip the bool from false to true in oder to create the subnet type of yoiur choice. It is recommended that all three be created and by default all three type is equal to a bool of true. 

```hcl-terraform
variable "subnet_type" {
  type = map(bool)
  default = {
    aws_routable                      = true
    externally_routable               = true
    transit_gateway_subnet            = true
  }
}
```

To create a VPC formed from the opinions in this module, please use the below example as a guide.
## Example usage

variables.tf
```hcl-terraform
variable "vpc_id" {}
variable "map_public_ip_on_launch" {} //false by default and should never be true.
variable "assign_ipv6_address_on_creation" {} //false by default. No other bool is accepted as denoted by the variables condition. 
variable "environment_type" {}

variable "private_subnets" {
  default = []
}

variable "public_subnets" {
  default = []
}

variable "transit_gateway_subnets" {
  default = []
}

```
main.tf
```hcl-terraform
provider "aws" {
  profile   = "default"
  region    = "us-east-2"
}


module "fsf-vpc-subnets" {
  source                          = "app.terraform.io/aws-gfs-accelerate/fsf-vpc-subnets/aws"
  version                         = "0.0.  3"
  vpc_id                          = module.fsf-manual-spoke-vpc.vpc_id
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.assign_ipv6_address_on_creation
  subnet_type                     = var.subnet_type
  private_subnets                 = var.private_subnets
  public_subnets                  = var.public_subnets
  transit_gateway_subnets         = var.transit_gateway_subnets
  environment_type                = var.environment_type
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
The subnets created in this module are managed by purpose built security groups and route tables. These enforce the boundaries specified in this document.

This terraform module creates a logically isolated space in the AWS Cloud. No access paths or infrastructure exist in this space until defined by the implementation of other modules. This opinionated VPC for Financial Services customers is not built with a virtual gateway (VGW) or Internet (IGW).  


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

