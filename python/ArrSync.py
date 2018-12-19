import requests

# Options are sonarr/radarr

runtype = 'sonarr'

url = 'https://domain.tld/sonarr'
api_key = 'asdf'

fourk_url = 'https://domain.tld/sonarr4k'
fourk_api_key = 'asdf'

full_url = f'{url}/api/series?apikey={api_key}'
fourk_full_url = f'{fourk_url}/api/series?apikey={fourk_api_key}'

idtype = None
if runtype == 'sonarr':
    idtype = 'tvdbId'
elif runtype == 'radarr':
    idtype = 'tmdbId'
else:
    exit(1)

session = requests.session()

regular = session.get(full_url).json()
fourk = session.get(fourk_full_url).json()

idtype_list = [ media[idtype] for media in regular ]
fourk_idtype_list = [ media[idtype] for media in fourk if fourk ]

missing_idtype = [ idt for idt in idtype_list if idt not in fourk_idtype_list ]

for media in regular:
    if media[idtype] in missing_idtype:
        payload = {
            'title': media['title'],
            'qualityProfileId': 1,
            'titleSlug': media['titleSlug'],
            'images': [],
            'path': media['path'],
            'monitored': True,
            'addOptions': {}
        }
        payload[idtype] = media[idtype],
        if runtype == 'sonarr':
            payload['seasons'] = []
            payload['addOptions']["searchForMissingEpisodes"] = True
        elif runtype == 'radarr':
            payload['year'] = media['year']
            payload['addOptions']["searchForMovie"] = True
            payload['minimumAvailability'] = 'inCinemas'
        p = session.post(fourk_full_url, json=payload)
        print('Adding {} to 4k instance'.format(media['title']))
