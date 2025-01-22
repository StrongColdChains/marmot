FROM ghcr.io/dbt-labs/dbt-postgres:1.9.latest

COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt
COPY . /tmp/

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/tmp/entrypoint.sh"]
