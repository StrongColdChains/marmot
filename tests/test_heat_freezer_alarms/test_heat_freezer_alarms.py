# from tests.fixtures.db_utils import db_connection
import datetime
import os
import pytest
import psycopg2
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