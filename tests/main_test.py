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
            datetime.datetime(2023, 11, 22, 2, 0),
            datetime.datetime(2023, 11, 22, 4, 0),
            "a"
        ),
        (
            datetime.datetime(2023, 11, 22, 4, 30),
            None,
            "a"
        ),
        (
            datetime.datetime(2023, 11, 22, 2, 0),
            datetime.datetime(2023, 11, 22, 4, 0),
            "b"
        )
    ]
    cursor = db_connection.cursor()
    cursor.execute("SELECT begin, stop, cce_id FROM freeze_fridge_alarms ORDER BY cce_id, begin")
    results = cursor.fetchall()

    print(results)
    for result, expected_result in zip(results, expected_results):
        assert result == expected_result, f"{result}, {expected_result}"

def test_heat_freezer_alarms(db_connection):

    expected_results = [
        (
            datetime.datetime(2023, 11, 22, 0, 0),
            None,
            "a"
        ),
        (
            datetime.datetime(2023, 11, 22, 0, 0),
            None,
            "b"
        ),
    ]
    cursor = db_connection.cursor()
    cursor.execute("SELECT begin, stop, cce_id FROM heat_freezer_alarms ORDER BY cce_id, begin")
    results = cursor.fetchall()

    print(results)
    for result, expected_result in zip(results, expected_results):
        assert result == expected_result, f"{result}, {expected_result}"

def test_heat_fridge_alarms(db_connection):

    expected_results = []
    cursor = db_connection.cursor()
    cursor.execute("SELECT begin, stop, cce_id FROM heat_fridge_alarms ORDER BY cce_id, begin")
    results = cursor.fetchall()

    for result, expected_result in zip(results, expected_results):
        assert result == expected_result, f"{result}, {expected_result}"

def test_non_temperature_alarms(db_connection):
    for expected_results, table_name in (
    ([
        (
            datetime.datetime(2023, 11, 20, 10, 0, 0),
            datetime.datetime(2023, 11, 21, 10, 0, 1),
            "a"
        ),
        (
            datetime.datetime(2023, 11, 22, 0, 0),
            None,
            "a"
        ),
    ], "power_alarms"),
    ([
        (
            datetime.datetime(2023, 11, 21, 0, 10),
            datetime.datetime(2023, 11, 21, 0, 40),
            "a"
        ),
        (
            datetime.datetime(2023, 11, 21, 1, 0),
            datetime.datetime(2023, 11, 21, 1, 31),
            "a"
        )
    ], "emd_connection_alarms"),
    ([
        (
            datetime.datetime(2023, 11, 21, 0, 4),
            datetime.datetime(2023, 11, 21, 0, 9),
            "a"
        ),
        (
            datetime.datetime(2023, 11, 21, 0, 10),
            datetime.datetime(2023, 11, 21, 0, 16),
            "a"
        ),
        # Verify time series data that isn't even in spacing still results
        # in alarms.
        (
            datetime.datetime(2023, 11, 21, 0, 2),
            None,
            "b"
        ),
        # Alarm should start between time series points if that's where the
        # threshold duration would end.
        (
            # TODO: This should actually be 7, right now its 9 because an alarm
            # can only start on a time where a tsf is recorded.
            datetime.datetime(2023, 11, 21, 0, 2),
            None,
            "c"
        ),
        # There is no alarm here, but CCE 'e' should have 0 alarms since
        # changing monitors shouldn't affect alarm computation.
    ], "door_alarms")
    ):
        cursor = db_connection.cursor()
        cursor.execute(f"SELECT begin, stop, cce_id FROM {table_name} ORDER BY cce_id, begin")
        results = cursor.fetchall()

        for result, expected_result in zip(results, expected_results):
            assert result == expected_result, f"{table_name}, {results}, {expected_results}"

        # strict=True does the len check, but it makes it more difficult to show
        # debugging info
        assert len(results) == len(expected_results), f"{table_name}, {results}, {expected_results}"

def test_connectivity_kpis(db_connection):
    # TODO: add these.
    pass
