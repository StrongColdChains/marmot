FROM ghcr.io/dbt-labs/dbt-postgres:1.9.latest
WORKDIR /usr/local/app

# Ensure that pytest output sends colors through pipes.
ENV PYTEST_ADDOPTS="--color=yes"
# Used to distinguish between running dbt locally and
# in docker.
ENV MARMOT_DB_HOST="postgres"
COPY requirements.txt ./
RUN pip install --requirement ./requirements.txt

# Need to get psql running locally so the load csv command works.
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    postgresql-client

COPY . .

ENTRYPOINT ["dbt"]