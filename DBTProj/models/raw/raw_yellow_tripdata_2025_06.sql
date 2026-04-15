{{ config(
    materialized='view'
) }}

select *
from read_parquet('source/yellow_tripdata_2025-06.parquet')
