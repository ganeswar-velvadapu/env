from dotenv import load_dotenv
import psycopg2
import os


load_dotenv()


db_url = os.getenv("DATABASE_URL")

def get_db_connection():
    conn = psycopg2.connect(db_url)
    return conn