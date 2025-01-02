a data system to build the future of global cold chain actioning.

very much a wip

## Development

While I'd like to get everything into docker soon, I currently run dbt and pytest
on my local machine. Use your favorite virtual env manager to handle the dependencies.
Use requirements.txt to get your env up to date.

You'll need to have psql downloaded locally to run some of the scripts.

To set up your postgres tables initially, use the scripts and data provided in
the `load` folder. DBT is not intended to be a loading tool and expects data to
exist in the configured sources prior to being run.

When I change stuff I like to use make test to ensure that nothing is broken.
