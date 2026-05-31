import requests
import subprocess
import os
import sys
import yaml


def run_butler(exe_path, args):
    command = [exe_path] + args
    
    print("Running command:", ' '.join(command))
    
    try:
        # Use Popen to get more control over the process
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=False  # This will give us bytes instead of string
        )
        
        # Communicate with the process and get output as bytes
        stdout_bytes, stderr_bytes = process.communicate()
        
        # Try to decode the output, falling back to a more lenient method if needed
        try:
            stdout = stdout_bytes.decode('utf-8')
        except UnicodeDecodeError:
            stdout = stdout_bytes.decode('utf-8', errors='replace')
        
        try:
            stderr = stderr_bytes.decode('utf-8')
        except UnicodeDecodeError:
            stderr = stderr_bytes.decode('utf-8', errors='replace')
        
        return process.returncode, stdout, stderr
    
    except Exception as e:
        return -1, "", str(e)



def filter_games(response, game_title):
        if response.status_code == 200:
            print(game_title)
            games = response.json().get('games', [])
            for game in games:
                if game['title'].lower() == game_title.lower():
                    print("Found it")
                    return game
            return [] 
        else:
            print('Failed to fetch games:', response.json())
            return None

def fetch_game_info(api_key, game_title):
    # Usage
 
    # Create game entry
    url = f'https://itch.io/api/1/{api_key}/my-games'
    fetch_games = requests.get(url)
    filtered_game= filter_games(fetch_games, game_title)
    # Extract the last part of the path (the internal name)
    print(filtered_game['url'])
    internal_name = filtered_game['url'].strip('/').split('/')[-1]

    print(f"The internal name of the game is: {internal_name}")
    
    return {'username':filtered_game['user']['username'],'internal_name':internal_name}

def get_current_version():
    # Path to the pubspec.yaml file in the same directory as this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    pubspec_path = os.path.join(script_dir, 'pubspec.yaml')

    # Read the pubspec.yaml file
    with open(pubspec_path, 'r') as file:
        pubspec = yaml.safe_load(file)

    # Extract the version
    version = pubspec.get('version', 'No version found')

    print(f"The current version is: {version}")
    return version
def prepareIndexPage():
    # Define the path to the build/web/index.html file
    script_dir = os.path.dirname(os.path.abspath(__file__))
    index_html_path = os.path.join(script_dir, 'build', 'web', 'index.html')

    # Read the index.html file
    with open(index_html_path, 'r') as file:
        content = file.readlines()

    # Remove the <base href="/"> line
    content = [line for line in content if '<base href="/" />' not in line and '<base href="/">' not in line]

    # Write the modified content back to index.html
    with open(index_html_path, 'w') as file:
        file.writelines(content)

    print(f"Modified {index_html_path} by removing <base href='/'>")


api_key = os.environ.get('ITCH_API_KEY')
if not api_key:
    print("Missing ITCH_API_KEY environment variable.")
    sys.exit(1)

prepareIndexPage()
#get_current_version()
game_title = 'Revalia Obscura'
game_info=fetch_game_info(api_key,game_title)
developer_name = game_info['username']
internal_gamename = game_info['internal_name']
print(developer_name)
local_web_build = 'build\\web\\'



# Get the directory of the script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Construct the path to the executable
exe_path = os.path.join(script_dir, 'butler.exe')

# Arguments to pass to the executable

args = [
    'push',
    local_web_build,
    f"{developer_name}/{internal_gamename}:HTML5",
    '--userversion',
    f'{get_current_version()}',
    '--verbose'
]

if os.path.exists(exe_path):
    print("Executable found. Running it...")
    
    return_code, stdout, stderr = run_butler(exe_path, args)
    
    print("Execution completed.")
    print(f"Return Code: {return_code}")
    print(f"Standard Output:\n{stdout}")
    print(f"Standard Error:\n{stderr}")
    
    if return_code != 0:
        print(f"Butler command failed with return code {return_code}")
        sys.exit(return_code)
else:
    print(f"Executable not found at: {exe_path}")
    sys.exit(1)
