import datetime
import pytest
import psycopg2

# This needs to be productionified at some point.
# but right now its really useful for making sure logic changes
# don't break things.
#
# Run this after running load/load_csvs.sh

@pytest.fixture(scope="module")
def db_connection():
    conn = psycopg2.connect(
        dbname="dbt",
        user="user",
        password="user",
        host="localhost",
        port="5432"
    )
    yield conn
    conn.close()

def test_freeze_fridge_alarms(db_connection):

    expected_results = [
        (
            datetime.datetime(2023, 11, 22, 3, 0),
            datetime.datetime(2023, 11, 22, 4, 0),
            "a"
        ),
        (
            datetime.datetime(2023, 11, 22, 5, 30),
            None,
            "a"
        ),
        (
            datetime.datetime(2023, 11, 22, 3, 0),
            datetime.datetime(2023, 11, 22, 4, 0),
            "b"
        )
    ]
    cursor = db_connection.cursor()
    cursor.execute("SELECT begin, stop, cce_id FROM temperature_alarms WHERE alarm_cce_type = 'fridge' AND alarm_temperature_type = 'freeze' ORDER BY cce_id, begin")
    results = cursor.fetchall()

    print(results)
    for result, expected_result in zip(results, expected_results):
        assert result == expected_result, f"{result}, {expected_result}"

def test_heat_freezer_alarms(db_connection):

    expected_results = [
        (
            datetime.datetime(2023, 11, 22, 1, 30),
            None,
            "a"
        ),
        (
            datetime.datetime(2023, 11, 22, 1, 30),
            None,
            "b"
        ),
    ]
    cursor = db_connection.cursor()
    cursor.execute("SELECT begin, stop, cce_id FROM temperature_alarms WHERE alarm_cce_type = 'freezer' AND alarm_temperature_type = 'fridge' ORDER BY cce_id, begin")
    results = cursor.fetchall()

    print(results)
    for result, expected_result in zip(results, expected_results):
        assert result == expected_result, f"{result}, {expected_result}"

def test_heat_fridge_alarms(db_connection):

    expected_results = []
    cursor = db_connection.cursor()
    cursor.execute("SELECT begin, stop, cce_id FROM temperature_alarms WHERE alarm_cce_type = 'fridge' AND alarm_temperature_type = 'heat' ORDER BY cce_id, begin")
    results = cursor.fetchall()

    print(results)
    for result, expected_result in zip(results, expected_results):
        assert result == expected_result, f"{result}, {expected_result}"
