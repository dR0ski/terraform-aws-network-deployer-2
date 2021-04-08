import json
import boto3

client = boto3.client('route53')
event_client = boto3.client('events')


# -----------------------------------------------------------------------------------------------------
# Centralized DNS Resource Share Association Request | Association Event
# -----------------------------------------------------------------------------------------------------
def centralized_dns_resource_share_association_request(vpc_id, eventbus_arn, event_type, vpc_region):
    """
    : This method writes an event to the shared services eventbus
    : The event is a request to Route 53 PHZ that asks the question, "Do you have PHZs for interface Endpoints?"
    """
    detail = {
            "vpc_id": vpc_id,
            "vpc_region": vpc_region,
            "event_type": event_type
    }

    details = json.dumps(detail)

    print("Detail Payload: ")
    print(details)

    response = event_client.put_events(
        Entries=[
            {
                'Source': 'aws-fsf-network-ops.dns-resolver-rule-association-request-event',
                'DetailType': 'network-ops',
                'Detail': details,
                'EventBusName': eventbus_arn
            },
        ]
    )

    print(response)



# -----------------------------------------------------------------------------------------------------
# Centralized AWS VPC Interface Endpoint | Populate Shared Services EventBus w/ Association Event
# -----------------------------------------------------------------------------------------------------
# -> This event is a request to the Shared Services account for the hosted zone ID of the PHZs
#   -> These Private Hosted Zones (PHZ) front-ends the interface endpoint host endpoints
# -----------------------------------------------------------------------------------------------------
def centralized_interface_endpoint_association_request(vpc_id, eventbus_arn, event_type, vpc_region, spoke_eventbus_arn):
    """
    : This method writes an event to the shared services eventbus
    : The event is a request to Route 53 PHZ that asks the question, "Do you have PHZs for interface Endpoints?"
    """
    detail = {
            "vpc_id": vpc_id,
            "vpc_region": vpc_region,
            "eventbus_arn": spoke_eventbus_arn,
            "event_type": event_type
    }

    details = json.dumps(detail)

    print("Detail Payload: ")
    print(details)

    response = event_client.put_events(
        Entries=[
            {
                'Source': 'aws-fsf-network-ops.interface-endpoints-association-event',
                'DetailType': 'network-ops',
                'Detail': details,
                'EventBusName': eventbus_arn
            },
        ]
    )

    print(response)


# -----------------------------------------------------------------------------------------------------
# AWS Transit Gateway (TGW) | Populate Shared Services EventBus with a TGW Association Request Event
# -----------------------------------------------------------------------------------------------------
def transit_gateway_route_table_association(tgw_attachment_id, tgw_dev_route_table_id, tgw_uat_route_table_id,
                                            tgw_prod_route_table_id, tgw_shared_services_route_table_id,
                                            tgw_packet_inspection_route_table_id, tgw_id, environment_type,
                                            access_shared_services_vpc, eventbus_arn, event_type,
                                            perform_east_west_packet_inspection):
    """
    : This function is used to associate an AWS VPC TGW attachment with the right TGW Route Table
    """
    print("-----------Transit Gateway Route Table Association & Route Propagation-----------")
    detail = {
        "transit_gateway_attachment_id": tgw_attachment_id,
        "transit_gateway_id": tgw_id,
        "transit_gateway_dev_route_table_id": tgw_dev_route_table_id,
        "transit_gateway_uat_route_table_id": tgw_uat_route_table_id,
        "transit_gateway_shared_services_route_table_id": tgw_shared_services_route_table_id,
        "transit_gateway_packet_inspection_route_table_id": tgw_packet_inspection_route_table_id,
        "transit_gateway_production_route_table_id": tgw_prod_route_table_id,
        "access_shared_services_vpc": access_shared_services_vpc,
        "perform_east_west_packet_inspection": perform_east_west_packet_inspection,
        "environment_type": environment_type,
        "event_type": event_type
    }

    details = json.dumps(detail)

    print("Detail Payload: ")
    print(details)

    response = event_client.put_events(
        Entries=[
            {
                'Source': 'aws-fsf-network-ops.route-table-associate-n-route-propagation-event',
                'DetailType': 'network-ops',
                'Detail': details,
                'EventBusName': eventbus_arn
            },
        ]
    )
    print("-----------Transit Gateway Route Table Association & Route Propagation Completed-----------")
    print(response)


# -----------------------------------------------------------------------------------------------------
# Centralized DNS | Populate Shared Services EventBus w/ Route 53 PHZ Association Request Event
# -----------------------------------------------------------------------------------------------------
def route_53_phz_association(id, region, bus_arn, zone_id, event_type, domain_name, rule_type, aws_organizations_id, aws_organizations_arn):
    """
    : This function is used to associate an AWS VPC TGW attachment with the right TGW Route Table
    """
    try:
        print("Initiating PHZ Association.......")

        split_domain_name = domain_name.split(".")
        domain_dot_count = len(split_domain_name)

        if rule_type == "FORWARD" and domain_dot_count >= 3:
            domain_name = split_domain_name[len(split_domain_name)-2]+"."+split_domain_name[len(split_domain_name)-1]
            print(domain_name)

        detail = {
            "vpc_id": id,
            "vpc_region": region,
            "hosted_zone_id": zone_id,
            "domain_name": domain_name,
            "rule_type": rule_type,
            "aws_organizations_id": aws_organizations_id,
            "aws_organizations_arn": aws_organizations_arn,
            "event_type": event_type
        }

        details = json.dumps(detail)

        print(details)
        print("eventbus_arn: ", bus_arn)

        response = event_client.put_events(
            Entries=[
                {
                    'Source': 'aws-fsf-network-ops.associate-with-spoke-private-hosted-zone-event',
                    'DetailType': 'network-ops',
                    'Detail': details,
                    'EventBusName': bus_arn
                },
            ]
        )
        print("-----------PHZ Association Completed---------")
        print(response)

    except Exception as e:
        print(e)


# -----------------------------------------------------------------------------------------------------
# HANDLER / MAIN | Checks the Event Types and routes the event to the right function
# -----------------------------------------------------------------------------------------------------
def lambda_handler(event, context):
    """
    : This AWS Lambda function takes the vpc id and region as input and returns a list of hosted zone ids as output.
    : Hosted Zone Associations created for each hosted zone
    """
    event_type = event['event_type']
    eventbus_arn = event['eventbus_arn']

    if event_type == 'centralized_dns_association_request':
        """
        : Event for associating a newly created spoke VPC with available AWS Route 53 Resolver Forward Rules
        """
        vpc_id = event['vpc_id']
        vpc_region = event['vpc_region']

        responses = centralized_dns_resource_share_association_request(vpc_id, eventbus_arn, event_type, vpc_region)

        return responses


    if event_type == 'centralized_interface_endpoints_association_request':
        """
        : Event for associating spoke VPCs with the centralized VPC Endpoints that exist inside the Shared Services VPC
        """
        vpc_id = event['vpc_id']
        vpc_region = event['vpc_region']
        spoke_eventbus_arn = event['spoke_eventbus_arn']

        responses = {"event_type":"centralized_interface_endpoints_association_request", "Status":"First phase of association works!"}
        print(responses)

        centralized_interface_endpoint_association_request(vpc_id, eventbus_arn, event_type, vpc_region, spoke_eventbus_arn)

        return responses


    if event_type == "route53_phz_association":
        """
        : Checks the event type and executes the function that adds an event for phz association
        """
        vpc_id = event['vpc_id']
        vpc_region = event['vpc_region']
        hosted_zone_id = event['hosted_zone_id']
        domain_name = event['domain_name']
        rule_type = event['rule_type']
        aws_organizations_id = event['aws_organizations_id']
        aws_organizations_arn = event['aws_organizations_arn']

        responses = route_53_phz_association(vpc_id, vpc_region, eventbus_arn, hosted_zone_id, event_type, domain_name,
                                             rule_type, aws_organizations_id, aws_organizations_arn)

    if event_type == "tgw_route_table_association_n_propagation":
        """
        : Checks the event type and executes the function that adds an event
        : For TGW Route Table Association & Propagation
        """

        transit_gateway_attachment_id = event['transit_gateway_attachment_id']
        transit_gateway_id = event['transit_gateway_id']
        transit_gateway_dev_route_table_id = event['transit_gateway_dev_route_table_id']
        transit_gateway_uat_route_table_id = event['transit_gateway_uat_route_table_id']
        transit_gateway_shared_services_route_table_id = event['transit_gateway_shared_services_route_table_id']
        transit_gateway_packet_inspection_route_table_id = event['transit_gateway_packet_inspection_route_table_id']
        transit_gateway_production_route_table_id = event['transit_gateway_production_route_table_id']
        access_shared_services_vpc = event['access_shared_services_vpc']
        perform_east_west_packet_inspection = event['perform_east_west_packet_inspection']
        environment_type = event['environment_type']

        print("established!")

        responses = transit_gateway_route_table_association(transit_gateway_attachment_id,
                                                            transit_gateway_dev_route_table_id,
                                                            transit_gateway_uat_route_table_id,
                                                            transit_gateway_production_route_table_id,
                                                            transit_gateway_shared_services_route_table_id,
                                                            transit_gateway_packet_inspection_route_table_id,
                                                            transit_gateway_id, environment_type,
                                                            access_shared_services_vpc, eventbus_arn, event_type,
                                                            perform_east_west_packet_inspection)

    # Return a list of hosted zone ids
    return {
        'statusCode': 200,
        'body': json.dumps(str(responses))
    }
