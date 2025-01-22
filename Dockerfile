FROM ghcr.io/dbt-labs/dbt-postgres:1.9.latest
WORKDIR /usr/local/app

ENV PYTEST_ADDOPTS="--color=yes"
COPY requirements.txt ./
RUN pip install --requirement ./requirements.txt

# Need to get psql running locally so the load csv command works.
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    postgresql-client

COPY . .

ENTRYPOINT ["dbt"]