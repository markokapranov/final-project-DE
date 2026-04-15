{{ config(
    materialized='view'
) }}

select *
from read_parquet('source/yellow_tripdata_2025-10.parquet')
