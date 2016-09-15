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

DROP PROCEDURE IF EXISTS drop_db_prefix;

DELIMITER $$

CREATE PROCEDURE drop_db_prefix (IN db_search_pattern VARCHAR(64))
BEGIN

    DECLARE done INT DEFAULT FALSE;
    DECLARE db_name VARCHAR(64);
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE dbs_dropped INT DEFAULT 0;
    DECLARE dbs CURSOR FOR 
     SELECT SCHEMA_NAME 
       FROM INFORMATION_SCHEMA.SCHEMATA
      WHERE SCHEMA_NAME = db_search_pattern
         OR SCHEMA_NAME LIKE CONCAT(db_search_pattern, '\_\_%');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN dbs;
    
    SET start_time = NOW(6);

    read_loop: LOOP

      FETCH dbs INTO db_name;

      IF done THEN
        LEAVE read_loop;
      END IF;

      SET @dropsql = CONCAT('DROP DATABASE `', db_name, '`');
      PREPARE drop_stmt FROM @dropsql;
      EXECUTE drop_stmt;  
      DEALLOCATE PREPARE drop_stmt;

      SET dbs_dropped = dbs_dropped + 1;

    END LOOP;

    SET end_time = NOW(6);

    CLOSE dbs;

    IF dbs_dropped THEN
      SELECT TIMEDIFF(end_time, start_time) AS total_time,
             dbs_dropped;
    END IF;

END$$

DELIMITER ;
