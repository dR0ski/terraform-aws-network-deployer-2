terraform{
  backend "s3"{
    # Please populate with the name of the S3 bucket that holds the terraform.tfstate file for your transit_gateway
    bucket = "PLEASE-ADD-AWS-BUCKET-NAME"

    # Please populate with the key name the terraform.tfstate file for your transit_gateway
    key =  "PLEASE-ADD-S3-PREFIX-PATH/KEY-NAME"

    # Please populate with the AWS Region for the S3 bucket that stores the terraform.tfstate file for your transit_gateway
    region = "PLEASE-ADD-AWS-REGION (example us-east-2)"
  }
}
