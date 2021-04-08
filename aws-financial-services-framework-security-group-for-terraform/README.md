# aws-financial-services-framework-security-group-for-terraform

A security group acts as a virtual firewall for your instance to control inbound and outbound traffic. When you launch an instance in a VPC, you can assign up to five security groups to the instance. Security groups act at the instance level, not the subnet level. Therefore, each instance in a subnet in your VPC can be assigned to a different set of security groups.

If you launch an instance using the Amazon EC2 API or a command line tool, and you don't specify a security group, the instance is automatically assigned to the default security group for the VPC. If you launch an instance using the Amazon EC2 console, you have an option to create a new security group for the instance.

For each security group, you add rules that control the inbound traffic to instances, and a separate set of rules that control the outbound traffic. This section describes the basic things that you need to know about security groups for your VPC and their rules.

This terraform module creates two categories of security groups; routable/externally routable & non-routable/aws-specific security groups. 

Within the Routable/Externally Routable security group category are the following security groups:
 
* Database Security Group 
* Web Security Group
* Apache Kafka Security Group
* Elastic Search Security Group
* Apache Spark Security Group

The Non-Routable/AWS Routable security allows access to all ports as long as the source and destination is the VPC CIDR ranges.

## Routable/Externally Routable Security Group 

The definition of Routable/Externally Routable in the context of this module means that this security group allows access to the ports listed above for the o-premises CIDR ranges specified in the below variable in the variable.tf file
'var.on_premises_cidrs' is an array that contains a set of on-premises CIDR ranges that you specify. Infrastructure with this security group attached to their elastic network interface will allow be allowed to receive traffic generated from these on-premises CIDR ranges or VPC CIDR rang(s). 

This security group can work in chorus with the externally routable subnets created by the terraform-aws-fsf-subnet module and the externally routable route table created by the terraform-aws-fsf-route-table module for optimal isolation around external traffic. 

```hcl-terraform
variable "on_premises_cidrs" {
  description = "On-premises or non VPC network range"
  type    = list(string)
  default = [ "172.16.0.0/16", "172.17.0.0/16", "172.18.0.0/16", "172.19.0.0/16", "172.20.0.0/16", "172.22.0.0/16" ]
}
```

To deploy a specific type of security group with this category simply change the bool of the required security group to true in the variable "security_grp_traffic_pattern {}". 

Please see below example. 

```hcl-terraform
variable "security_grp_traffic_pattern" {
  type = map(bool)
  default = {
    database                = true
    web                     = true
    kafka_zookeeper         = true
    elasticsearch           = true
    apache_spark            = true

  }
}
```

## Non-Routable/AWS Routable Security Group 
Non-routable security groups allows access to all ports for traffic with a source and destination of subnets that belongs to the VPC CIDR range(s).
Unlike the externally routable or Routaable security groups, this security group is created by default.


## Example usage
Please see the below deployment example for building routable and mnon routable security groups using this terraform module. 

```hcl-terraform

provider "aws" {
	profile   = "default"
	region    = "us-east-2"
}

variable "security_grp_traffic_pattern" {
  type = map(bool)
  default = {
    database                = true
    web                     = true
    kafka_zookeeper         = true
    elasticsearch           = true
    apache_spark            = true

  }
}


# Create VPC Security Group Modules 
# ---------------------------------------------------------------------------------------------------------------
module "fsf-security-groups" {
  source                          = "app.terraform.io/aws-gfs-accelerate/fsf-security-groups/aws"
  version                         = "0.0.2"
  vpc_id                          = module.fsf-manual-spoke-vpc.vpc_id
  vpc_cidr_block                  = module.fsf-manual-spoke-vpc.vpc_cidr_block
  environment_type                = var.environment_type
  on_premises_cidrs               = var.on_premises_cidrs
  security_grp_traffic_pattern    = var.security_grp_traffic_pattern
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

Amazon VPC Security Groups enforce the security boundary atv the EC2 instance level. The security groups created by this module goes a step further by creating security group rules that restrict traffic to specific IP ranges for on-premises adn AWS specific networks. 

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

