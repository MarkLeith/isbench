-- Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

DROP DATABASE IF EXISTS isbench;

CREATE DATABASE isbench;

USE isbench;

SOURCE ./sp_create_dbs.sql
SOURCE ./sp_drop_db_prefix.sql

CALL sys.ps_setup_enable_consumer('');
CALL sys.ps_setup_enable_instrument('');

UPDATE performance_schema.threads SET instrumented = 'NO';

SET @conn_id := CONNECTION_ID();
SET @thd_id = sys.ps_thread_id(@conn_id);

CALL sys.ps_setup_enable_thread(@conn_id);

CALL sys.ps_truncate_all_tables(false);

--

TEE ./output/InnoDB_50_output.txt

SELECT NOW() AS 'InnoDB, 1 database, 50 tables, 500 columns, 150 indexes (with PK)';
CALL isbench.create_dbs('InnoDB_50', 1, 50, 10, 2, 'InnoDB');

SOURCE ./dump_ps_info.sql

SOURCE ./test_statements.sql

SELECT NOW() AS 'Dropping...';
CALL isbench.drop_db_prefix('InnoDB_50');

SOURCE ./dump_ps_info.sql

NOTEE

--

TEE ./output/InnoDB_500_output.txt

SELECT NOW() AS 'InnoDB, 10 databases, 500 tables, 5,000 columns, 1,500 indexes (with PK)';
CALL isbench.create_dbs('InnoDB_500', 10, 50, 10, 2, 'InnoDB');

SOURCE ./dump_ps_info.sql

SOURCE ./test_statements.sql

SELECT NOW() AS 'Dropping...';
CALL isbench.drop_db_prefix('InnoDB_500');

SOURCE ./dump_ps_info.sql

NOTEE

--

TEE ./output/InnoDB_5k_output.txt

SELECT NOW() AS 'InnoDB, 100 databases, 5,000 tables, 50,000 columns, 15,000 indexes (with PK)';
CALL isbench.create_dbs('InnoDB_5k', 100, 50, 10, 2, 'InnoDB');

SOURCE ./dump_ps_info.sql

SOURCE ./test_statements.sql

SELECT NOW() AS 'Dropping...';
CALL isbench.drop_db_prefix('InnoDB_5k');

SOURCE ./dump_ps_info.sql

NOTEE

--

TEE ./output/InnoDB_100k_output.txt

SELECT NOW() AS 'InnoDB, 1000 databases, 100,000 tables, 1,000,000 columns, 300,000 indexes (with PK)';
CALL isbench.create_dbs('InnoDB_100k', 1000, 100, 10, 2, 'InnoDB');

SOURCE ./dump_ps_info.sql

SOURCE ./test_statements.sql

SELECT NOW() AS 'Dropping...';
CALL isbench.drop_db_prefix('InnoDB_100k');

SOURCE ./dump_ps_info.sql

NOTEE

--

TEE ./output/InnoDB_1m_output.txt

SELECT NOW() AS 'InnoDB, 10,000 databases, 1,000,000 tables, 10,000,000 columns, 3,000,000 indexes (with PK)';
CALL isbench.create_dbs('InnoDB_1m', 10000, 100, 10, 2, 'InnoDB');

SOURCE ./dump_ps_info.sql

SOURCE ./test_statements.sql

SELECT NOW() AS 'Dropping...';
CALL isbench.drop_db_prefix('InnoDB_1m');

SOURCE ./dump_ps_info.sql

NOTEE

--

TEE ./output/MyISAM_20_output.txt

SELECT NOW() AS 'Creating MyISAM, 10 databases, 200 tables, 8,000 columns, 2,200 indexes (with PK)';
CALL isbench.create_dbs('MyISAM_20', 10, 20, 40, 10, 'MyISAM');

SOURCE ./dump_ps_info.sql

SOURCE ./test_statements.sql

SELECT NOW() AS 'Dropping...';
CALL isbench.drop_db_prefix('MyISAM_20');

SOURCE ./dump_ps_info.sql

NOTEE

--

