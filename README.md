The problem addressed by this project is to survey voter activity going back 30 years and to find patterns of changes in voter behavior in that time.

The dataset that I'm using consists of all voter activity in the state of Massachusetts for the range 1996 to 2022. The data is on a CD that was sent to me by the office of the Secretary of State. I had instructions to not share the data, so what I've done is stripped out the names and addresses of the voters.

The voter activity in question consists of which elections and which primaries each voter voted in. So one voter could appear many times in the data if they voted in more than one election in that time.

* Selecting a dataset of interest (see [Datasets](#datasets))
* Creating a pipeline for processing this dataset and putting it to a datalake
* Creating a pipeline for moving the data from the lake to a data warehouse
* Transforming the data in the data warehouse: prepare it for the dashboard
* Building a dashboard to visualize the data

The pipeline I used to move the data into the data lake had to be manual, due to the nature of the data. First of all, it was on a CD. I only have one old computer that can read a CD, and the browsers on that computer are unsupported by Google cloud. So I had to read the CD on that computer and put the data onto a USB drive. Then I could move the data from the USB drive to a Google cloud storage bucket from another computer.

Once I had that data in Google cloud storage, I unzipped the file and extracted 351 text files, which represent the 351 cities and towns in Massachusetts. I used a python notebook to read the files and do the initial transformation into parquet files in the same Google cloud storage bucket.

