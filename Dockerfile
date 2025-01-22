FROM ghcr.io/dbt-labs/dbt-postgres:1.9.latest
WORKDIR /usr/local/app

COPY requirements.txt ./
RUN pip install --requirement ./requirements.txt
COPY . .

# Code file to execute when the docker container starts up (`entrypoint.sh`)
# ENTRYPOINT ["ls", "-l", "./"]

ENTRYPOINT ["./entrypoint.sh"]
