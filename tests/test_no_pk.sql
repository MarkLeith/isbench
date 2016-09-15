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

-- Tables without PRIMARY or UNIQUE keys.

  SELECT t.table_schema,
  	     t.table_name
    FROM information_schema.tables t
    LEFT JOIN information_schema.table_constraints c
      ON (t.table_schema = c.table_schema
     AND t.table_name = c.table_name
     AND c.constraint_type IN ('PRIMARY KEY','UNIQUE'))
   WHERE t.table_schema NOT IN ('information_schema', 'performance_schema')
     AND t.engine NOT IN ('ARCHIVE','FEDERATED')
     AND c.table_name IS NULL;

SOURCE ./dump_ps_info.sql
