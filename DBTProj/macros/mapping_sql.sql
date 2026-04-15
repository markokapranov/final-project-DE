{% macro map_payment_type(payment_type_col) %}
    case
        when {{ payment_type_col }} = 0 then 'flex fare'
        when {{ payment_type_col }} = 1 then 'credit card'
        when {{ payment_type_col }} = 2 then 'cash'
        when {{ payment_type_col }} = 3 then 'no charge'
        when {{ payment_type_col }} = 4 then 'dispute'
        when {{ payment_type_col }} = 5 then 'unknown'
        when {{ payment_type_col }} = 6 then 'voided trip'
        else 'other'
    end
{% endmacro %}


{% macro map_vendor(vendor_col) %}
    case
        when {{ vendor_col }} = 1 then 'Creative Mobile Technologies'
        when {{ vendor_col }} = 2 then 'Curb Mobility'
        when {{ vendor_col }} = 6 then 'Myle Technologies'
        when {{ vendor_col }} = 7 then 'Helix'
        else 'unknown'
    end
{% endmacro %}


{% macro map_rate_code(rate_code_col) %}
    case
        when {{ rate_code_col }} = 1 then 'standard rate'
        when {{ rate_code_col }} = 2 then 'JFK'
        when {{ rate_code_col }} = 3 then 'Newark'
        when {{ rate_code_col }} = 4 then 'Nassau/Westchester'
        when {{ rate_code_col }} = 5 then 'negotiated fare'
        when {{ rate_code_col }} = 6 then 'group ride'
        when {{ rate_code_col }} = 99 then 'unknown'
        else 'other'
    end
{% endmacro %}


{% macro map_store_and_fwd(flag_col) %}
    case
        when {{ flag_col }} = 'Y' then 'stored and forwarded'
        when {{ flag_col }} = 'N' then 'not stored'
        else 'unknown'
    end
{% endmacro %}
