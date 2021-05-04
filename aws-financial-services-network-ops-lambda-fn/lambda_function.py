import json
import sys
import uuid
import datetime
import boto3
import botocore.exceptions

client = boto3.client('route53')
tgw_client = boto3.client('ec2')
resolver_client = boto3.client('route53resolver')
ram_client = boto3.client('ram')
event_client = boto3.client('events')

# -----------------------------------------------------------------------------------------------------
# Centralized DNS Resource Share Association Request | Association Event
# -----------------------------------------------------------------------------------------------------
def associate_vpc_with_existing_resolver_rule(vpc_id):
    """
    : Checks all existing shared resolver rule and creates an association request for each available resolver rule
    """
    rule_prefix = "rslvr-"
    rule_suffix = "-rule-for-"

    try:
        # List all AWS Route 53 Resolver rule
        list_rule_response = resolver_client.list_resolver_rules()

        # If the list response contains any rule then the response array is parsed
        if len(list_rule_response['ResolverRules']) > 0:
            # Processes each rules in the response list
            for rule in list_rule_response['ResolverRules']:
                # Checks if any rule matches the name format for resolver rules that are created by this solution.
                if rule_prefix in rule['Name'] and rule_suffix in rule['Name']:
                    # Creates an association between each resolver rule and the VPC that created the association request
                    response = resolver_client.associate_resolver_rule(
                        ResolverRuleId=rule['Id'],
                        Name=rule['Name'],
                        VPCId=vpc_id
                    )

    except Exception as e:
        print(e)


# -----------------------------------------------------------------------------------------------------
# Centralized AWS VPC Interface Endpoint | Complete Centralize Interface VPC Endpoint Association
# -----------------------------------------------------------------------------------------------------
def complete_centralized_interface_endpoint_association(hosted_zone_id, vpc_id, region):
    """
    : This AWS Lambda function takes the vpc id and region as input and returns a list of hosted zone ids as output.
    : Hosted Zone Associations created for each hosted zone
    """
    print("Initiating the association the VPC with all available interface endpoint Route 53 Private Hosted Zone")
    print("--------------------------------------------------------------------------------------------------------")
    print("List of Hosted Zones:-------> ", hosted_zone_id)
    print("--------------------------------------------------------------------------------------------------------")
    hosted_zone_id = hosted_zone_id.strip("[")
    hosted_zone_id = hosted_zone_id.strip("]")
    hosted_zone_id = hosted_zone_id.split(",")

    for zone in hosted_zone_id:
        zone_id = zone.strip(" ' ")
        print(zone_id)
        associate_response = client.associate_vpc_with_hosted_zone(
            HostedZoneId=str(zone_id),
            VPC={
                'VPCRegion': region,
                'VPCId': vpc_id
            },
            Comment= vpc_id+'-associated'
       )

    print(associate_response)
    print("--------------------------------------------------------------------------------------------------------")
    print("Spoke VPC association with centralized interface endpoint solution completed! ")
    print("--------------------------------------------------------------------------------------------------------")


# -----------------------------------------------------------------------------------------------------
# Centralized AWS VPC Interface Endpoint | PHZ Auth for Spoke VPC Id & Returns List to Spoke EventBus
# -----------------------------------------------------------------------------------------------------
def centralized_interface_endpoint_association(region, vpc_id, eventbus_arn):
    """
    : This AWS Lambda function takes the vpc id and region as input and returns a list of hosted zone ids as output.
    : Hosted Zone Associations created for each hosted zone
    """
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


    detail = {
        "hosted_zone_id": str(return_hosted_zone_id),
        "vpc_id": vpc_id,
        "vpc_region": region,
        "event_type": "interface-endpoints-association-completion-event"
    }

    details = json.dumps(detail)
    print(detail)

    response = event_client.put_events(
            Entries=[
                {
                    'Source': 'aws-fsf-network-ops.interface-endpoints-association-completion-event',
                    'DetailType': 'network-ops',
                    'Detail': details,
                    'EventBusName': eventbus_arn
                },
            ]
    )

    return response


# -----------------------------------------------------------------------------------------------------
# AWS Resource Access Manager (RAM) | Creates an AWS RAM Resource Share for the Resolver Rules
# -----------------------------------------------------------------------------------------------------
def aws_ram_resource_share_for_resolver_rule(aws_organizations_arn, rule_arn, rslvr_rule_name):
    try:
        resource_share_name = "ram-share-for-"+rslvr_rule_name

        ram_share_response = ram_client.create_resource_share(
            name=resource_share_name,
            resourceArns=[
                rule_arn
            ],
            principals=[
                aws_organizations_arn
            ],
            allowExternalPrincipals=False
        )

        print(ram_share_response)

    except Exception as e:
        print(e)


# -----------------------------------------------------------------------------------------------------
# Route 53 Private Hosted Zone Association | Associates Spoke PHZ with the Shared Services/DNS VPC
# -----------------------------------------------------------------------------------------------------
def route53_phz_association(hosted_zone_id, vpc_region, vpc_id, comment):
    """
    :param hosted_zone_id:
    :param vpc_region:
    :param vpc_id:
    :param comment:
    :return:

    """
    try:
        response = client.associate_vpc_with_hosted_zone(
            HostedZoneId=hosted_zone_id,
            VPC={
                'VPCRegion': vpc_region,
                'VPCId': vpc_id
            },
            Comment=comment
        )

        print(response)

    except Exception as e:
        print("Error executing the API for associating private hosted zone with VPC:", e)


# -----------------------------------------------------------------------------------------------------
# Route 53 Resolver Rule | This method creates a resolver forwarding rule
# -----------------------------------------------------------------------------------------------------
def resolver_rule(domain_name, host_vpc_id, rule_type, aws_organizations_arn):
    """
    :param domain_name:
    :param host_vpc_id:
    :param rule_type:
    :return: resolver_response
    """
    resolver_id = []
    resolver_ip = []
    print(domain_name)
    print(rule_type)
    dom = str(domain_name).replace(".", "-")
    rle = str(rule_type).casefold()
    rslvr_rule_name = "rslvr-" + rle + "-rule-for-" + dom

    list_rule_response = resolver_client.list_resolver_rules(
        Filters=[
            {
                'Name': 'Name',
                'Values': [
                    rslvr_rule_name,
                ]
            },
        ]
    )

    # print(list_rule_response)
    if len(list_rule_response['ResolverRules']) <= 0:
        # -----------------------------------------------------------------------
        # Route 53 Resolver  | -> Lists Inbound Resolver Endpoints
        # -----------------------------------------------------------------------
        try:
            inbound_response = resolver_client.list_resolver_endpoints(
                Filters=[
                    {
                        'Name': 'HostVPCId',
                        'Values': [host_vpc_id]
                    },
                    {
                        'Name': 'DIRECTION',
                        'Values': ['INBOUND']
                    }
                ]
            )
        except Exception as e:
            print("Error listing resolver endpoints for variable --inbound_response--:", e)

        # -----------------------------------------------------------------------
        # Route 53 Resolver | -> -> Lists Outbound Resolver Endpoints
        # -----------------------------------------------------------------------
        try:
            outbound_response = resolver_client.list_resolver_endpoints(
                Filters=[
                    {
                        'Name': 'HostVPCId',
                        'Values': [host_vpc_id]
                    },
                    {
                        'Name': 'DIRECTION',
                        'Values': ['OUTBOUND']
                    }
                ]
            )

            outbound_id = outbound_response['ResolverEndpoints'][0]['Id']

            id_list = inbound_response['ResolverEndpoints']

            for id in id_list:
                resolver_id.append(id['Id'])
                ip_response = resolver_client.list_resolver_endpoint_ip_addresses(
                    ResolverEndpointId=id['Id'],

                )
                for ip in ip_response['IpAddresses']:
                    resolver_ip.append({'Ip': ip['Ip'], 'Port': 53})

        except Exception as e:
            print(e)

        # -----------------------------------------------------------------------
        # Route 53 Resolver Rule | -> Creates either a Forward and System Rule
        # -----------------------------------------------------------------------
        try:
            resolver_response = resolver_client.create_resolver_rule(
                CreatorRequestId=rslvr_rule_name,
                Name=rslvr_rule_name,
                RuleType=rule_type,
                DomainName=domain_name,
                TargetIps=resolver_ip,
                ResolverEndpointId=outbound_id)

            resolver_rule_arn = resolver_response['ResolverRule']['Arn']
            aws_ram_resource_share_for_resolver_rule(aws_organizations_arn, resolver_rule_arn, rslvr_rule_name)

        except Exception as e:
            print(e)

    elif len(list_rule_response['ResolverRules']) > 0:
        print("Resolver Rule Already Exist.")
        print("Rule details listed below: ")
        print(list_rule_response['ResolverRules'])


# -----------------------------------------------------------------------------------------------------
# AWS Transit Gateway Route Table Association & Route Manipulation |
# -----------------------------------------------------------------------------------------------------
# -> Function performs route table association
# -> Function also performs route manipulation and route propagation based on VPC environment tag
# -----------------------------------------------------------------------------------------------------
def tgw_attachment_api(route_table_id, attachment_id, shared_route_table_id, access_shared_services_vpc,
                       environment_type, perform_east_west_packet_inspection, dev_table_id, uat_table_id, prod_table_id,
                       packet_inspection_table_id):
    """
    : AWS API Request for TGW Route Table Attachment & Propagation
    """
    response = tgw_client.associate_transit_gateway_route_table(TransitGatewayRouteTableId=route_table_id,
                                                                TransitGatewayAttachmentId=attachment_id)
    try:
        if (perform_east_west_packet_inspection == 'true' and access_shared_services_vpc == 'true') and (
                environment_type == "packet_inspection" or environment_type == "packet inspection" or environment_type == "packet-inspection" or environment_type == "Packet Inspection" or environment_type == "Packet-inspection" or environment_type == "Packet-Inspection" or environment_type == "Packet_Inspection" or environment_type == "PACKET INSPECTION"):
            # Adds packet inspection VPC routes to dev route table
            dev_route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=dev_table_id,
                TransitGatewayAttachmentId=attachment_id
            )

            # Adds packet inspection VPC routes to uat route table
            uat_route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=uat_table_id,
                TransitGatewayAttachmentId=attachment_id
            )

            # Adds packet inspection VPC routes to prod route table
            prod_route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=prod_table_id,
                TransitGatewayAttachmentId=attachment_id
            )

            # Adds packet inspection VPC routes to shared-services route table
            shared_route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=shared_route_table_id,
                TransitGatewayAttachmentId=attachment_id
            )
            return shared_route_propagation_response  # , dev_route_propagation_response, uat_route_propagation_response, prod_route_propagation_response

        if (perform_east_west_packet_inspection == 'false' and access_shared_services_vpc == 'true') and (
                environment_type == "Shared Services" or environment_type == "SHARED SERVICES" or environment_type == "SHARED-SERVICES" or environment_type == "Shared-Services" or environment_type == "shared services" or environment_type == "shared-services" or environment_type == "shared_services" or environment_type == "SHARED_SERVICES" or environment_type == "Shared_Services"):
            # Adds packet inspection VPC routes to dev route table
            dev_route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=dev_table_id,
                TransitGatewayAttachmentId=attachment_id
            )

            # Adds packet inspection VPC routes to uat route table
            uat_route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=uat_table_id,
                TransitGatewayAttachmentId=attachment_id
            )

            # Adds packet inspection VPC routes to prod route table
            prod_route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=prod_table_id,
                TransitGatewayAttachmentId=attachment_id
            )

            # Adds packet inspection VPC routes to shared-services route table
            shared_route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=packet_inspection_table_id,
                TransitGatewayAttachmentId=attachment_id
            )
            return shared_route_propagation_response  # , dev_route_propagation_response, uat_route_propagation_response, prod_route_propagation_response

        if (perform_east_west_packet_inspection == 'true') and (
                environment_type == "Development" or environment_type == "dev" or environment_type == "DEVELOPMENT" or environment_type == "development" or environment_type == "DEV",
                environment_type == "UAT" or environment_type == "User Acceptance Testing" or environment_type == "user acceptance testing" or environment_type == "TEST",
                environment_type == "Production" or environment_type == "PROD" or environment_type == "PRODUCTION"):
            # Adds packet inspection VPC routes to dev route table
            route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=packet_inspection_table_id,
                TransitGatewayAttachmentId=attachment_id
            )
            return route_propagation_response

        if (perform_east_west_packet_inspection == 'false' and access_shared_services_vpc == 'true') and (
                environment_type == "Development" or environment_type == "dev" or environment_type == "DEVELOPMENT" or environment_type == "development" or environment_type == "DEV",
                environment_type == "UAT" or environment_type == "User Acceptance Testing" or environment_type == "user acceptance testing" or environment_type == "TEST",
                environment_type == "Production" or environment_type == "PROD" or environment_type == "PRODUCTION"):
            # Adds packet inspection VPC routes to dev route table
            route_propagation_response = tgw_client.enable_transit_gateway_route_table_propagation(
                TransitGatewayRouteTableId=shared_route_table_id,
                TransitGatewayAttachmentId=attachment_id
            )
            return route_propagation_response

    except Exception as e:
        print(e)


def transit_gateway_route_table_association(tgw_attachment_id, tgw_dev_route_table_id, tgw_uat_route_table_id,
                                            tgw_prod_route_table_id, tgw_shared_services_route_table_id,
                                            tgw_packet_inspection_route_table_id, tgw_id, environment_type,
                                            access_shared_services_vpc, event_type,
                                            perform_east_west_packet_inspection):
    """
    : This function is used to associate an AWS VPC TGW attachment with the right TGW Route Table
    """
    print("-----------Initiating Transit Gateway Route Table Association & Route Propagation-----------")

    try:
        if environment_type == "Development" or environment_type == "dev" or environment_type == "DEVELOPMENT" or environment_type == "development" or environment_type == "DEV":
            tgw_attachment_api(tgw_dev_route_table_id, tgw_attachment_id, tgw_shared_services_route_table_id,
                               access_shared_services_vpc, environment_type, perform_east_west_packet_inspection,
                               tgw_dev_route_table_id, tgw_uat_route_table_id, tgw_prod_route_table_id,
                               tgw_packet_inspection_route_table_id)

        elif environment_type == "UAT" or environment_type == "User Acceptance Testing" or environment_type == "user acceptance testing" or environment_type == "TEST":
            tgw_attachment_api(tgw_uat_route_table_id, tgw_attachment_id, tgw_shared_services_route_table_id,
                               access_shared_services_vpc, environment_type, perform_east_west_packet_inspection,
                               tgw_dev_route_table_id, tgw_uat_route_table_id, tgw_prod_route_table_id,
                               tgw_packet_inspection_route_table_id)

        elif environment_type == "Production" or environment_type == "PROD" or environment_type == "PRODUCTION":
            tgw_attachment_api(tgw_prod_route_table_id, tgw_attachment_id, tgw_shared_services_route_table_id,
                               access_shared_services_vpc, environment_type, perform_east_west_packet_inspection,
                               tgw_dev_route_table_id, tgw_uat_route_table_id, tgw_prod_route_table_id,
                               tgw_packet_inspection_route_table_id)

        elif environment_type == "packet_inspection" or environment_type == "packet inspection" or environment_type == "packet-inspection" or environment_type == "Packet Inspection" or environment_type == "Packet-inspection" or environment_type == "Packet-Inspection" or environment_type == "Packet_Inspection" or environment_type == "PACKET INSPECTION":
            tgw_attachment_api(tgw_packet_inspection_route_table_id, tgw_attachment_id,
                               tgw_shared_services_route_table_id,
                               access_shared_services_vpc, environment_type, perform_east_west_packet_inspection,
                               tgw_dev_route_table_id, tgw_uat_route_table_id, tgw_prod_route_table_id,
                               tgw_packet_inspection_route_table_id)

        elif environment_type == "Shared Services" or environment_type == "SHARED SERVICES" or environment_type == "SHARED-SERVICES" or environment_type == "Shared-Services" or environment_type == "shared services" or environment_type == "shared-services" or environment_type == "shared_services" or environment_type == "SHARED_SERVICES" or environment_type == "Shared_Services":
            tgw_attachment_api(tgw_shared_services_route_table_id, tgw_attachment_id,
                               tgw_shared_services_route_table_id,
                               access_shared_services_vpc, environment_type, perform_east_west_packet_inspection,
                               tgw_dev_route_table_id, tgw_uat_route_table_id, tgw_prod_route_table_id,
                               tgw_packet_inspection_route_table_id)


    except Exception as e:
        print(e)

# -----------------------------------------------------------------------------------------------------
# Main | Handler | ->
# -----------------------------------------------------------------------------------------------------
def lambda_handler(event, context):
    """
    : This AWS Lambda function takes the vpc id and region as input and returns a list of hosted zone ids as output.
    : Hosted Zone Associations created for each hosted zone
    """
    print("Event Data: ", event['detail'])
    event_type = event['detail']['event_type']

    try:

        if event_type == 'centralized_dns_association_request':
                """
                : Event for associating a newly created spoke VPC with available AWS Route 53 Resolver Forward Rules
                """
                vpc_id = event['detail']['vpc_id']

                responses = associate_vpc_with_existing_resolver_rule(vpc_id)

                return responses

        # Centralized DNS Resource Share Request Event |
        # -----------------------------------------------------------------------
        if event_type == "centralized_dns_association_request":
            """
            : Event requesting the resource share arn for all resolver-rule that exist inside the Shared Services account
            """
            vpc_id = event['detail']['vpc_id']
            vpc_region = event['detail']['vpc_region']
            eventbus_arn = event['detail']['eventbus_arn']

            responses = list_aws_ram_resource_share_for_resolver_rule(vpc_region, vpc_id, eventbus_arn)

            # Return a list of hosted zone ids
            return {
                'statusCode': 200,
                'body': json.dumps(str(responses))
            }



        # Centralized Interface Endpoint Association Completion Event |
        # -----------------------------------------------------------------------
        if event_type == "interface-endpoints-association-completion-event":
            """
            : Event for associating spoke VPCs with the centralized VPC Endpoints that exist inside the Shared Services VPC
            """
            hosted_zone_id = event['detail']['hosted_zone_id']
            vpc_id = event['detail']['vpc_id']
            vpc_region = event['detail']['vpc_region']

            complete_centralized_interface_endpoint_association(hosted_zone_id, vpc_id, vpc_region)


        # Centralized Interface Endpoint Association Event |
        # -----------------------------------------------------------------------
        if event_type == "centralized_interface_endpoints_association_request":
            """
            : Event for associating spoke VPCs with the centralized VPC Endpoints that exist inside the Shared Services VPC
            """
            vpc_id = event['detail']['vpc_id']
            vpc_region = event['detail']['vpc_region']
            eventbus_arn = event['detail']['eventbus_arn']

            responses = centralized_interface_endpoint_association(vpc_region, vpc_id, eventbus_arn)

            # Return a list of hosted zone ids
            return {
                'statusCode': 200,
                'body': json.dumps(str(responses))
            }


        # Route 53 Event |
        # -----------------------------------------------------------------------
        if event_type == "route53_phz_association":
            """
            : Declares the variables that holds the event data necessaryb to exectue the below function
            """
            hosted_zone_id = event['detail']['hosted_zone_id']
            domain_name = event['detail']['domain_name']
            rule_type = event['detail']['rule_type']
            vpc_region = event['detail']['vpc_region']
            vpc_id = event['detail']['vpc_id']
            aws_organizations_id = event['detail']['aws_organizations_id']
            aws_organizations_arn = event['detail']['aws_organizations_arn']
            comment = 'Associated with Spoke Account Private Hosted Zone'

            # -----------------------------------------------------------------------
            # Function Call  | -> Associates Spoke PHZ with centralized DNS VPC
            # -----------------------------------------------------------------------
            route53_phz_association(hosted_zone_id, vpc_region, vpc_id, comment)

            # -----------------------------------------------------------------------
            # Function Call  | -> Creates a Route 53 Resolver Rule
            # -----------------------------------------------------------------------
            responses = resolver_rule(domain_name, vpc_id, rule_type, aws_organizations_arn)
            print(responses)

            # -----------------------------------------------------------------------
            # Function Call  | -> Creates an AWS RAM Resource Share for Resolver Rule
            # -----------------------------------------------------------------------
            # aws_ram_resource_share_for_resolver_rule(aws_organizations_id)

            # Return a list of hosted zone ids
            return {
                'statusCode': 200,
                'body': json.dumps(str(responses))
            }

        # Transit Gateway Event |
        # -----------------------------------------------------------------------
        if event_type == "tgw_route_table_association_n_propagation":
            """
            :
            """
            transit_gateway_attachment_id = event['detail']['transit_gateway_attachment_id']
            transit_gateway_id = event['detail']['transit_gateway_id']
            transit_gateway_dev_route_table_id = event['detail']['transit_gateway_dev_route_table_id']
            transit_gateway_uat_route_table_id = event['detail']['transit_gateway_uat_route_table_id']
            transit_gateway_shared_services_route_table_id = event['detail'][
                'transit_gateway_shared_services_route_table_id']
            transit_gateway_packet_inspection_route_table_id = event['detail'][
                'transit_gateway_packet_inspection_route_table_id']
            transit_gateway_production_route_table_id = event['detail']['transit_gateway_production_route_table_id']
            access_shared_services_vpc = event['detail']['access_shared_services_vpc']
            perform_east_west_packet_inspection = event['detail']['perform_east_west_packet_inspection']
            environment_type = event['detail']['environment_type']

            responses = transit_gateway_route_table_association(transit_gateway_attachment_id,
                                                                transit_gateway_dev_route_table_id,
                                                                transit_gateway_uat_route_table_id,
                                                                transit_gateway_production_route_table_id,
                                                                transit_gateway_shared_services_route_table_id,
                                                                transit_gateway_packet_inspection_route_table_id,
                                                                transit_gateway_id, environment_type,
                                                                access_shared_services_vpc, event_type,
                                                                perform_east_west_packet_inspection)
            # Return a list of hosted zone ids
            return {
                'statusCode': 200,
                'body': json.dumps(str(responses))
            }

    except Exception as e:
        print(e)
