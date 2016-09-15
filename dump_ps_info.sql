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

UPDATE performance_schema.threads SET instrumented = 'NO' WHERE thread_id = @thd_id;

-- Ignore the UPDATEs and truncates to P_S from in here
SELECT * 
  FROM sys.statement_analysis 
 WHERE query NOT LIKE 'UPDATE%' 
   AND query NOT LIKE 'CALL `sys`%'\G

SOURCE ./thread_info.sql

UPDATE performance_schema.threads SET instrumented = 'YES' WHERE thread_id = @thd_id;

CALL sys.ps_truncate_all_tables(false);
