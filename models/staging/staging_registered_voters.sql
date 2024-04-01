{{
    config(
        materialized='view'
    )
}}

WITH staging_registered_voters AS (
    SELECT
        city_code,
        city_name,
        county_name,
        voter_id,
        zip,
        party_affiliation,
        ward,
        precinct,
        congressional_district,
        senatorial_district,
        state_rep_district,
        voter_status
    FROM `data-engineering-2024-411821.voter_data.materialized_voters`
)

SELECT
    city_code,
    city_name,
    county_name,
    voter_id,
    zip,
    party_affiliation,
    ward,
    precinct,
    congressional_district,
    senatorial_district,
    state_rep_district,
    voter_status
FROM staging_registered_voters

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}