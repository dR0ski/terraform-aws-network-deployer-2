import json
import boto3
client = boto3.client('route53')

def lambda_handler(event, context):
    """
    : This AWS Lambda function takes the vpc id and region as input and returns a list of hosted zone ids as output.
    : Hosted Zone Associations created for each hosted zone

    """
    print("Event Data: ", event['queryStringParameters'])
    region = event['queryStringParameters']['aws_region']
    vpc_id = event['queryStringParameters']['vpc_id']

    a_response = client.list_hosted_zones()

    comment = "'Centralize-VPC-Interface-Endpoint-Managed-by-Terraform'"
    private_zone = True
    hosted_zone_id = []
    return_hosted_zone_id =[]

    for zone in a_response['HostedZones']:
        config = zone['Config']
        config = dict(config)
        if 'Comment' in config and 'PrivateZone' in config:
            if 'Centralize-VPC-Interface-Endpoint-Managed-by-Terraform' in config['Comment'] and config['PrivateZone']==True:
                hosted_zone_id.append(zone['Id'].replace("/hostedzone/",""))

    for hosted_zone in hosted_zone_id:
        print("Currently Associating Hosted Zone: ", hosted_zone)
        hosted_zone_response = client.create_vpc_association_authorization(
            HostedZoneId=hosted_zone,
            VPC={
                    'VPCRegion': region,
                    'VPCId': vpc_id
            }
        )
        return_hosted_zone_id.append(hosted_zone)
        print('Processed: ', hosted_zone_response)

    # Return a list of hosted zone ids
    return {
        'statusCode': 200,
        'body': json.dumps(str(return_hosted_zone_id))
    }