-- Create a custom role for SPCS
CREATE ROLE IF NOT EXISTS ${SPCS_ROLE_NAME};

-- Grant necessary privileges to the role
GRANT USAGE ON WAREHOUSE ${WAREHOUSE_NAME} TO ROLE ${SPCS_ROLE_NAME};
GRANT USAGE ON DATABASE ${DATABASE} TO ROLE ${SPCS_ROLE_NAME};
GRANT USAGE ON SCHEMA ${DATABASE}.${SCHEMA} TO ROLE ${SPCS_ROLE_NAME};

-- Grant specific object privileges as needed
GRANT SELECT ON ALL TABLES IN SCHEMA ${DATABASE}.${SCHEMA} TO ROLE ${SPCS_ROLE_NAME};
GRANT SELECT ON FUTURE TABLES IN SCHEMA ${DATABASE}.${SCHEMA} TO ROLE ${SPCS_ROLE_NAME};

-- If the service needs to write data
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA ${DATABASE}.${SCHEMA} TO ROLE ${SPCS_ROLE_NAME};
GRANT INSERT, UPDATE ON FUTURE TABLES IN SCHEMA ${DATABASE}.${SCHEMA} TO ROLE ${SPCS_ROLE_NAME};

-- Grant the role to a user that will own/manage the services
GRANT ROLE ${SPCS_ROLE_NAME} TO USER ${SNOWFLAKE_USER}; 