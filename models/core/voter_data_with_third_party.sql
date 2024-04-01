-- File: models/voter_data_with_third_party.sql

-- Define a model for third-party voters
{{ config(materialized='table') }}

with third_party_voters as (
    select
        *,
        case 
            when trim(party_affiliation) not in ('D', 'R', 'U') then true
            else false
        end as is_third_party
    from {{ ref('voter_data_with_designation') }}
)

select
    *,
    is_third_party as third_party
from third_party_voters



-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}