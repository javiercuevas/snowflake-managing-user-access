// Create a role named Marketing
Create Role "Marketing";

// Grant this new role to SYSADMIN so that SYSADMIN can manage it.
Grant Role "Marketing" to Role "SYSADMIN";

// Now grant to role to a user
Grant Role "Marketing" to User LaurenMinder;

// Users need to have access to a warehouse, which will give them computing power
// to perform queries in Snowflake.
Grant Operate on Warehouse Compute_XSmall to role "Marketing";

// Grant Select on all tables in a target database and schema and assign to the
// marketing role.
Grant Select on All Tables in Schema <database name>.<schema_name> to role Marketing;

// Grant Select on all future tables.
Grant Select on Future Tables in Schema <database name>.<schema_name> to role Marketing;