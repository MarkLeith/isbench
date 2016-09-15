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

-- Schema Statistics 

SELECT s.schema_name,
       CONCAT(IFNULL(ROUND((SUM(t.data_length)+SUM(t.index_length))/1024/1024,2),0.00),'Mb') total_size,
       CONCAT(IFNULL(ROUND(((SUM(t.data_length)+SUM(t.index_length))-SUM(t.data_free))/1024/1024,2),0.00),'Mb') data_used,
       CONCAT(IFNULL(ROUND(SUM(data_free)/1024/1024,2),0.00),'Mb') data_free,
       IFNULL(ROUND((((SUM(t.data_length)+SUM(t.index_length))-SUM(t.data_free))/((SUM(t.data_length)+SUM(t.index_length)))*100),2),0) pct_used,
       COUNT(table_name) total_tables
  FROM information_schema.schemata s
  LEFT JOIN information_schema.tables t 
    ON s.schema_name = t.table_schema
 WHERE s.schema_name NOT IN ('performance_schema', 'information_schema', 'mysql', 'sys')
 GROUP BY s.schema_name
 ORDER BY pct_used DESC;

SOURCE ./dump_ps_info.sql
