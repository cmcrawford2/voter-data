-- File: models/party_affiliations.sql

-- Define a seed model for party affiliations
{{ config(materialized='table') }}

SELECT
    Code AS code,
    `Party or Designation Name` AS party_name
FROM {{ ref('PartyDesignationCodes') }}

