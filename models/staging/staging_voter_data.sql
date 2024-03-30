{{
    config(
        materialized='view'
    )
}}

WITH staging_voter_data AS (
    SELECT
        CASE
            -- If the date can be parsed successfully with the format '%m/%d/%y', convert it to '%m/%d/%Y'
            WHEN SAFE.PARSE_DATE('%m/%d/%y', election_date) IS NOT NULL THEN TIMESTAMP(FORMAT_DATE('%Y-%m-%d', SAFE.PARSE_DATE('%m/%d/%y', election_date)))
            -- If the date can be parsed successfully with the format '%m/%d/%Y', convert it to a TIMESTAMP
            WHEN SAFE.PARSE_DATE('%m/%d/%Y', election_date) IS NOT NULL THEN TIMESTAMP(FORMAT_DATE('%Y-%m-%d', SAFE.PARSE_DATE('%m/%d/%Y', election_date)))
            -- Handle any other cases (e.g., unknown format) as needed
            ELSE NULL  -- Handle as needed
        END AS formatted_datetime,
        election_type,
        voter_id,
        zip,
        city,
        party_affiliation,
        ward,
        precinct,
        voter_status,
        election_date  -- Include the original election_date column if needed
    FROM `data-engineering-2024-411821.voter_data.materialized_voter_data`
)

SELECT
    formatted_datetime,
    election_type,
    voter_id,
    zip,
    city,
    party_affiliation,
    ward,
    precinct,
    voter_status,
    election_date  -- Include the original election_date column if needed
FROM staging_voter_data

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}