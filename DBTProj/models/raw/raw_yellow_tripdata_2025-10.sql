{{ config(
    materialized='view'
) }}

select *
from read_parquet('seeds/yellow_tripdata_2025-10.parquet')
