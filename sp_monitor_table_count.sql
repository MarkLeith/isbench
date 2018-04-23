-- Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.
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

DROP PROCEDURE IF EXISTS sp_monitor_table_count;

DELIMITER $$

CREATE PROCEDURE sp_monitor_table_count (
    IN in_runtime INT,
    IN in_interval INT
)
BEGIN
    DECLARE remaining_runtime INT DEFAULT 0;
    DECLARE total_tables INT DEFAULT 0;
    DECLARE previous_total INT DEFAULT 0;

SET remaining_runtime = in_runtime;

WHILE remaining_runtime > 0 DO

	SET previous_total = total_tables;

	SELECT COUNT(*) INTO total_tables FROM INFORMATION_SCHEMA.TABLES;

	# Skip first interval
	IF remaining_runtime != in_runtime THEN
		SELECT total_tables, (total_tables - previous_total) AS new_tables, (total_tables - previous_total)/in_interval AS tables_per_second;
	END IF;

	SET remaining_runtime = remaining_runtime - in_interval;
	SELECT SLEEP(in_interval) INTO @dummy;

END WHILE;

END$$

DELIMITER ;
