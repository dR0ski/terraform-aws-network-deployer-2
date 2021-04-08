
package test

import (
	"fmt"
	"strings"
	"encoding/json"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

//MAIN Function
func TestTerraformSpokeVPCEndpoints(t *testing.T) {
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
		//terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
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
	accountNumber := terraform.Output(t, terraformOptions, "account_id")
	vpceS3ID := terraform.Output(t, terraformOptions, "vpc_endpoint_s3")
	vpceDDBID := terraform.Output(t, terraformOptions, "vpc_endpoint_dynamodb")
	vpceSecretsMgrID := terraform.Output(t, terraformOptions, "vpc_endpoint_secrets_manager")
	vpceEC2ID := terraform.Output(t, terraformOptions, "vpc_endpoint_ec2")
	vpceSNSID := terraform.Output(t, terraformOptions, "vpc_endpoint_sns")
	vpceSQSID := terraform.Output(t, terraformOptions, "vpc_endpoint_sqs")
	vpceSTSID := terraform.Output(t, terraformOptions, "vpc_endpoint_sts")
	//----------------------------------------------------------------------------------------

	// Struct 
	//----------------------------------------------------------------------------------------
	type Statements struct {
		Effect string `json:"Effect"`
		Principal interface {} `json:"Principal"`
		Action interface{} `json:"Action"`
		Resource interface{} `json:"Resource"`		
	}
	
	type policyJSON struct{
		Version string `json:"Version"`
		Statement []Statements `json:"Statement"`
	}
	
	// Constructing the expected Principal Value 
	//----------------------------------------------------------------------------------------
	principal := `"Principal":{"AWS":"` 
	pARN := `arn:aws:iam::`
	pARNRoot := `:root`
	accountSpecific := `"}`
	principalJoined := principal+accountNumber+accountSpecific
	principalARNJoined := principal+pARN+accountNumber+pARNRoot+accountSpecific
	fmt.Println("Principal: ", principalJoined)
	fmt.Println("Principal: ", principalARNJoined)
	//----------------------------------------------------------------------------------------



	//myVpcID := terraform.Output(t, terraformOptions, "vpc_id")
	//----------------------------------------------------------------------------------------
	if len(vpceS3ID)!=0 && len(vpceS3ID)>0 { 
		//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
		test_structure.RunTestStage(t, "test_vpce_id_compliance", func() {
			regexPrefixMatch := "^vpce-"
			vpceS3ID := terraform.Output(t, terraformOptions, "vpc_endpoint_s3")
			assert.Regexpf(t, regexPrefixMatch, vpceS3ID, "error message %s", "formatted")
		})

		//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
		test_structure.RunTestStage(t, "test_s3_vpce_principal_policy_check", func() {
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
			input := &ec2.DescribeVpcEndpointsInput{
				VpcEndpointIds: []*string{
					aws.String(vpceS3ID),
				},
			}
			
			//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
			result, err := svc.DescribeVpcEndpoints(input)
			//Checks if an error was thrown
			if err != nil {
				fmt.Println("Error getting VPC:")
				fmt.Println(err.Error())
			}
			
			endpointsArray:=result.VpcEndpoints
			
			for count:=0; count<len(endpointsArray); count++{
				policyDoc := *result.VpcEndpoints[count].PolicyDocument
				
				if len(policyDoc)>0{
					var data policyJSON
					bytes := []byte(policyDoc)
					err := json.Unmarshal(bytes, &data)
					if err != nil {
						panic(err)
					}

					for lngth:=0; len(data.Statement)>lngth; lngth++{
						
						splt:= fmt.Sprintf("%v", data.Statement[0].Principal)
						spltArray := strings.Replace(splt, `map[AWS:`,`"Principal":{"AWS":"`, -1)
						splitArray := strings.Replace(spltArray, "]",`"}`, -1)
		
						fmt.Printf("%+v", splitArray)
						assert.Equalf(t, principalJoined, splitArray, "Error Message %s", "formatted")
					} // ------->Closes for lngth:=0;
				}// ------->Closes if len(policyDoc)
			}// ------->Closes for count:=0
		})// ------->Closes function "test_s3_vpce_principal_policy_check"
	} // ------->Closes if len(vpceS3ID)


//------------------------------------------->DYNAMODB VPCE

	if len(vpceDDBID)!=0 && len(vpceDDBID)>0 { 
		//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
		test_structure.RunTestStage(t, "test_ddb_vpce_id_compliance", func() {
			regexPrefixMatch := "^vpce-"
			//vpceDDBID := terraform.Output(t, terraformOptions, "vpc_endpoint_dynamodb")
			assert.Regexpf(t, regexPrefixMatch, vpceDDBID, "error message %s", "formatted")
		})

		//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
		test_structure.RunTestStage(t, "test_ddb_vpce_principal_policy_check", func() {
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
			input := &ec2.DescribeVpcEndpointsInput{
				VpcEndpointIds: []*string{
					aws.String(vpceDDBID),
				},
			}
			
			//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
			result, err := svc.DescribeVpcEndpoints(input)
			//Checks if an error was thrown
			if err != nil {
				fmt.Println("Error getting VPC:")
				fmt.Println(err.Error())
			}
			
			endpointsArray:=result.VpcEndpoints
			
			for count:=0; count<len(endpointsArray); count++{
				policyDoc := *result.VpcEndpoints[count].PolicyDocument
				
				if len(policyDoc)>0{
					var data policyJSON
					bytes := []byte(policyDoc)
					err := json.Unmarshal(bytes, &data)
					if err != nil {
						panic(err)
					}

					for lngth:=0; len(data.Statement)>lngth; lngth++{
						
						splt:= fmt.Sprintf("%v", data.Statement[0].Principal)
						spltArray := strings.Replace(splt, `map[AWS:`,`"Principal":{"AWS":"`, -1)
						splitArray := strings.Replace(spltArray, "]",`"}`, -1)
		
						fmt.Printf("%+v", splitArray)
						assert.Equalf(t, principalJoined, splitArray, "Error Message %s", "formatted")
					} // ------->Closes for lngth:=0;
				}// ------->Closes if len(policyDoc)
			}// ------->Closes for count:=0
		})// ------->Closes function "test_ddb_vpce_principal_policy_check"
	} // ------->Closes if len(vpceDDBID)


//------------------------------------------->SECRETS MANAGER VPCE

if len(vpceSecretsMgrID)!=0 && len(vpceSecretsMgrID)>0 { 
	//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
	test_structure.RunTestStage(t, "test_secrets_mgr_vpce_id_compliance", func() {
		regexPrefixMatch := "^vpce-"
		assert.Regexpf(t, regexPrefixMatch, vpceSecretsMgrID, "error message %s", "formatted")
	})

	//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
	test_structure.RunTestStage(t, "test_secrets_mgr_vpce_principal_policy_check", func() {
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
		input := &ec2.DescribeVpcEndpointsInput{
			VpcEndpointIds: []*string{
				aws.String(vpceSecretsMgrID),
			},
		}
		
		//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
		result, err := svc.DescribeVpcEndpoints(input)
		//Checks if an error was thrown
		if err != nil {
			fmt.Println("Error getting VPC:")
			fmt.Println(err.Error())
		}
		
		endpointsArray:=result.VpcEndpoints
		
		for count:=0; count<len(endpointsArray); count++{
			policyDoc := *result.VpcEndpoints[count].PolicyDocument
			
			if len(policyDoc)>0{ 
				var data policyJSON
				bytes := []byte(policyDoc)
				err := json.Unmarshal(bytes, &data)
				if err != nil {
					panic(err)
				}

				for lngth:=0; len(data.Statement)>lngth; lngth++{
					
					splt:= fmt.Sprintf("%v", data.Statement[0].Principal)
					spltArray := strings.Replace(splt, `map[AWS:`,`"Principal":{"AWS":"`, -1)
					splitArray := strings.Replace(spltArray, "]",`"}`, -1)
	
					fmt.Printf("%+v", splitArray)
					assert.Equalf(t, principalARNJoined, splitArray, "Error Message %s", "formatted")
				} // ------->Closes for lngth:=0;
			}// ------->Closes if len(policyDoc)
		}// ------->Closes for count:=0
	})// ------->Closes function "test_secrets_mgr_vpce_principal_policy_check"
} // ------->Closes if len(vpceSecretsMgrID)


//------------------------------------------->EC2 VPCE

if len(vpceEC2ID)!=0 && len(vpceEC2ID)>0 { 
	//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
	test_structure.RunTestStage(t, "test_ec2_vpce_id_compliance", func() {
		regexPrefixMatch := "^vpce-"
		assert.Regexpf(t, regexPrefixMatch, vpceEC2ID, "error message %s", "formatted")
	})

	//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
	test_structure.RunTestStage(t, "test_ec2_vpce_principal_policy_check", func() {
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
		input := &ec2.DescribeVpcEndpointsInput{
			VpcEndpointIds: []*string{
				aws.String(vpceEC2ID),
			},
		}
		
		//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
		result, err := svc.DescribeVpcEndpoints(input)
		//Checks if an error was thrown
		if err != nil {
			fmt.Println("Error getting VPC:")
			fmt.Println(err.Error())
		}
		
		endpointsArray:=result.VpcEndpoints
		
		for count:=0; count<len(endpointsArray); count++{
			policyDoc := *result.VpcEndpoints[count].PolicyDocument
			
			if len(policyDoc)>0{ 
				var data policyJSON
				bytes := []byte(policyDoc)
				err := json.Unmarshal(bytes, &data)
				if err != nil {
					panic(err)
				}

				for lngth:=0; len(data.Statement)>lngth; lngth++{
					
					splt:= fmt.Sprintf("%v", data.Statement[0].Principal)
					spltArray := strings.Replace(splt, `map[AWS:`,`"Principal":{"AWS":"`, -1)
					splitArray := strings.Replace(spltArray, "]",`"}`, -1)
	
					fmt.Printf("%+v", splitArray)
					assert.Equalf(t, principalARNJoined, splitArray, "Error Message %s", "formatted")
				} // ------->Closes for lngth:=0;
			}// ------->Closes if len(policyDoc)
		}// ------->Closes for count:=0
	})// ------->Closes function "test_ec2_vpce_principal_policy_check"
} // ------->Closes if len(vpceEC2ID)


//------------------------------------------->SNS VPCE

if len(vpceSNSID)!=0 && len(vpceSNSID)>0 { 
	//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
	test_structure.RunTestStage(t, "test_sns_vpce_id_compliance", func() {
		regexPrefixMatch := "^vpce-"
		assert.Regexpf(t, regexPrefixMatch, vpceSNSID, "error message %s", "formatted")
	})

	//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
	test_structure.RunTestStage(t, "test_sns_vpce_principal_policy_check", func() {
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
		input := &ec2.DescribeVpcEndpointsInput{
			VpcEndpointIds: []*string{
				aws.String(vpceSNSID),
			},
		}
		
		//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
		result, err := svc.DescribeVpcEndpoints(input)
		//Checks if an error was thrown
		if err != nil {
			fmt.Println("Error getting VPC:")
			fmt.Println(err.Error())
		}
		
		endpointsArray:=result.VpcEndpoints
		
		for count:=0; count<len(endpointsArray); count++{
			policyDoc := *result.VpcEndpoints[count].PolicyDocument
			
			if len(policyDoc)>0{ 
				var data policyJSON
				bytes := []byte(policyDoc)
				err := json.Unmarshal(bytes, &data)
				if err != nil {
					panic(err)
				}

				for lngth:=0; len(data.Statement)>lngth; lngth++{
					
					splt:= fmt.Sprintf("%v", data.Statement[0].Principal)
					spltArray := strings.Replace(splt, `map[AWS:`,`"Principal":{"AWS":"`, -1)
					splitArray := strings.Replace(spltArray, "]",`"}`, -1)
	
					fmt.Printf("%+v", splitArray)
					assert.Equalf(t, principalARNJoined, splitArray, "Error Message %s", "formatted")
				} // ------->Closes for lngth:=0;
			}// ------->Closes if len(policyDoc)
		}// ------->Closes for count:=0
	})// ------->Closes function "test_sns_vpce_principal_policy_check"
} // ------->Closes if len(vpceSNSID)


//------------------------------------------->SQS VPCE

if len(vpceSQSID)!=0 && len(vpceSQSID)>0 { 
	//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
	test_structure.RunTestStage(t, "test_sqs_vpce_id_compliance", func() {
		regexPrefixMatch := "^vpce-"
		assert.Regexpf(t, regexPrefixMatch, vpceSQSID, "error message %s", "formatted")
	})

	//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
	test_structure.RunTestStage(t, "test_sqs_vpce_principal_policy_check", func() {
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
		input := &ec2.DescribeVpcEndpointsInput{
			VpcEndpointIds: []*string{
				aws.String(vpceSQSID),
			},
		}
		
		//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
		result, err := svc.DescribeVpcEndpoints(input)
		//Checks if an error was thrown
		if err != nil {
			fmt.Println("Error getting VPC:")
			fmt.Println(err.Error())
		}
		
		endpointsArray:=result.VpcEndpoints
		
		for count:=0; count<len(endpointsArray); count++{
			policyDoc := *result.VpcEndpoints[count].PolicyDocument
			if len(policyDoc)>0{ 
				var data policyJSON
				bytes := []byte(policyDoc)
				err := json.Unmarshal(bytes, &data)
				if err != nil {
					panic(err)
				}

				for lngth:=0; len(data.Statement)>lngth; lngth++{
					
					splt:= fmt.Sprintf("%v", data.Statement[0].Principal)
					spltArray := strings.Replace(splt, `map[AWS:`,`"Principal":{"AWS":"`, -1)
					splitArray := strings.Replace(spltArray, "]",`"}`, -1)
	
					fmt.Printf("%+v", splitArray)
					assert.Equalf(t, principalARNJoined, splitArray, "Error Message %s", "formatted")
				} // ------->Closes for lngth:=0;
			}// ------->Closes if len(policyDoc)
		}// ------->Closes for count:=0
	})// ------->Closes function "test_sns_vpce_principal_policy_check"
} // ------->Closes if len(vpceSQSID)


//------------------------------------------->STS VPCE

if len(vpceSTSID)!=0 && len(vpceSTSID)>0 { 
	//Checks the output variable to ensure the VPC Endpoint ID AWS Compliant 
	test_structure.RunTestStage(t, "test_sts_vpce_id_compliance", func() {
		regexPrefixMatch := "^vpce-"
		assert.Regexpf(t, regexPrefixMatch, vpceSTSID, "error message %s", "formatted")
	})

	//Function for checking that each VPC Endpoint with an endpoint policy has the account as 
	test_structure.RunTestStage(t, "test_sts_vpce_principal_policy_check", func() {
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
		input := &ec2.DescribeVpcEndpointsInput{
			VpcEndpointIds: []*string{
				aws.String(vpceSTSID),
			},
		}
		
		//API call to the EC2 service using the input filter. Success is stored in the 'result' variable and error exceptions are stored inside 'err'
		result, err := svc.DescribeVpcEndpoints(input)
		//Checks if an error was thrown
		if err != nil {
			fmt.Println("Error getting VPC:")
			fmt.Println(err.Error())
		}
		
		endpointsArray:=result.VpcEndpoints
		
		for count:=0; count<len(endpointsArray); count++{
			policyDoc := *result.VpcEndpoints[count].PolicyDocument
			if len(policyDoc)>0{ 
				//policyDoc := *result.VpcEndpoints[count].PolicyDocument
				var data policyJSON
				bytes := []byte(policyDoc)
				err := json.Unmarshal(bytes, &data)
				if err != nil {
					panic(err)
				}

				for lngth:=0; len(data.Statement)>lngth; lngth++{
					splt:= fmt.Sprintf("%v", data.Statement[0].Principal)
					spltArray := strings.Replace(splt, `map[AWS:`,`"Principal":{"AWS":"`, -1)
					splitArray := strings.Replace(spltArray, "]",`"}`, -1)
	
					fmt.Printf("%+v", splitArray)
					assert.Equalf(t, principalARNJoined, splitArray, "Error Message %s", "formatted")
				} // ------->Closes for lngth:=0;
			}// ------->Closes if len(policyDoc)
		}// ------a->Closes for count:=0
	})// ------->Closes function "test_sts_vpce_principal_policy_check"
} // ------->Closes if len(vpceSTSID)


}// ------->Closes MAIN

