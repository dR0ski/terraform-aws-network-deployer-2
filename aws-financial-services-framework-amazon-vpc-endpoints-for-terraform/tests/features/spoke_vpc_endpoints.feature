Feature: KMS cmk has been properly formed

  Scenario: The cmk key usage has been set to "ENCRYPT_DECRYPT"
    Given I have aws_kms_key defined
    Then it must contain key_usage
    And its value must match the "^ENCRYPT_DECRYPT$" regex

  Scenario: The cmk key has key rotation enabled
    Given I have aws_kms_key defined
    Then it must contain enable_key_rotation
    And its value must must be "true"

  Scenario: The cmk key is enabled
    Given I have aws_kms_key defined
    Then it must contain is_enabled
    And its value must must be "true"
