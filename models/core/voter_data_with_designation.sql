-- File: models/state_elections_with_designations.sql

-- Define a model to filter state elections in early November and join them with voter designations
{{ config(materialized='view') }}

WITH state_elections AS (
    -- Filter data to include only state elections in early November
    SELECT *
    FROM {{ ref('staging_voter_data') }}
    WHERE election_type = 'STATE ELECTION'
      AND EXTRACT(MONTH FROM formatted_datetime) = 11
      AND EXTRACT(DAY FROM formatted_datetime) < 10
),
voter_designations AS (
    -- Load the voter designations data
    SELECT *
    FROM {{ ref('party_affiliation') }}
)
-- Join the filtered state elections data with the voter designations data
SELECT se.*, vd.party_name
FROM state_elections se
JOIN voter_designations vd ON trim(se.party_affiliation) = trim(vd.code)

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}