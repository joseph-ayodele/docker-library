from configparser import ConfigParser
from pathlib import Path
import docker

def get_config(filename='database.ini', section='postgresql_test'):
    parser = ConfigParser()
    db = {}
    
    with open(filename, 'r') as file:
        parser.read_file(file)
        if parser.has_section(section):
            params = parser.items(section)
            for param in params:
                db[param[0]] = param[1]
        else:
            raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return db

# Set up empty test database
def set_up_empty_test_db(filename='database.ini', section='test_container'):

    config = get_config(filename, section)
    client = docker.from_env()
  
    print('[Info] Creating Mock Database Server for testing...')
    testdb = client.containers.get(config['name'])
    testdb.stop()
    testdb.remove()
    testdb = client.containers.run(
        config['image'],
        ports={config['ports'].split(':')[0]: config['ports'].split(':')[1]},
        detach=True,
        name=config['name'],
        environment=["POSTGRES_PASSWORD=%s"%config['password']],
    )
    print('[Info] Database Server is created...')

def get_project_root() -> Path:
  """Returns project root folder."""
  return str(Path(__file__).parents[1])
