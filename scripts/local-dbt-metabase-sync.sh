#!/bin/bash
#
# This script is provided to make it easy to sync the dbt
# manifest with a local version of metabase running per
# the docker-compose configuration.

# Note: METABASE_DB_NAME changes based on what you name your
# database during configuration of metabase.
METABASE_DB_NAME="dbt data"

dbt-metabase models \
    --manifest-path target/manifest.json \
    --metabase-url http://localhost:3000 \
    --metabase-api-key "$METABASE_API_KEY" \
    --metabase-database "$METABASE_DB_NAME" \
    --include-schemas public
