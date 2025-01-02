#!/bin/bash
#
# Note: this was created with ChatGPT using the following prompt:
# I have 4 csvs in a folder and I'd like to copy them into a postgres table. Each table should be named after the filename (raw_temperature.csv should be put into a table called raw_temperature).

# I have postgres running on a localhost and can connect to it running the following psql command:

# psql -h localhost -U user -d dbt

# It does require a password prompt.

# Could you please write me a bash script that dumps my csv data into postgres? thanks.
#
#
# This thing is quite brittle. Should go through and make sure that if something
# has gone wrong it actually exits and gives some clue as to *why* it has
# failed.

if ! command -v psql 2>&1 >/dev/null
then
    echo "psql could not be found, it is needed to load postgres with the required data."
    exit 1
fi

# Database connection details
DB_HOST="localhost"
DB_USER="user"
DB_NAME="dbt"
export PGPASSWORD="user"

FOLDER=$(dirname "$0")
CSV_FOLDER="$FOLDER/csvs"


# Connect to PostgreSQL and create tables
for FILE in $(find $CSV_FOLDER); do
    echo "$FILE"
    if [[ -f "$FILE" ]]; then
        # Get the base name of the file (e.g., raw_temperature.csv -> raw_temperature)
        TABLE_NAME=$(basename "$FILE" .csv)
        echo "$TABLE_NAME"

        echo "Loading data from $FILE into table $TABLE_NAME..."

        # Use psql to drop the table if it exists
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
        DROP TABLE IF EXISTS $TABLE_NAME CASCADE;"
        # Use psql to create the table and load data
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
        CREATE TABLE IF NOT EXISTS $TABLE_NAME (
            -- Adjust column definitions if necessary
            $(head -n 1 "$FILE" | awk -F',' '{for(i=1;i<=NF;i++) printf "\""$i"\" text%s", (i<NF?", ":"")}')
        );"

        # Use psql's \copy command to load data
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\copy $TABLE_NAME FROM '$FILE' WITH CSV HEADER"
    fi
done

echo "All CSV files have been loaded into PostgreSQL."
