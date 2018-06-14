import os
from time import sleep
import boto3

domain = 'domain.tld'

client = boto3.client('route53')
recordName = '_acme-challenge.' + domain
zoneID = [ zone['Id'] for zone in client.list_hosted_zones_by_name()['HostedZones'] if domain in zone['Name'] ][0]
record_precheck = client.test_dns_answer(HostedZoneId=zoneID, RecordName=recordName, RecordType='TXT')['RecordData']
dns1_verification = [{'value': os.environ["CERTBOT_VALIDATION"]}]

if record_precheck:
    for record in record_precheck:
        dns1_verification.append({'Value': record})

response = client.change_resource_record_sets(
    HostedZoneId=zoneID,
    ChangeBatch={
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
)

sleep(15)
