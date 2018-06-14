import boto3

domain = 'domain.tld.' # Trailing period required!

client = boto3.client('route53')
recordName = '_acme-challenge.' + domain
zoneID = [ zone['Id'] for zone in client.list_hosted_zones_by_name()['HostedZones'] if zone['Name'] == domain ][0]
record_precheck = client.test_dns_answer(HostedZoneId=zoneID, RecordName=recordName, RecordType='TXT')['RecordData']

if record_precheck:
    response = client.change_resource_record_sets(
        HostedZoneId=zoneID,
        ChangeBatch={
            'Changes': [
                {
                    'Action': 'DELETE',
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
