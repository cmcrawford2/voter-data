The problem addressed by this project is to survey all voter activity in Massachusetts going back 30 years, and to find trends among parties other than Democrat or Republican. The data consists of two main files: first, the list of all registered voters on the date the file was made - about 4 million; then, the list of voter activity. This includes all the elections that any registered voter voted in, going back 30 years. This file is much bigger, over 10G with about 40 million records.

This dataset is proprietary. For this project, I removed the names and addresses of the voters before I made any tables.

The datasets that I'm using consist of all voter activity in the state of Massachusetts for the range 1996 to 2022, plus the list of registered voters as of August, 2022. The data is on a CD that was sent to me by the office of the Secretary of State.

The voter activity in question consists of which elections--municipal and state, primaries and general elections--each voter voted in. So one voter could appear many times in the data if they voted in more than one election in the last 30 years.

The pipeline starts with extracting the data from the CD. I have a laptop that can read a CD, but it has an old operating system. The browsers are not compatible with Google cloud. So the first step was to read the data from the CD onto a USB drive. Then I used another computer to put the zip files into a GCP bucket.



The next step was to unzip the files and write parquet files into the GCP bucket. I used two jupyter notebooks to do this, one for each file. They are voter-data.ipynb for the large file and voters.ipynb for the smaller file.

To move the data from the data lake to the data warehouse, I used a combination of queries in BigQuery to create the raw data files, and DBT. In DBT, I created two staging files which were copies of the raw data with a date transformation on the voter activity file. Some of the dates were in mm/dd/yy format and others were in mm/dd/yyyy format. I converted them all to a timestamp.

Then to prepare the data for the dashboard, I used dbt to create tables from the two staging files. The first file joined a table where the party affiliations were spelled out with the main file, where they were just encoded with one or two letters. Then once that was done, I created other tables that were convenient for presenting the data that I wanted to present in Google Looker studio.

Finally, I created two files in Google Looker Studio. You can see these here:






