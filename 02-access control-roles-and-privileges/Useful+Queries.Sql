/*
Account_Usage views mirror the corresponding views and table functions in the Snowflake Information Schema, but with the following differences:
    Records for dropped objects included in each view
    Longer retention time for historical usage data
    Data latency
*/

// Capture the list of users in the account
Select 
    Name,
    Created_On,
    Deleted_On,
    Login_Name,
    Display_Name,
    First_Name,
    Last_Name,
    Email,
    Comment,
    Disabled,
    Must_Change_Password,   -- Specifies whether the user is forced to change their password on their next login.
    Snowflake_Lock,         -- Specifies whether a temporary lock has been placed on the user’s account.
    Default_Warehouse,      -- Specifies the virtual warehouse that is active by default for the user’s session upon login.
    Default_Namespace,      -- Specifies the namespace, database and schema, that is active by default for the user’s session upon login
    Default_Role,           -- Specifies the role that is active by default for the user’s session upon login.
    Ext_Authn_Duo,          -- If true the user is using MFA. Cannot be set directly.
    Ext_Authn_uid,          -- MFA user Id
    Last_Success_Login,     
    Expires_At,             -- Date and time the account expires
    Locked_Until_Time,      -- Specifies the number of minutes until the temporary lock on the user login is cleared
    Has_Password,           -- Specifies whether a password was created for the user
    Has_Rsa_Public_Key      -- Specifies whether RSA public key used for key pair authentication has been set up for the user
From Snowflake.Account_Usage.Users

// Generate a list of Role
Select
    Created_On,
    Deleted_On,
    Name as Role_Name,
    Comment
From Snowflake.Account_Usage.Roles;

// List all privileges granted to any role
Select 
    Created_On,
    Deleted_On,
    Modified_On,
    Privilege,              -- The type of privilege assigned to the role
    Granted_On,             -- The scope (object) of the privilege
    Name as Object_Name,    -- Object name
    Table_Catalog,          -- Database name
    Table_Schema,           -- Schema name
    Granted_To,             -- This will always be 'ROLE' in this view
    Grantee_Name,           -- The name of the role to which the privilege was granted
    Grant_Option,           -- If this is true, the role can grant the privilege to other roles
    Granted_By              -- The name of the role that granted the privilege
From Snowflake.Account_Usage.Grants_To_Roles;

// List all roles granted to any user
Select
    Created_On,
    Deleted_On,
    Role,                       -- Name of the role
    Granted_To,                 -- This will always be 'USER' in this view
    Grantee_Name as User_Name,  -- User name receiving the grant
    Granted_By                  -- Role that granted the privilege
From Snowflake.Account_Usage.Grants_To_Users;

// List all grants on the account
Show Grants on Account;

// Same as above with a bit more flexibility
Show Grants on Account;
Select *
From table(result_scan(Last_Query_Id()));

// List all grants on the target object
Show Grants on Database Demo;

// List all privileges and roles granted to the target role
Show Grants To Role LKMRole;

// List all roles granted to the target user
Show Grants To User LaurenMinder;

// List all futuer grants in the target database
Show Future Grants in Database LaurenDatabase;

// Generate a list of all roles, privileges and who is assigned to each
With All_Roles_And_Privileges AS
(
  Select 
    Created_On,                 -- When was the role + privilege created?
    Modified_On,                -- When was the role + privilege last modifed?
    Privilege,                  -- What is the privilege?
    Granted_On,                 -- What object was the role + privilege granted on?
    Table_Catalog,              -- Associated database name
    Table_Schema,               -- Associated schema name
    Granted_To,                 -- What was the role + privilege granted to
    Grantee_Name as Role_Name,  -- What role was the role + privilege granted to
    Deleted_On                  -- When was this row deleted?
  From Snowflake.Account_Usage.Grants_To_Roles
),

Roles_Assigned_To_Users AS
(
    Select
        Created_On,                 -- When was the role assigned to the user?
        Deleted_On,                 -- When was this role deleted?
        Role as Role_Name,          -- Role name
        Granted_To,                 -- What was the role assigned to?
        Grantee_Name as User_Name,  -- Name of user the role was assigned to
        Granted_By                  -- Which role granted this?
    From Snowflake.Account_Usage.Grants_To_Users
)

Select t.*, t2.User_Name
From All_Roles_And_Privileges t
    Left Join Roles_Assigned_To_Users t2 On t.Role_Name = t2.Role_Name
Where t.Deleted_On IS NULL And t2.Deleted_On IS NULL;

// What is the current user, role, database and warehouse?
Select Current_User();
Select Current_Role();
Select Current_Warehouse();
Select Current_Database();

// Creating a User
// Set the context
USE ROLE SECURITYADMIN;

// Create user with password authentication
CREATE USER SarahMinder
  PASSWORD             = 'randomly-generated-password'
  LOGIN_NAME           = 'sarahminder@gmail.com'
  DISPLAY_NAME         = 'Sarah Minder'
  FIRST_NAME           = 'Sarah'
  LAST_NAME            = 'Minder'
  EMAIL                = 'sarahminder@gmail.com'
  MUST_CHANGE_PASSWORD = TRUE
  DEFAULT_ROLE         = Marketing;
  
// Grant usage on the default role
GRANT ROLE Marketing TO USER SarahMinder;
