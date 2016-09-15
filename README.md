# isbench

A lazy way to benchmark INFORMATION_SCHEMA statements for MySQL databases.

To run the benchmark, cd to this repository directory, log in with the command line client, and run:

```SOURCE ./isbench.sql```

The benchmark will be run each statement within the ```tests``` directory 3 times, and include a dump of performance schema/sys statistics following each iteration.

Some numbers for extrapolation to make sure you have enough space...

Based on MySQL 5.7, using InnoDB with file per table, each directory takes 6.7 KB, each empty .ibd file takes 128 KB and each .frm file takes 8.7 KB.

At 1 database with 100 tables that is:

6.7 + (128 * 100) + (8.7 * 100) = 13,677 KB, or 13.67 MB

So for each of these number of databases: 

* 10 = ~136.7 MB
* 100 = ~1.37 GB
* 1,000 = ~13.7 GB
* 10,000 = ~137 GB

On an 8.0 instance, each directory takes 4 KB and each empty ibd takes 160 KB.

4 + (160 * 100) = 16,004 KB, or 16MB

* 10 = ~160MB
* 100 = ~1.6GB
* 1,000 = ~16GB
* 10,000 = ~160GB
