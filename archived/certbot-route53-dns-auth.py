#!/usr/bin/env python

import boto3

from time import sleep
from os import environ as en

# OS Environment mappings
domain = en['CERTBOT_DOMAIN'].strip('*.') if en['CERTBOT_DOMAIN'].startswith('*.') else en['CERTBOT_DOMAIN']
validation_token = en["CERTBOT_VALIDATION"]

client = boto3.client('route53')
recordName = '_acme-challenge.' + domain
zoneID = [zone['Id'] for zone in client.list_hosted_zones_by_name()['HostedZones'] if domain in zone['Name']][0]
record_precheck = client.test_dns_answer(HostedZoneId=zoneID, RecordName=recordName, RecordType='TXT')['RecordData']
dns1_verification = [{'Value': '"{}"'.format(validation_token)}]

if record_precheck:
    for record in record_precheck:
        dns1_verification.append({'Value': record})

changes = {
    'Changes': [
        {
            'Action': 'UPSERT',
            'ResourceRecordSet': {
                'Name': recordName,
                'Type': 'TXT',
                'TTL': 300,
                'ResourceRecords': dns1_verification
            }
        }
    ]
}

response = client.change_resource_record_sets(HostedZoneId=zoneID, ChangeBatch=changes)

sleep(15)
