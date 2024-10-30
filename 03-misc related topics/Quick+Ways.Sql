// Determine what queries are being run using the ACCOUNTADMIN role
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE role_name = 'ACCOUNTADMIN';

// Determine what users have executed queries using the ACCOUNTADMIN role
SELECT Distinct User_Name FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE role_name = 'ACCOUNTADMIN';

// Determine who has the ACCOUNTADMIN role.
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE DELETED_ON IS NULL
AND ROLE = 'ACCOUNTADMIN';

// Tracking failed logins over the past 7 days
SELECT 
    LH.user_name,
    U.disabled as account_disabled,
    U.deleted_on as account_deletion_timestamp,
    LH.error_message 
FROM SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY LH
    INNER JOIN SNOWFLAKE.ACCOUNT_USAGE.USERS U ON U.Name = LH.User_Name
WHERE error_message IS NOT NULL AND event_timestamp > DATEADD(DAY ,'-7', current_date)
ORDER BY 1;

// For each user in the Users table, determine when he/she last logged in.
Select 
    u.name as user_name,
    Max(LH.event_timestamp) as last_login
From SNOWFLAKE.ACCOUNT_USAGE.USERS U
    Left Join SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY LH
Group By u.name
Order By u.last_login;

// Find all roles with no privileges
Select r.name as role_name
From SNOWFLAKE.ACCOUNT_USAGE.ROLES r
    Left Join SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES GTR ON R.name = GTR.name
Where GTR.privilege IS NULL And r.name NOT IN ('ACCOUNTADMIN', 'USERADMIN', 'SECURITYADMIN', 'SYSADMIN', 'PUBLIC');

