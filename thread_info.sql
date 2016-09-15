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

SET SESSION group_concat_max_len = 64 * 1024 * 1024;

SELECT GROUP_CONCAT(
           '{\n  "stage_summary": [', IFNULL(st.stage_summary_info, '\n    { }'), '\n  ]',
           ',\n  "wait_summary": {',
           '\n    "total_wait_time": "', IFNULL(sys.format_time(twt.total_wait_time), 'Unknown'), '"',
           ',\n    "wait_details": [', IFNULL(w.wait_summary_info, '\n    { }'), '\n    ]\n  }',
           ',\n  "memory_summary": {',
           '\n    "total_memory": "', IFNULL(sys.format_bytes(tm.total_memory), 'Unknown'), '"',
           ',\n    "memory_details": [', IFNULL(mem.memory_info, '\n    { }'), '\n    ]\n  }',
           '\n}'
        ) AS session_info
  FROM performance_schema.threads t
  LEFT JOIN (
   	    SELECT thread_id, SUM(current_number_of_bytes_used) total_memory
          FROM performance_schema.memory_summary_by_thread_by_event_name
         GROUP BY thread_id 
  	   ) AS tm
    ON t.thread_id = tm.thread_id
  LEFT JOIN (
        SELECT GROUP_CONCAT(
               '\n      { "type": "', SUBSTRING_INDEX(event_name, '/', -2),
               '", "count": ', current_count_used,
               ', "allocated": "', sys.format_bytes(current_number_of_bytes_used),
               '", "total_allocated": "', sys.format_bytes(sum_number_of_bytes_alloc),
               '", "high_allocated": "', sys.format_bytes(high_number_of_bytes_used),
               '" }'
               ORDER BY current_number_of_bytes_used DESC) AS memory_info,
               thread_id
          FROM performance_schema.memory_summary_by_thread_by_event_name
         WHERE sum_number_of_bytes_alloc > 0
         GROUP BY thread_id
       ) as mem
    ON t.thread_id = mem.thread_id
  LEFT JOIN (
        SELECT IFNULL(
        	     GROUP_CONCAT(
                   '\n    { "stage": "', SUBSTRING_INDEX(event_name, '/', -1),
                   '", "count": ', count_star,
                   ', "total_time": "', sys.format_time(sum_timer_wait),
                   '", "max_time": "', sys.format_time(max_timer_wait),
                   '" }'
                   ORDER BY sum_timer_wait DESC
                 ), '\n    {}') AS stage_summary_info,
               thread_id
          FROM performance_schema.events_stages_summary_by_thread_by_event_name
         WHERE count_star > 0
         GROUP BY thread_id
       ) as st
    ON t.thread_id = st.thread_id
  LEFT JOIN (
        SELECT GROUP_CONCAT(
               '\n      { "wait": "', SUBSTRING_INDEX(tw.event_name, '/', -4),
               '", "count": ', count_star,
               ', "time_total": "', sys.format_time(tw.sum_timer_wait),
               '", "time_pct": "', (tw.sum_timer_wait / tws.total_wait_time) * 100,
               '", "time_max": "', sys.format_time(tw.max_timer_wait),
               '" }'
               ORDER BY tw.sum_timer_wait DESC) AS wait_summary_info,
               tw.thread_id
          FROM performance_schema.events_waits_summary_by_thread_by_event_name tw
          JOIN (
            SELECT thread_id, SUM(SUM_TIMER_WAIT) total_wait_time
              FROM performance_schema.events_waits_summary_by_thread_by_event_name
             GROUP BY thread_id
          ) AS tws ON tw.thread_id = tws.thread_id
         WHERE tw.count_star > 0
           AND tw.event_name != 'idle'
         GROUP BY tw.thread_id
       ) as w
    ON t.thread_id = w.thread_id
  LEFT JOIN (
   	    SELECT thread_id, SUM(SUM_TIMER_WAIT) total_wait_time
          FROM performance_schema.events_waits_summary_by_thread_by_event_name
         GROUP BY thread_id 
       ) twt
   ON t.thread_id = twt.thread_id
 WHERE t.thread_id = @thd_id
 GROUP BY t.thread_id\G
