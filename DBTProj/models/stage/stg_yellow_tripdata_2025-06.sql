with renamed as (

    select
        VendorID as vendor_id,
        cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
        cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,
        passenger_count,
        trip_distance,
        RatecodeID as rate_code_id,
        store_and_fwd_flag as store_and_forward_flag,
        PULocationID as pickup_location_id,
        DOLocationID as dropoff_location_id,
        payment_type, fare_amount,
        extra, mta_tax,
        tip_amount, tolls_amount,
        improvement_surcharge,
        total_amount,
        congestion_surcharge,
        airport_fee,
        cbd_congestion_fee
    from {{ ref('raw_yellow_tripdata_2025_06') }}

),
cleaned as (
    select
        *,
        datediff('minute', pickup_datetime, dropoff_datetime) as trip_duration_minutes,
        case
            when trip_distance = 0 then null
            else total_amount / trip_distance
        end as revenue_per_mile,
        {{ map_payment_type('payment_type') }} as payment_type_name,
        {{ map_vendor('vendor_id') }} as vendor_name,
        {{ map_rate_code('rate_code_id') }} as rate_code_name,
        {{ map_store_and_fwd('store_and_forward_flag') }} as store_and_forward_flag_name
    from renamed),

validated as (

    select *
    from cleaned
    where
        pickup_datetime is not null
        and dropoff_datetime is not null
        and pickup_datetime < dropoff_datetime
        and trip_duration_minutes > 0
        and vendor_id is not null
        and pickup_location_id is not null
        and dropoff_location_id is not null
        and rate_code_id is not null
        and payment_type is not null
        and passenger_count between 0 and 9
        and fare_amount >= 0
        and tip_amount >= 0
        and tolls_amount >= 0
        and total_amount > 0
        and trip_distance > 0
        and trip_distance <= 500
        and (trip_distance / nullif(trip_duration_minutes / 60.0, 0)) < 150),

deduplicated as (
    select *
    from validated
    qualify row_number() over (
        partition by
            vendor_id,
            pickup_datetime,
            dropoff_datetime,
            pickup_location_id,
            dropoff_location_id,
            passenger_count,
            fare_amount
        order by total_amount desc
    ) = 1
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key([
            'vendor_id',
            'pickup_datetime',
            'dropoff_datetime',
            'pickup_location_id',
            'dropoff_location_id',
            'passenger_count',
            'fare_amount'
        ]) }} as trip_id,
        vendor_id,
        pickup_datetime,
        dropoff_datetime,
        passenger_count,
        trip_distance,
        rate_code_id,
        store_and_forward_flag,
        pickup_location_id,
        dropoff_location_id,
        payment_type, fare_amount,
        extra, mta_tax,
        tip_amount, tolls_amount,
        improvement_surcharge,
        total_amount, congestion_surcharge,
        airport_fee, cbd_congestion_fee,
        trip_duration_minutes,
        revenue_per_mile, payment_type_name,
        vendor_name, rate_code_name,
        store_and_forward_flag_name
    from deduplicated
)

select *
from final
