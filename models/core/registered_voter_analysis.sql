{{
    config(
        materialized='table'
    )
}}

WITH voter_count AS (
    SELECT
        city_name,
        COUNT(*) AS total_voters,
        SUM(IF(trim(party_affiliation) = 'D', 1, 0)) AS democrat_count,
        SUM(IF(trim(party_affiliation) = 'R', 1, 0)) AS republican_count,
        SUM(IF(trim(party_affiliation) = 'U', 1, 0)) AS unenrolled_count,
        SUM(IF(trim(party_affiliation) = 'L', 1, 0)) AS libertarian_count
    FROM
        {{ ref ('staging_registered_voters') }}
    GROUP BY
        city_name
)

SELECT
    vc.city_name,
    vc.total_voters,
    vc.democrat_count,
    vc.republican_count,
    vc.unenrolled_count,
    vc.libertarian_count,
    ROUND((vc.democrat_count / vc.total_voters) * 100, 2) AS democrat_percentage,
    ROUND((vc.republican_count / vc.total_voters) * 100, 2) AS republican_percentage,
    ROUND((vc.unenrolled_count / vc.total_voters) * 100, 2) AS unenrolled_percentage,
    ROUND((vc.libertarian_count / vc.total_voters) * 100, 2) AS libertarian_percentage
FROM
    voter_count vc

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
