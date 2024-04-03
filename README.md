# Massachusetts voter data project

### Problem description

The problem addressed by this project is to survey all voter activity in Massachusetts going back 30 years, and to find trends among parties other than Democrat or Republican. It's hard to find data about third party voter registration. In the USA, the two major parties, Democrat and Republican, win most of the elections. There is not much interest in reporting on third parties.

The data that I'm using consists of two files. First, I have a list of all registered voters on the date the file was made, August 2022. There are about 4 million registered voters in Massachusetts, and there is one row per voter. The second file consists of all voter activity in the state of Massachusetts for the range 1996 to 2022. This file is much larger. The size is about 11 gigabytes with over 80 million records. It has all the elections that every voter participated in. So if a voter voted in every election from 1996 to 2022, including local municipal elections and primaries, they would appear multiple times in the data.

The data is on a CD that was sent to me by the office of the Secretary of State. This data is proprietary. For this project, I removed the names and addresses of the voters before I made any tables.

### Cloud

Once I uploaded the data from the CD to a Google cloud storage bucket, I ran everything on the cloud from a virtual machine instance and the DBT cloud IDE. I automated the pipelines that were used to transform the data and prepare it for visualization. I could not automate the process of extracting data from the CD, because I used a CD reader on an older computer. But once I had the data on Google cloud storage, I was able to automate almost everything.

### Data Ingestion: Pipeline from raw data to Google cloud bucket

The pipeline starts with extracting the data from the CD. I have a laptop that can read a CD, but it has an old operating system. The browsers are not compatible with Google cloud. So the first step was to read the data from the CD onto a USB drive. Then I used another computer to put the zip files into a GCP bucket.

![CD to cloud pipeline image](https://github.com/cmcrawford2/voter-data/blob/main/assets/CD_to_cloud.png)

The next step was to unzip the files and write parquet files into the GCP bucket. I used two jupyter notebooks to do this, one for each file. They are commented, and you can read them here: [voter-data.ipynb](https://github.com/cmcrawford2/voter-data/blob/main/voter-data.ipynb) for the large file and [voters.ipynb](https://github.com/cmcrawford2/voter-data/blob/main/voters.ipynb) for the smaller file.

### Data warehouse

I used BigQuery as my data warehouse. To move the data from the data lake to the data warehouse, I used SQL queries in BigQuery to create the raw data files. Because I was querying the voter registration data by city, I partitioned that table by city. There are 351 cities and towns in Massachusetts. I partitioned the table into 27 buckets of 39 towns each in order to optimize the search.

```sql
CREATE OR REPLACE EXTERNAL TABLE `voter_data.external_voter_data`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://cris-voter-data/output/*.parquet']
);

select count(*) from `voter_data.external_voter_data`;

SELECT DISTINCT election_type FROM `voter_data.external_voter_data`;

CREATE OR REPLACE TABLE `voter_data.materialized_voter_data` AS
SELECT *
FROM `voter_data.external_voter_data`;

select count(*) from voter_data.materialized_voter_data;

CREATE OR REPLACE EXTERNAL TABLE `voter_data.external_voters`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://cris-voter-data/voter_output/*.parquet']
);

select count(*) from voter_data.external_voters;

CREATE OR REPLACE TABLE voter_data.materialized_voters
PARTITION BY RANGE_BUCKET(city_code, GENERATE_ARRAY(1,351,27))
AS
SELECT *
FROM voter_data.external_voters;

select count(*) from `voter_data.materialized_voters`;
```

### Transformations: Preparing the data for the dashboard

To prepare the data for the dashboard, I used dbt. I created tables from the two staging files. The first table only needed to be a count of the registered voters of each party in the 351 towns of Massachusetts. For the second table, I joined a table where the party affiliations were spelled out with the main file, where the party affiliations were just encoded with one or two letters. Then once that was done, I created other tables that were convenient for presenting the data that I wanted to present in Google Looker studio.

Finally, I created a schema for documentation and testing. There were a few null records in the large file, but the smaller file passed all the tests.

The models are in models/staging and models/core at the top level of this repository.

- [models/staging/staging_voters.sql](https://github.com/cmcrawford2/voter-data/blob/main/models/staging/staging_voters.sql)
- [models/staging/staging_voter_data.sql](https://github.com/cmcrawford2/voter-data/blob/main/models/staging/staging_voter_data.sql)
- [models/staging/schema.yml](https://github.com/cmcrawford2/voter-data/blob/main/models/staging/schema.yml)

Model for voter registration analysis:

- [models/core/registered_voter_analysis](https://github.com/cmcrawford2/voter-data/blob/main/models/core/registered_voter_analysis.sql)

Models for voter activity analysis:

- [models/core/voter_data_with_designation.sql](https://github.com/cmcrawford2/voter-data/blob/main/models/core/voter_data_with_designation.sql)
- [models/core/party_affiliation.sql](https://github.com/cmcrawford2/voter-data/blob/main/models/core/party_affiliation.sql)
- [models/core/voter_data_with_third_party.sql](https://github.com/cmcrawford2/voter-data/blob/main/models/core/voter_data_with_third_party.sql)
- [models/core/percent_third_party.sql](https://github.com/cmcrawford2/voter-data/blob/main/models/core/percent_third_party.sql)

Seed file for PartyDesignationCodes:

- [seeds/PartyDesignationCodes.csv](https://github.com/cmcrawford2/voter-data/blob/main/seeds/PartyDesignationCodes.csv)
![Lineage of voter registration data](https://github.com/cmcrawford2/voter-data/blob/main/assets/voter_lineage.png)
![Lineage of voter election data](https://github.com/cmcrawford2/voter-data/blob/main/assets/dbt_lineage.png)

### Dashboard: Visualization of the data

I created two files in Google Looker Studio. The first represents a static picture of libertarian voter registration on a particular date (August 29, 2022). The second shows that the percentage of voters who identify with a third party had grown over time, from approximatly 0.5% in 2000 to 1.0% in 2020.

You can see these here - the copies are fully editable so you can also examine the data that I didn't use in the charts. They are: 

- [Cities and towns in Massachusetts with the highest and lowest percentage of voters registered as libertarian as of August 2022](https://lookerstudio.google.com/u/0/reporting/5a51805c-6f4b-4790-8cc7-812f6f8466d5/page/oE4uD/edit) and 
- [Third party voters voting in Massachusetts state elections for President and Governor](https://lookerstudio.google.com/u/0/reporting/9d9c2220-430f-429c-b120-46a187b22ab0/page/2RzuD/edit)

For the third party voters in Massachusetts, I created a quick filter that excludes 'D', 'R', and 'U'. **You may have to put this filter back, as it sometimes doesn't persist in looker studio.** To do this, go to "quick filter" in the filter bar above the charts (make sure you have it enabled in edit mode by choosing the "filter bar" button on the right-hand side). Select party_affiliation, and remove 'D', 'R', and 'U'. Then apply the filter.

Here are pictures of the charts:
![Bar charts of registered libertarians](https://github.com/cmcrawford2/voter-data/blob/main/assets/registered_libertarians.png)
![Bar chart of third party voters](https://github.com/cmcrawford2/voter-data/blob/main/assets/third_party_voters.png)

### Reproducibility

My cloud environment is private, as is my dbt IDE. I have the free version of the dbt IDE, which prohibits me from adding team members. However, by inspecting the files, you can see every step of the process. I should be able to reproduce the entire run with a new CD from the Secretary of State's office, which I've applied for. You can look at the data in Google looker studio. I've allowed public editing access. Just don't delete any of the tables!
