import requests

radarr_api_key = 'asdf'
radarr4k_api_key = 'asdf'

radarr_url = 'https://radarr.domain.tld/api/movie?apikey={}'.format(radarr_api_key)
radarr4k_url = 'https://radarr4k.domain.tld/api/movie?apikey={}'.format(radarr4k_api_key)

session = requests.session()

radarr_movies = session.get(radarr_url).json()
radarr4k_movies = session.get(radarr4k_url).json()

radarr_tmdbIds = [ movie['tmdbId'] for movie in radarr_movies ]
radarr4k_tmdbIds = [ movie['tmdbId'] for movie in radarr4k_movies if radarr4k_movies ]

missing_tmdbIds = [ tmdbId for tmdbId in radarr_tmdbIds if tmdbId not in radarr4k_tmdbIds ]

for movie in radarr_movies:
    if movie['tmdbId'] in missing_tmdbIds:
        payload = {
            'title': movie['title'],
            'qualityProfileId': 1,
            'titleSlug': movie['titleSlug'],
            'images': [],
            'tmdbId': movie['tmdbId'],
            'year': movie['year'],
            'path': movie['path'],
            'monitored': True,
        }
        p = session.post(radarr4k_url, json=payload)
        print('Adding {} to 4k instance'.format(movie['title']))
