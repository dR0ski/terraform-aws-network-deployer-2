# terraform-aws-fsf-vpc-route-table

This terraform module creates three (3) Amazon Virtual Private Cloud (VPC) Route Tables. These are as follows: 
 
 * AWS Routable Route Table
 * Externally Routable Route Table
 * Transit Gateway Route Table
 
The three route tables listed above maps to the three subnet types that are created by the "terraform-aws-fsf-vpc-subnets" module. This module checks for the presence of these subnets and associate them with their corresponding route table type.  

## AWS Routable Route Table 

This route table allows routing within an Amazon VPC or to other VPCs if they dont have any overlapping IP space but it doesn't have routes to networks outside the AWS Cloud. This module discovers and automatically associate the AWS routable subnets with this route table.  
## Externally Routable Route Table 

This route table contains routes to external networks. This module discovers if externally routable subnets have been created and automatically associate them with this route table.
## Transit Gateway Routable Route Table

This route table is built to support the subnets that are purpose built to host transit gateway attachment interfaces. This module discovers these subnets and associates them with this route table. 

To create a VPC formed from the opinions in this module, please use the below example as a guide.
## Example usage

variables.tf
```hcl-terraform
variable "vpc_id" {}

variable "environment_type" {
  description = "Envrionment Type"
  type    = string
  default = "Development"

}

variable "routable_subnets" {}

variable "externally_routable_subnets" {}

variable "transit_gateway_subnets" {}

```
main.tf
```hcl-terraform
provider "aws" {
  profile   = "default"
  region    = "us-east-2"
}


module "vpc-route-table" {
  source  = "app.terraform.io/aws-gfs-accelerate/vpc-route-table/aws"
  version = "0.0.1"
  vpc_id = module.fsf-manual-spoke-vpc.vpc_id
  externally_routable_subnets = module.fsf-vpc-subnets.externally_routable_subnets
  routable_subnets = module.fsf-vpc-subnets.routable_subnets
  transit_gateway_subnets = module.fsf-vpc-subnets.transit_gateway_subnets
  environment_type = var.environment_type
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
The infrastructure built by this module helps to enforce the security boundary around the subnets that are associated with it. This is done by isolating subnets according to their routing needs. 

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

