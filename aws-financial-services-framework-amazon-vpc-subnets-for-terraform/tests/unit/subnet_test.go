package test

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)
//MAIN Function
func TestTerraformSubnet(t *testing.T) {
	t.Parallel()


	//Configures the parameters needed to conduct the test
	terraformOptions := &terraform.Options{
		//Specifies the working directory for your terraform files. Ideally, this should "
		TerraformDir: "../../examples",
		//Loads all the variables specified in the
		VarFiles:     []string{"terraform.tfvars"},
	}

	//Defers TERRAFORM DESTROY until the test functions are completed
	defer test_structure.RunTestStage(t, "teardown", func() {
		//terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
		terraform.Destroy(t, terraformOptions)
	})

	//Triggers a TERRAFORM APPLY on the TERRAFORM Template
	test_structure.RunTestStage(t, "deploy", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	//------------------------------------------------------------------------------------------------------------------
	//SUBNETS
	//------------------------------------------------------------------------------------------------------------------

	privateSubnet := terraform.Output(t, terraformOptions, "routable_subnets")
	routableSubnet := terraform.Output(t, terraformOptions, "externally_routable_subnets")
	tgwSubnet := terraform.Output(t, terraformOptions, "transit_gateway_subnets")

	if len(privateSubnet)!=0 || len(routableSubnet)!=0 || len(tgwSubnet)!=0 {

		fmt.Println("Subnet Array not empty!")
		fmt.Println(privateSubnet)

		//Function for checking if DNS Support was enabled
		test_structure.RunTestStage(t, "test_private_subnet_public_ip_mapped_on_launch", func() {
			//GETs the AWS Region from output of the terraform apply
			aws_region := terraform.Output(t, terraformOptions, "aws_region")
			//Configures the session with AWS by loading the regions in which the infrastructure was created.
			sess := session.Must(session.NewSessionWithOptions(session.Options{
				SharedConfigState: session.SharedConfigEnable,
				Config:            aws.Config{Region: aws.String(aws_region)},
			},
			))

			//GETs the VPC_ID from the output file after the TERRAFORM APPLY
			myVpcID := terraform.Output(t, terraformOptions, "vpc_id")

			//Specifies the AWS service being accessed
			svc := ec2.New(sess)

			input := &ec2.DescribeSubnetsInput{
				Filters: []*ec2.Filter{
					{
						Name: aws.String("vpc-id"),
						Values: []*string{
							aws.String(myVpcID),
						},
					},
				},
			}


			result, err := svc.DescribeSubnets(input)

			if err != nil {
				fmt.Println("Error getting VPC:")
				fmt.Println(err.Error())
			}

			fmt.Println(result)

			subnetArray:=result.Subnets

			for count:=0; count<len(subnetArray); count++{
				assert.Falsef(t, *subnetArray[count].MapPublicIpOnLaunch, "Error Message %s", "formatted")
			}

		})

	} // Closes IF statement



}

