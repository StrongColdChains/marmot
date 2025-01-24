a data system to build the future of global cold chain actioning.

very much a wip

## Development

use `docker compose up` to get the various containers up and running.
it will spin up postgres, dbt, and metabase.

dbt is where all of the logic is implemented that takes time series data
and transforms it into metrics and KPIs. metabase is a great BI analytics
tool that can be used to explore the data produced by dbt.  postgres is
the datastore that backs the other two services.

To directly run make commands you'll need to either run them from inside
the dbt container (`docker exec dbt make test`) or you'll need to get the
dependencies set up on your local environment. Doing it from within docker
will be easier to maintain : )

To set up your postgres tables initially, use the scripts and data provided in
the `load` folder. DBT is not intended to be a loading tool and expects data to
exist in the configured sources prior to being run. The make commands will do
this for you.
