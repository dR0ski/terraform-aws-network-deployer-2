package test

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTerraformCheckI(t *testing.T) {
	t.Parallel()

	//workingDir := ".../examples"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples",
		VarFiles:     []string{"terraform.tfvars"},
	}

	defer test_structure.RunTestStage(t, "teardown", func() {
		//terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		terraform.InitAndApply(t, terraformOptions)
	})


	test_structure.RunTestStage(t, "vpc_flow_logs_is_enabled", func() {
		aws_region := terraform.Output(t, terraformOptions, "aws_region")
		sess := session.Must(session.NewSessionWithOptions(session.Options{
			SharedConfigState: session.SharedConfigEnable,
			Config:            aws.Config{Region: aws.String(aws_region)},
		},
		))

		//Get the Flow Log ID from output file
		flowLogId := terraform.Output(t, terraformOptions, "flow_log_id")

		//Expected Flow Log status
		expectedStatus := "ACTIVE"

		//Specifies the AWS service being accessed
		svc := ec2.New(sess)

		//Specifies the AWS API being referenced and the parameters or filters
		input := &ec2.DescribeFlowLogsInput{
			FlowLogIds: []*string{
				aws.String(flowLogId),
			},
		}

		result, err := svc.DescribeFlowLogs(input)

		if err != nil {
			if aerr, ok := err.(awserr.Error); ok {
				switch aerr.Code() {
				default:
					fmt.Println(aerr.Error())
				}
			} else {
				fmt.Println(err.Error())
			}
			return
		}

		if len(flowLogId) == 1 {
			for _, id := range flowLogId {
				fmt.Println(id)
				assert.Regexpf(t, expectedStatus, *result.FlowLogs[id].FlowLogStatus, "error message %s", "formatted")
			}
		}

	})

	//Should we tests for this case?
	//Need to find out how to provide 2 terratest multiple terraform.tfvars
	//test_structure.RunTestStage(t, "vpc_flow_logs_is_disabled", func() {
	//
	//	//Get the Flow Log ID from output file
	//	flowLogId := terraform.Output(t, terraformOptions, "flow_log_id")
	//
	//	//Expected Flow Log status
	//	expectedStatus := ""
	//
	//
	//	assert.Regexpf(t, expectedStatus, flowLogId, "error message %s", "formatted")
	//
	//})


}
