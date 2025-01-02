.PHONY: fix test

fix:
	sqlfluff fix

test:
	./load/load_csvs.sh
	dbt build
	pytest tests

dbt_test_build:
	# https://docs.getdbt.com/blog/dbt-production-commands#1-always-test-your-data
	# Testing source data before running any dbt transformation
	dbt test -s source:*

	dbt run

	dbt test --exclude source:*

	# Testing source freshness
	dbt source freshness
