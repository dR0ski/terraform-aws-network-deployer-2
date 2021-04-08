package test

import (
	"fmt"
	//"strings"
	//"encoding/json"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

//MAIN Function
func TestTerraformSpokeVPCSecurityGroups(t *testing.T) {
	t.Parallel()

	
	//Configures the parameters needed to conduct the test  
	//----------------------------------------------------------------------------------------
	terraformOptions := &terraform.Options{
		//Specifies the working directory for your terraform files. Ideally, this should "
		TerraformDir: "../../examples",
		//Loads all the variables specified in the 
		VarFiles:     []string{"terraform.tfvars"},
	}

	//Defers TERRAFORM DESTROY until the test functions are completed
	//----------------------------------------------------------------------------------------
	defer test_structure.RunTestStage(t, "teardown", func() {
		terraform.Destroy(t, terraformOptions)
	})

	//Triggers a TERRAFORM APPLY on the TERRAFORM Template
	//----------------------------------------------------------------------------------------
	test_structure.RunTestStage(t, "deploy", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	//----------------------------------------------------------------------------------------	
	//Loading VPC Endpoint IDs from Terraform's state machine output object 
	//----------------------------------------------------------------------------------------
	vpcCIDR := terraform.Output(t, terraformOptions, "vpc_cidr_block")
	sgNonRoutableID := terraform.Output(t, terraformOptions, "non_routable_security_group_id")
	sgWebRoutableID := terraform.Output(t, terraformOptions, "web_routable_security_group_id")
	sgDatabaseRoutableID := terraform.Output(t, terraformOptions, "database_routable_security_group_id")
	sgKafkaRoutableID := terraform.Output(t, terraformOptions, "kafka_routable_security_group_id")
	sgElasticSearchRoutableID := terraform.Output(t, terraformOptions, "elastic_search_routable_security_group_id")
	sgSparkRoutableID := terraform.Output(t, terraformOptions, "apache_spark_routable_security_group_id")
	//----------------------------------------------------------------------------------------


	//----------------------------------------------------------------------------------------
	// NON ROUTABLE SECURITY GROUP UNIT TEST
	//----------------------------------------------------------------------------------------
	if len(sgNonRoutableID)!=0 && len(sgNonRoutableID)>0 { 
		//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
		test_structure.RunTestStage(t, "test_non_routable_sg_id_compliance", func() {
			regexPrefixMatch := "^sg-"
			assert.Regexpf(t, regexPrefixMatch, sgNonRoutableID, "error message %s", "formatted")
		})

		//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
		test_structure.RunTestStage(t, "test_non_routable_sg_check", func() {
		//GETs the AWS Region from output of the terraform apply 
		aws_region := terraform.Output(t, terraformOptions, "aws_region")
		//Configures the session with AWS by loading the regions in which the infrastructure was created.
		sess := session.Must(session.NewSessionWithOptions(session.Options{
			SharedConfigState: session.SharedConfigEnable,
			Config:            aws.Config{Region: aws.String(aws_region)},
		},
		))
			//Specifies the AWS service being accessed
			svc := ec2.New(sess)
			
			//Specifies the AWS API being referenced and the parameters or filters
			input := &ec2.DescribeSecurityGroupsInput{
				GroupIds: []*string{
					aws.String(sgNonRoutableID),
				},
			}
			
			//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
			result, err := svc.DescribeSecurityGroups(input)
			//Checks if an error was thrown
			if err != nil {
				fmt.Println("Error getting VPC:")
				fmt.Println(err.Error())
			}
			sg := result.SecurityGroups[0].IpPermissions
			//fmt.Println(sg)

			for count :=0; len(sg)>count; count++{
				ip := *sg[count].IpRanges[0].CidrIp
				assert.Equal(t, vpcCIDR, ip, "CIDR Ranges should be the same.")
			}

		})// ------->Closes function "test_non_routable_security_group_principal_policy_check"
	} // ------->Closes if len(sgNonRoutableID)


	//----------------------------------------------------------------------------------------
	// WEB - ROUTABLE SECURITY GROUP UNIT TEST
	//----------------------------------------------------------------------------------------
	if len(sgWebRoutableID)!=0 && len(sgWebRoutableID)>0 { 
		//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
		test_structure.RunTestStage(t, "test_web_routable_sg_id_compliance", func() {
			regexPrefixMatch := "^sg-"
			assert.Regexpf(t, regexPrefixMatch, sgWebRoutableID, "error message %s", "formatted")
		})

		//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
		test_structure.RunTestStage(t, "test_web_routable_sg_check", func() {
		//GETs the AWS Region from output of the terraform apply 
		aws_region := terraform.Output(t, terraformOptions, "aws_region")
		//Configures the session with AWS by loading the regions in which the infrastructure was created.
		sess := session.Must(session.NewSessionWithOptions(session.Options{
			SharedConfigState: session.SharedConfigEnable,
			Config:            aws.Config{Region: aws.String(aws_region)},
		},
		))
			//Specifies the AWS service being accessed
			svc := ec2.New(sess)
			
			//Specifies the AWS API being referenced and the parameters or filters
			input := &ec2.DescribeSecurityGroupsInput{
				GroupIds: []*string{
					aws.String(sgWebRoutableID),
				},
			}
			
			//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
			result, err := svc.DescribeSecurityGroups(input)
			//Checks if an error was thrown
			if err != nil {
				fmt.Println("Error getting VPC:")
				fmt.Println(err.Error())
			}
			sg := result.SecurityGroups[0].IpPermissions
			fmt.Println(sg)

			for count :=0; len(sg)>count; count++{
				
				for icount:=0; len(sg[count].IpRanges)>icount; icount++{
					ip := *sg[count].IpRanges[icount].CidrIp
					assert.NotEqual(t, "0.0.0.0/0", ip, "CIDR Ranges should be the same.")
					fmt.Println(*sg[count].IpRanges[icount].CidrIp)
				}
			}

		})// ------->Closes function "test_web_routable_security_group_check"
	} // ------->Closes if len(sgWebRoutableID)


	//----------------------------------------------------------------------------------------
	// DATABASE - ROUTABLE SECURITY GROUP UNIT TEST
	//----------------------------------------------------------------------------------------
	if len(sgDatabaseRoutableID)!=0 && len(sgDatabaseRoutableID)>0 { 
		//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
		test_structure.RunTestStage(t, "test_database_routable_sg_id_compliance", func() {
			regexPrefixMatch := "^sg-"
			assert.Regexpf(t, regexPrefixMatch, sgDatabaseRoutableID, "error message %s", "formatted")
		})

		//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
		test_structure.RunTestStage(t, "test_database_routable_sg_check", func() {
		//GETs the AWS Region from output of the terraform apply 
		aws_region := terraform.Output(t, terraformOptions, "aws_region")
		//Configures the session with AWS by loading the regions in which the infrastructure was created.
		sess := session.Must(session.NewSessionWithOptions(session.Options{
			SharedConfigState: session.SharedConfigEnable,
			Config:            aws.Config{Region: aws.String(aws_region)},
		},
		))
			//Specifies the AWS service being accessed
			svc := ec2.New(sess)
			
			//Specifies the AWS API being referenced and the parameters or filters
			input := &ec2.DescribeSecurityGroupsInput{
				GroupIds: []*string{
					aws.String(sgDatabaseRoutableID),
				},
			}
			
			//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
			result, err := svc.DescribeSecurityGroups(input)
			//Checks if an error was thrown
			if err != nil {
				fmt.Println("Error getting VPC:")
				fmt.Println(err.Error())
			}
			sg := result.SecurityGroups[0].IpPermissions
			fmt.Println(sg)

			for count :=0; len(sg)>count; count++{
				
				for icount:=0; len(sg[count].IpRanges)>icount; icount++{
					ip := *sg[count].IpRanges[icount].CidrIp
					assert.NotEqual(t, "0.0.0.0/0", ip, "CIDR Ranges should be the same.")
					fmt.Println(*sg[count].IpRanges[icount].CidrIp)
				}
			}

		})// ------->Closes function "test_web_routable_security_group_check"
	} // ------->Closes if len(sgDatabaseRoutableID)



	//----------------------------------------------------------------------------------------
	// KAFKA - ROUTABLE SECURITY GROUP UNIT TEST
	//----------------------------------------------------------------------------------------
	if len(sgKafkaRoutableID)!=0 && len(sgKafkaRoutableID)>0 { 
		//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
		test_structure.RunTestStage(t, "test_kafka_routable_sg_id_compliance", func() {
			regexPrefixMatch := "^sg-"
			assert.Regexpf(t, regexPrefixMatch, sgKafkaRoutableID, "error message %s", "formatted")
		})

		//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
		test_structure.RunTestStage(t, "test_kafka_routable_sg_check", func() {
		//GETs the AWS Region from output of the terraform apply 
		aws_region := terraform.Output(t, terraformOptions, "aws_region")
		//Configures the session with AWS by loading the regions in which the infrastructure was created.
		sess := session.Must(session.NewSessionWithOptions(session.Options{
			SharedConfigState: session.SharedConfigEnable,
			Config:            aws.Config{Region: aws.String(aws_region)},
		},
		))
			//Specifies the AWS service being accessed
			svc := ec2.New(sess)
			
			//Specifies the AWS API being referenced and the parameters or filters
			input := &ec2.DescribeSecurityGroupsInput{
				GroupIds: []*string{
					aws.String(sgKafkaRoutableID),
				},
			}
			
			//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
			result, err := svc.DescribeSecurityGroups(input)
			//Checks if an error was thrown
			if err != nil {
				fmt.Println("Error getting VPC:")
				fmt.Println(err.Error())
			}
			sg := result.SecurityGroups[0].IpPermissions
			fmt.Println(sg)

			for count :=0; len(sg)>count; count++{
				
				for icount:=0; len(sg[count].IpRanges)>icount; icount++{
					ip := *sg[count].IpRanges[icount].CidrIp
					assert.NotEqual(t, "0.0.0.0/0", ip, "CIDR Ranges should be the same.")
					fmt.Println(*sg[count].IpRanges[icount].CidrIp)
				}
			}

		})// ------->Closes function "test_web_routable_security_group_check"
	} // ------->Closes if len(sgKafkaRoutableID)



	//----------------------------------------------------------------------------------------
	// ELASTICSEARCH - ROUTABLE SECURITY GROUP UNIT TEST
	//----------------------------------------------------------------------------------------
	if len(sgElasticSearchRoutableID)!=0 && len(sgElasticSearchRoutableID)>0 { 
		//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
		test_structure.RunTestStage(t, "test_elasticsearch_routable_sg_id_compliance", func() {
			regexPrefixMatch := "^sg-"
			assert.Regexpf(t, regexPrefixMatch, sgElasticSearchRoutableID, "error message %s", "formatted")
		})

		//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
		test_structure.RunTestStage(t, "test_elasticsearch_routable_sg_check", func() {
		//GETs the AWS Region from output of the terraform apply 
		aws_region := terraform.Output(t, terraformOptions, "aws_region")
		//Configures the session with AWS by loading the regions in which the infrastructure was created.
		sess := session.Must(session.NewSessionWithOptions(session.Options{
			SharedConfigState: session.SharedConfigEnable,
			Config:            aws.Config{Region: aws.String(aws_region)},
		},
		))
			//Specifies the AWS service being accessed
			svc := ec2.New(sess)
			
			//Specifies the AWS API being referenced and the parameters or filters
			input := &ec2.DescribeSecurityGroupsInput{
				GroupIds: []*string{
					aws.String(sgElasticSearchRoutableID),
				},
			}
			
			//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
			result, err := svc.DescribeSecurityGroups(input)
			//Checks if an error was thrown
			if err != nil {
				fmt.Println("Error getting VPC:")
				fmt.Println(err.Error())
			}
			sg := result.SecurityGroups[0].IpPermissions
			fmt.Println(sg)

			for count :=0; len(sg)>count; count++{
				
				for icount:=0; len(sg[count].IpRanges)>icount; icount++{
					ip := *sg[count].IpRanges[icount].CidrIp
					assert.NotEqual(t, "0.0.0.0/0", ip, "CIDR Ranges should be the same.")
					fmt.Println(*sg[count].IpRanges[icount].CidrIp)
				}
			}

		})// ------->Closes function "test_web_routable_security_group_check"
	} // ------->Closes if len(sgElasticSearchRoutableID)

	
	//----------------------------------------------------------------------------------------
	// APACHESPARK - ROUTABLE SECURITY GROUP UNIT TEST
	//----------------------------------------------------------------------------------------
	if len(sgSparkRoutableID)!=0 && len(sgSparkRoutableID)>0 { 
		//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
		test_structure.RunTestStage(t, "test_apache_spark_routable_sg_id_compliance", func() {
			regexPrefixMatch := "^sg-"
			assert.Regexpf(t, regexPrefixMatch, sgSparkRoutableID, "error message %s", "formatted")
		})

		//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
		test_structure.RunTestStage(t, "test_apache_spark_routable_sg_check", func() {
		//GETs the AWS Region from output of the terraform apply 
		aws_region := terraform.Output(t, terraformOptions, "aws_region")
		//Configures the session with AWS by loading the regions in which the infrastructure was created.
		sess := session.Must(session.NewSessionWithOptions(session.Options{
			SharedConfigState: session.SharedConfigEnable,
			Config:            aws.Config{Region: aws.String(aws_region)},
		},
		))
			//Specifies the AWS service being accessed
			svc := ec2.New(sess)
			
			//Specifies the AWS API being referenced and the parameters or filters
			input := &ec2.DescribeSecurityGroupsInput{
				GroupIds: []*string{
					aws.String(sgSparkRoutableID),
				},
			}
			
			//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
			result, err := svc.DescribeSecurityGroups(input)
			//Checks if an error was thrown
			if err != nil {
				fmt.Println("Error getting VPC:")
				fmt.Println(err.Error())
			}
			sg := result.SecurityGroups[0].IpPermissions
			fmt.Println(sg)

			for count :=0; len(sg)>count; count++{
				
				for icount:=0; len(sg[count].IpRanges)>icount; icount++{
					ip := *sg[count].IpRanges[icount].CidrIp
					assert.NotEqual(t, "0.0.0.0/0", ip, "CIDR Ranges should be the same.")
					fmt.Println(*sg[count].IpRanges[icount].CidrIp)
				}
			}

		})// ------->Closes function "test_web_routable_security_group_check"
	} // ------->Closes if len(sgSparkRoutableID)



}// ------->Closes MAIN


