import json
from sys import argv
from pymediainfo import MediaInfo

media_info = MediaInfo.parse(argv[1])
media = json.loads(media_info.to_json())['tracks']

info = {
    'general': {},
    'video': {},
    'audio': {},
    'text': {}
}

for section in media:
    stream_type = section['kind_of_stream']
    if stream_type == 'General':
        info['general'] = section
    elif stream_type == 'Video':
        info['video'] = section
    elif stream_type == 'Audio':
        info['audio'][section['track_id']] = section
    elif stream_type == 'Text':
        info['text'][section['track_id']] = section
output = []

output.append(' ____  _      _          ____       _            ')
output.append('|  _ \(_)_ __| |_ _   _ / ___|__ _ (_)_   _ _ __ ')
output.append("| | | | | '__| __| | | | |   / _` || | | | | '_ \\")
output.append('| |_| | | |  | |_| |_| | |__| (_| || | |_| | | | |')
output.append('|____/|_|_|   \__|\__, |\____\__,_|/ |\__,_|_| |_|')
output.append('                  |___/          |__/')
output.append('__________________________________________________')

template = '{:25}{}'
output.append('\nGeneral Information\n')
output.append(template.format('Title', info['general']['other_unique_id'][0]))
output.append(template.format('Title', info['general']['movie_name']))
output.append(template.format('Format', info['general']['format']))
output.append(template.format('Format Version', info['general']['format_version']))
output.append(template.format('File Size', info['general']['other_file_size'][4]))
duration = info['general']['other_duration'][0].replace('mn', ' Minutes').replace('h', ' Hours')
output.append(template.format('Duration', duration))
output.append(template.format('Overall Bit Rate', info['general']["other_overall_bit_rate"][0]))
output.append(template.format('Encoded Date', info['general']["encoded_date"]))
output.append(template.format('Writing Application', info['general']["writing_application"][0]))

output.append('\nVideo\n')
output.append(template.format('Format', info['video']['format']))
output.append(template.format('Format Info', info['video']['format_info']))
output.append(template.format('Format Profile', info['video']['format_profile']))
output.append(template.format('Codec', info['video']['codec']))
output.append(template.format('Width', info['video']['width']))
output.append(template.format('Height', info['video']['height']))
output.append(template.format('Display Aspect Ratio', info['video']["other_display_aspect_ratio"][0]))
output.append(template.format('Frame Rate Mode', info['video']['frame_rate_mode']))
output.append(template.format('Frame Rate', info['video']['other_frame_rate'][0]))
output.append(template.format('Color Space', info['video']['color_space']))
output.append(template.format('Chroma Subsampling', info['video']['chroma_subsampling']))
output.append(template.format('Bit Depth', info['video']['other_bit_depth'][0]))
output.append(template.format('Bit Rate', info['video']['other_bit_rate'][0]))
output.append(template.format('Color Range', info['video']['color_range']))
output.append(template.format('Color Primaries', info['video']['color_primaries']))
output.append(template.format('Matrix Coefficients', info['video']["matrix_coefficients"]))

output.append('\nAudio')
for track in info['audio'].keys():
    output.append('')
    output.append(template.format('Format', info['audio'][track]['format']))
    output.append(template.format('Format Info', info['audio'][track]['format_info']))
    output.append(template.format('Codec ID', info['audio'][track]['codec_id']))
    output.append(template.format('Bit Rate Mode', info['audio'][track]['bit_rate_mode']))
    output.append(template.format('Channels', info['audio'][track]['other_channel_s'][0]))
    output.append(template.format('Channel Positions', info['audio'][track]['channel_positions']))
    output.append(template.format('Sampling Rate', info['audio'][track]['other_sampling_rate'][0]))
    output.append(template.format('Bit Depth', info['audio'][track]['other_bit_depth'][0]))
    output.append(template.format('Compression Mode', info['audio'][track]['other_compression_mode'][0]))
    output.append(template.format('Title', info['audio'][track]['title']))
    output.append(template.format('Language', info['audio'][track]['other_language'][0]))
    output.append(template.format('Default', info['audio'][track]['default']))
    output.append(template.format('Forced', info['audio'][track]['forced']))

output.append('\nText')
for track in info['text'].keys():
    output.append('')
    output.append(template.format('Format', info['text'][track]['format']))
    output.append(template.format('Codec ID', info['text'][track]['codec_id']))
    output.append(template.format('Codec Info', info['text'][track]['codec_info']))
    output.append(template.format('Language', info['text'][track]['other_language'][0]))
    output.append(template.format('Default', info['text'][track]['default']))
    output.append(template.format('Forced', info['text'][track]['forced']))

nfo_filename = argv[1].replace('mkv', 'nfo')
with open(nfo_filename, 'w') as file:
    for line in output:
        file.write('{}\n'.format(line))
file.close()
print('\nwrote nfo file to {}'.format(nfo_filename))
