import psycopg2, time
from dbconfig import *

ROOT_DIR = get_project_root() + '/'

class TestDao:
    # Connect to test database and create shema and tables
    def setUp():
        params = get_config()
        set_up_empty_test_db()

        con = None
        con_tries = 4
        while con == None and con_tries >= 0:
            try:
                con = psycopg2.connect(**params)
                if con != None:
                    print('[Info] Database is Connected!')
                    break
            except psycopg2.OperationalError:
                time.sleep(1.2)
                con_tries -= 1
                if con_tries < 0:
                    print('[Error] Database is not online, time limit reached!')
                else:
                    print('[Warning] Database is not online, Reattempting to connect...')

        cur = con.cursor()
        with open(ROOT_DIR + '/dbschema.sql', 'r') as sql_file:
            cur.execute(sql_file.read())
        print('[Info]', cur.fetchall())
        print('[Info] Tables created!')

        con.commit()
        con.close()
        return con


