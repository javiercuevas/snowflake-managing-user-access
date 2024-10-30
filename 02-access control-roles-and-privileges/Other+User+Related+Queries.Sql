// Retrieve user login statistics 
Select
    event_timestamp,
    event_id,
    event_type,
    user_name,
    client_ip,
    reported_client_type,
    reported_client_version,
    first_authentication_factor,
    second_authentication_factor,
    is_success,
    error_message
From Snowflake.Account_Usage.Login_History
Where user_name = 'RANDYMINDER';    

// Retrieve the count of failed logins month-to-date
Select 
    user_name,
    Sum(iff(is_success = 'NO', 1, 0)) As failed_logins,
    Count(*) as logins,
    Sum(iff(is_success = 'NO', 1, 0)) / nullif(Count(*), 0) as login_failure_rate
From Snowflake.Account_Usage.Login_History
Where event_timestamp > date_trunc(month, current_date)
    Group By user_name
    Order By login_failure_rate desc;

// Calculate the average number of seconds between failed login attempts by each user, 
// month-to-date
With Logins AS
(
  Select 
    user_name,
    timediff(seconds, event_timestamp, Lead(event_timestamp) Over(partition by user_name order by event_timestamp)) as seconds_between_login_attempts
  From Snowflake.Account_Usage.Login_History
  Where event_timestamp > date_trunc(month, current_date) And is_success = 'NO'
)

Select 
    user_name,
    Count(*) as failed_logins,
    Avg(seconds_between_login_attempts) as average_seconds_between_login_attempts
From Logins
    Group By user_name
    Order By average_seconds_between_login_attempts;

// Calculate the average query execution time for each user in your account
// month-to-date
Select 
    user_name,
    Avg(execution_time) as average_execution_time -- In milliseconds
From Snowflake.Account_Usage.Query_History
Where start_time >= date_trunc(month, current_date)
Group By user_name
Order By 2 Desc;

// Calculate a query count for each user session (login)
Select 
    l.user_name,
    l.event_id,
    Count(q.query_id)
From Snowflake.Account_Usage.Login_History l
    Join Snowflake.Account_Usage.Sessions s On l.event_id = s.login_event_id
    Join Snowflake.Account_Usage.Query_History q On q.session_id = s.session_id
    Group By 1, 2
    Order By l.user_name;

// Retrieve the query history for a user
 Select
    query_id,
    query_text,
    database_name,
    schema_name,
    query_type,
    session_id,
    user_name,
    role_name,
    warehouse_name,
    warehouse_size,
    query_tag,                          -- Every query in Snowflake can be tagged
    execution_status,                   -- Execution status for the query: success, fail, incident
    error_message,
    start_time,
    end_time,
    total_elapsed_time,                 -- In milliseconds
    bytes_scanned,                      -- Number of bytes scanned by this statement
    percentage_scanned_from_cache,      -- The percentage of data scanned from the local disk cache. The value ranges from 0.0 to 1.0 (100%)
    bytes_written,                      -- Number of bytes written (e.g. when loading into a table)
    rows_produced,                      -- Number of rows produced by this statement
    rows_inserted,
    rows_updated,
    rows_deleted,
    rows_unloaded,
    bytes_spilled_to_local_storage,     -- Volume of data spilled to local disk (warehouse node)
    bytes_spilled_to_remote_storage,    -- Volume of data spilled to remote disk (cloud provider storage)
    bytes_sent_over_the_network,        -- Volume of data sent over the network
    compilation_time,                   -- In milliseconds
    execution_time,                     -- In milliseconds
    queued_provisioning_time,           -- Time (milliseconds) spent in the warehouse queue, waiting for the warehouse servers to provision, due to warehouse creation, resume, or resize
    queued_repair_time,                 -- Time (milliseconds) spent in the warehouse queue, waiting for servers in the warehouse to be repaired
    queued_overload_time,               -- Time (milliseconds) spent in the warehouse queue, due to the warehouse being overloaded by the current query workload
    transaction_blocked_time,           -- Time (milliseconds) spent blocked by a concurrent DML operation
    credits_used_cloud_services,        -- Credits consumed
    release_version,                    -- Release version of Snowflake
    query_load_percent                  -- Percentage of load this query put on the associated warehouse
 From Snowflake.Account_Usage.Query_History
 Where user_name = 'RANDYMINDER';
