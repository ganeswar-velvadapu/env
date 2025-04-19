import psycopg2


DATABASE_URL = "postgresql://postgres:postgres@localhost/env"

def get_db_connection():
    conn = psycopg2.connect(DATABASE_URL)
    return conn