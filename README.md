# isbench

A lazy way to benchmark INFORMATION_SCHEMA statements for MySQL databases.

To run the benchmark, cd to this repository directory, log in with the command line client, and run:

```SOURCE ./isbench.sql```

The benchmark will run each statement within the ```tests``` directory 3 times, and include a dump of performance schema/sys statistics following each iteration.

To create a set of databases to test with, you can use the provided ```sp_create_dbs``` stored routine. It takes the following parameters:

* in_db_prefix (VARCHAR(12)) - A prefix to add to the test schemas
* in_schemas (INT) - The total number of test schemas to create
* in_tables (INT) - The total number of tables to create within each schema
* in_columns (INT) - The number of columns that should be within each table
* in_indexes (INT) - The number of secondary indexes that should be added to each table
* in_engine (VARCHAR(10)) - The storage engine to use for the tables

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

To monitor creation of the test schemas, you can use the ```sp_monitor_table_count``` stored routine. It takes the following parameters:

* in_runtime (INT) - The total time to monitor for
* in_interval (INT) - The interval at which to print an update of progress

```
mysql> call sp_monitor_table_count(3600, 60);
+--------------+------------+-------------------+
| total_tables | new_tables | tables_per_second |
+--------------+------------+-------------------+
|        93234 |       2098 |           34.9667 |
+--------------+------------+-------------------+
1 row in set (1 min 0.82 sec)

+--------------+------------+-------------------+
| total_tables | new_tables | tables_per_second |
+--------------+------------+-------------------+
|        95188 |       1954 |           32.5667 |
+--------------+------------+-------------------+
1 row in set (2 min 1.29 sec)

+--------------+------------+-------------------+
| total_tables | new_tables | tables_per_second |
+--------------+------------+-------------------+
|        97110 |       1922 |           32.0333 |
+--------------+------------+-------------------+
1 row in set (3 min 1.76 sec)

+--------------+------------+-------------------+
| total_tables | new_tables | tables_per_second |
+--------------+------------+-------------------+
|        99215 |       2105 |           35.0833 |
+--------------+------------+-------------------+
1 row in set (4 min 2.17 sec)
```
