#######################################################################################################
# Shared Service VPC Deployment
#######################################################################################################
terraform {
  backend "s3" {
    region         = "us-east-2"
    bucket         = "aws-fsf-team-terraform-state-storage"
    key            = "aws-fsf-terraform-network-state/Account/900095077793/vpc-a/terraform.tfstate"
  }
}


#######################################################################################################
# Spoke VPC Deployment
#######################################################################################################
//terraform {
//  backend "s3" {
//    region         = "us-west-2"# "us-east-2"
//    bucket         = "aws-fsf-test" # "aws-fsf-team-terraform-state-storage"
//    key            = "account/505649211197/vpc/spoke/terraform.tfstate" # "aws-fsf-terraform-network-state/Account/900095077793/vpc/spoke-test-reinvent2021/terraform.tfstate"
//  }
//}


//terraform {
//  backend "s3" {
//    region         = "us-west-2"# "us-east-2"
//    bucket         = "aws-fsf-test" # "aws-fsf-team-terraform-state-storage"
//    key            = "account/505649211197/vpc/network-orchestration/terraform.tfstate" # "aws-fsf-terraform-network-state/Account/900095077793/vpc/spoke-test-reinvent2021/terraform.tfstate"
//  }
//}