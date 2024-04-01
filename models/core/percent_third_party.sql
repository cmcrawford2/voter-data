-- Define a model for the percentage of third-party voters in each state election
{{ config(materialized='table') }}

with state_election_summary as (
    select
        formatted_datetime,
        count(*) as total_voters,
        sum(case when third_party then 1 else 0 end) as third_party_voters
    from {{ ref ('voter_data_with_third_party') }}
    group by formatted_datetime
)

select
    DATE(formatted_datetime) AS election_date,
    total_voters,
    third_party_voters,
    round((third_party_voters / total_voters) * 100, 2) as percent_third_party
from state_election_summary

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}

