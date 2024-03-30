-- File: models/party_affiliations.sql

-- Define a seed model for party affiliations
{{ config(materialized='seed') }}

select
    'Code' as code,
    'Party or Designation Name' as party_name
from source('data', 'PartyDesignationCodes.csv')
