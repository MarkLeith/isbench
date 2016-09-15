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

DROP PROCEDURE IF EXISTS create_dbs;

DELIMITER $$

CREATE PROCEDURE create_dbs (
    IN in_db_prefix VARCHAR(12),
    IN in_schemas INT,
    IN in_tables INT,
    IN in_columns INT,
    IN in_indexes INT,
    IN in_engine VARCHAR(10)
)
BEGIN
    DECLARE dbs_created INT DEFAULT 0;
    DECLARE tbls_created INT DEFAULT 0;
    DECLARE cols_created INT DEFAULT 0;
    DECLARE idxs_created INT DEFAULT 0;

    DECLARE cols TEXT;

    createDatabasesLoop: LOOP

        SET dbs_created = dbs_created + 1;
        SET @sql = CONCAT('CREATE DATABASE IF NOT EXISTS ', in_db_prefix, '__', dbs_created);

        -- SELECT @sql;

        PREPARE create_db FROM @sql;
        EXECUTE create_db;
        DEALLOCATE PREPARE create_db;

        SET tbls_created = 0;

        createTablesLoop: LOOP

            SET tbls_created = tbls_created + 1;

            SET @sql = CONCAT('CREATE TABLE IF NOT EXISTS ', in_db_prefix, '__', dbs_created, '.tbl_', tbls_created, ' (');

            SET cols_created = 0;
            SET cols = '';

            createColsLoop: LOOP

                SET cols_created = cols_created + 1;

                IF cols_created >= in_columns THEN
                    LEAVE createColsLoop;
                END IF;

                SET cols = CONCAT(cols, CONCAT('col_', cols_created, IF(cols_created = 1, ' INT AUTO_INCREMENT, ', ' INT, ')));

            END LOOP createColsLoop;

            SET @sql = CONCAT(@sql, cols);
            SET @sql = CONCAT(@sql, 'PRIMARY KEY (col_1)');
            SET @sql = CONCAT(@sql, ') ENGINE = ', in_engine);

            -- SELECT @sql;

            PREPARE create_tbl FROM @sql;
            EXECUTE create_tbl;
            DEALLOCATE PREPARE create_tbl;

            SET idxs_created = 0;

            createIndexesLoop: LOOP

                SET idxs_created = idxs_created + 1;

                SET @sql = CONCAT('ALTER TABLE ', in_db_prefix, '__', dbs_created, '.tbl_', tbls_created, 
                    ' ADD INDEX tbl_', tbls_created, '_idx_', idxs_created, ' (col_', idxs_created + 1, ')');

                -- SELECT @sql;

                PREPARE create_idx FROM @sql;
                EXECUTE create_idx;
                DEALLOCATE PREPARE create_idx;

                IF idxs_created >= in_indexes THEN
                    LEAVE createIndexesLoop;
                END IF;

            END LOOP createIndexesLoop;

            SET @sql = CONCAT('ANALYZE TABLE ', in_db_prefix, '__', dbs_created, '.tbl_', tbls_created);

            PREPARE analyze_tbl FROM @sql;
            EXECUTE analyze_tbl;
            DEALLOCATE PREPARE analyze_tbl;

            IF tbls_created >= in_tables THEN
                LEAVE createTablesLoop;
            END IF;

        END LOOP createTablesLoop;

        IF dbs_created >= in_schemas THEN
            LEAVE createDatabasesLoop;
        END IF;

    END LOOP createDatabasesLoop;

END$$

DELIMITER ;
