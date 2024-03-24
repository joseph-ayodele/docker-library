#!/bin/bash

# Path to the flag file
FLAG_FILE="$ORACLE_HOME/dbs/.setup_complete"

# Function to create ORCL service
function create_orcl_service {
	echo "Creating and starting ORCL service..."
	if ! sqlplus / as sysdba <<-EOF
		ALTER SESSION SET CONTAINER = FREEPDB1;
		BEGIN
			DBMS_SERVICE.CREATE_SERVICE(
				service_name => 'ORCL',
				network_name => 'ORCL'
			);
			DBMS_SERVICE.START_SERVICE('ORCL');
		END;
		/
		ALTER SYSTEM REGISTER;
	EOF
	then
		echo "Error creating ORCL service. Please check the Oracle logs."
		exit 1
	fi
	lsnrctl reload
}

# Function to start the ORCL service
function start_orcl {
	echo "Starting ORCL service..."
	if ! sqlplus / as sysdba <<-EOF
		ALTER SESSION SET CONTAINER = FREEPDB1;
		BEGIN
			DBMS_SERVICE.START_SERVICE('ORCL');
		END;
		/
		ALTER SYSTEM REGISTER;
	EOF
	then
		echo "Error starting ORCL service. Please check the Oracle logs."
		exit 1
	fi
	lsnrctl reload
}

function run_sql_file {
	local sql_file="$1"
	echo "Running SQL commands from ${sql_file}..."
	if ! sqlplus / as sysdba @"${sql_file}"
	then
		echo "Error executing SQL commands from ${sql_file}. Please check the Oracle logs."
		exit 1
	fi
}

# Main script execution starts here
if [ ! -f "$FLAG_FILE" ]; then
	echo "Initial setup: Configuring ORCL PDB and creating users..."

	create_orcl_service
#	run_sql_file "/opt/oracle/scripts/startup/ren_users.sql-setup"

	# Create the flag file to indicate the script has run
	touch "$FLAG_FILE"
	echo "Setup complete! This script will not run setup again."
else
	echo "Setup previously completed, ensuring ORCL service is started..."
	start_orcl
fi
