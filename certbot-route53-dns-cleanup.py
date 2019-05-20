#!/usr/bin/env python
import boto3

from os import environ as en

domain = en['CERTBOT_DOMAIN'].strip('*.') if en['CERTBOT_DOMAIN'].startswith('*.') else en['CERTBOT_DOMAIN']
validation_token = en["CERTBOT_VALIDATION"]

client = boto3.client('route53')
recordName = '_acme-challenge.' + domain
zoneID = [zone['Id'] for zone in client.list_hosted_zones_by_name()['HostedZones'] if domain in zone['Name']][0]
record_precheck = client.test_dns_answer(HostedZoneId=zoneID, RecordName=recordName, RecordType='TXT')['RecordData']
dns1_verification = [{'Value': '"{}"'.format(validation_token)}]
new_recordset = [{'Value': record} for record in record_precheck if record != dns1_verification]

changes = {
    'Changes': [
        {
            'Action': 'DELETE',
            'ResourceRecordSet': {
                'Name': recordName,
                'Type': 'TXT',
                'TTL': 300,
                'ResourceRecords': new_recordset
            }
        }
    ]
}

if record_precheck:
    response = client.change_resource_record_sets(HostedZoneId=zoneID, ChangeBatch=changes)
