python
import os

# Load environment variables
OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY')
REPLICATE_API_KEY = os.environ.get('REPLICATE_API_KEY')
FFMPEG_PATH = os.environ.get('FFMPEG_PATH')

# Define other configurations
VIDEO_INPUT_PATH = 'input.mp4'
VIDEO_OUTPUT_PATH = 'output.mp4'

# Define the API endpoints
OPENAI_API_ENDPOINT = 'https://api.openai.com/v1/completions'
REPLICATE_API_ENDPOINT = 'https://api.replicate.ai/predict'

# Define the FFmpeg commands
FFMPEG_TRIM_COMMAND = f'{FFMPEG_PATH} -i {VIDEO_INPUT_PATH} -ss {{start_time}} -t {{duration}} -c:v libx264 -crf 18 -c:a aac -b:a 128k {{output_file}}'
FFMPEG_SLOW_MOTION_COMMAND = f'{FFMPEG_PATH} -i {VIDEO_INPUT_PATH} -filter:v "setpts={{speed}}*PTS" -c:v libx264 -crf 18 -c:a aac -b:a 128k {{output_file}}'