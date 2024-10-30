// #1
SELECT *
FROM Snowflake.Account_Usage.Query_History
WHERE query_type = 'ALTER_ACCOUNT'
    And execution_status = 'SUCCESS'
    
// #2
SELECT *
from Snowflake.Account_Usage.Query_History
WHERE error_message ILIKE '%insufficient privileges%';

// #6
Select 
    u.name as user_name,
    Count(QH.user_name) as query_count
From Snowflake.Account_Usage.Users U
    Inner Join Snowflake.Account_Usage.Query_History QH ON u.name = QH.user_name
Where QH.start_time >= date_trunc(month,current_timestamp())   
Group By U.name;

// #7
Select u.name as user_name, LH.First_Authentication_Factor, LH.Second_Authentication_Factor
From Snowflake.Account_Usage.Users U
    Inner Join Snowflake.Account_Usage.Login_History LH ON u.name = LH.user_name
Where 
    LH.event_timestamp >= date_trunc(month,current_timestamp()) 
    And LH.First_Authentication_Factor = 'PASSWORD'
    And LH.Second_Authentication_Factor IS NOT NULL;
    
// #10
Grant Select On Future Tables In Schema <database name>.<schema_name> To Role <role_name>;    
