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

-- Tables where autoinc keys are nearing boundary.

  SELECT t.table_schema,
         t.table_name,
         ROUND(t.pct_used, 1) AS pct_used
    FROM (SELECT t.table_schema, t.table_name, 100 * (t.auto_increment /
             (CASE
               WHEN ((LOCATE('tinyint', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) = 0)) THEN 127
               WHEN ((LOCATE('tinyint', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) > 0)) THEN 255
               WHEN ((LOCATE('smallint', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) = 0)) THEN 32767
               WHEN ((LOCATE('smallint', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) > 0)) THEN 65535
               WHEN ((LOCATE('mediumint', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) = 0)) THEN 8388607
               WHEN ((LOCATE('mediumint', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) > 0)) THEN 16777215
               WHEN ((LOCATE('bigint', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) = 0)) THEN 9223372036854775807
               WHEN ((LOCATE('bigint', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) > 0)) THEN 18446744073709551615
               WHEN ((LOCATE('int', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) = 0)) THEN 2147483647
               WHEN ((LOCATE('int', c.column_type) > 0) AND (LOCATE('unsigned', c.column_type) > 0)) THEN 4294967295
               ELSE 0
             END)) AS pct_used
           FROM information_schema.tables t,
                information_schema.columns c
          WHERE t.table_schema = c.table_schema
            AND t.table_name = c.table_name
            AND t.table_schema NOT IN ('performance_schema', 'information_schema', 'mysql', 'sys')
            AND LOCATE('auto_increment', c.extra) > 0) as t
    WHERE t.pct_used > 75;

SOURCE ./dump_ps_info.sql
