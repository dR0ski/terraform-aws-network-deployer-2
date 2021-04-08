Feature: VPC Flow Log has been created with the correct properties

  Scenario: The Flow Log should have an IAM role assigned
    Given I have aws_flow_log defined
    Then it must contain iam_role_arn

  Scenario: The Flow Log has a destination log group
    Given I have aws_flow_log defined
    Then it must contain log_destination


