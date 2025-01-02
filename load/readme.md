DBT is not intended for loading data into the data platform.
for local development, load_csvs.sh should work fine for now.

"❌ seeds for loading source data. Do not use seeds to load data from a source system into your warehouse. If it exists in a system you have access to, you should be loading it with a proper EL tool into the raw data area of your warehouse. dbt is designed to operate on data in the warehouse, not as a data-loading tool."