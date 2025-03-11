# tests/conftest.py
import datetime
import os
import pytest
import psycopg2
@pytest.fixture
def db_connection():
    conn = psycopg2.connect(
        dbname="dbt",
        user="user",
        password="user",
        host=os.environ.get("MARMOT_DB_HOST", "localhost"),
        port="5432"
    )
    yield conn
    conn.close()