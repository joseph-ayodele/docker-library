#!/bin/bash
# This script starts the oracle database or creates a database if one doesn't exist

# Start database
function start_database() {
  lsnrctl start
  sqlplus / as sysdba <<EOF
startup;
exit;
EOF
}

# Create network directory
NETWORK_DIR="${ORACLE_HOME}/network/admin"
mkdir -p "${NETWORK_DIR}"

# Configure the database network
function setup_network_config() {
  # sqlnet.ora: defines client network configurations
  cat >"${NETWORK_DIR}/sqlnet.ora" <<EOL
NAMES.DIRECTORY_PATH=(TNSNAMES, EZCONNECT, HOSTNAME)
DISABLE_OOB=ON
EOL

  # listener.ora: manages incoming client connection requests and traffic to the database
  cat >"${NETWORK_DIR}/listener.ora" <<EOL
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = ${ORACLE_HOSTNAME})(PORT = 1521))
    )
  )

DEDICATED_THROUGH_BROKER_LISTENER=ON
DIAG_ADR_ENABLED = off
EOL
}

# Set up tns names
function setup_tns() {
  # tnsnames.ora: host:port/service_name for ezconnect
  cat >"${NETWORK_DIR}/tnsnames.ora" <<EOL
${ORACLE_SID}=localhost:1521/${ORACLE_SID}
EOL
}

# Checks if the database was created successfully
function check_db_created() {
  DB=$(sqlplus -s / as sysdba <<EOF
set heading off;
set pagesize 0;
SELECT name FROM v\$database WHERE name = '${ORACLE_SID}';
exit;
EOF
)
  ret=$?
  if [ $ret -eq 0 ] && [ "${DB}" = "${ORACLE_SID}" ]; then
    echo 0
  else
    echo 1
  fi
}

# Create and setup database 
function create_database() {
  lsnrctl start

  dbca -silent -createDatabase \
    -templateName General_Purpose.dbc \
    -gdbname ${ORACLE_SID} -sid ${ORACLE_SID} -responseFile NO_VALUE \
    -characterSet AL32UTF8 \
    -sysPassword ${DB_PWD} \
    -systemPassword ${DB_PWD} \
    -createAsContainerDatabase false \
    -databaseType MULTIPURPOSE \
    -memoryMgmtType auto_sga \
    -totalMemory 2048 \
    -storageType FS \
    -datafileDestination ${DATA_DIR} \
    -redoLogFileSize 50 \
    -emConfiguration NONE \
    -ignorePreReqs

  sqlplus -s / as sysdba <<EOF
ALTER SYSTEM SET db_create_file_dest='${DATA_DIR}';
ALTER SYSTEM SET local_listener='';
EXEC DBMS_XDB_CONFIG.SETGLOBALPORTENABLED (TRUE);
exit;
EOF
  
  db_created=$(check_db_created)
  if [ "${db_created}" -eq 0 ]; then
    date -Iseconds > "${DATA_DIR}/.${ORACLE_SID}.created"
    echo "Database Created Successfully!"
  else 
    echo "Error! Something went wrong trying to create database!"
    exit 1
  fi
}

# Runs all .sql scripts in USER_SCRIPTS directory
function run_user_scripts() {
  for script in "${USER_SCRIPTS}"/*.sql; do
      echo "$0: executing ${script}";
      echo "exit" | sqlplus -s / as sysdba @"${script}";
      echo "";
  done
}

# Main
# Start db if it exists or create one if it doesn't
if [ -d "${DATA_DIR}/${ORACLE_SID}" ] && [ -f "${DATA_DIR}/.${ORACLE_SID}.created" ]; then
  echo "Starting database..."
  start_database
else
  echo "Creating database in silent mode..."
  setup_network_config
  create_database
  setup_tns
  run_user_scripts
fi

# Setup logging and prevent container from exiting
tail -f "${ORACLE_BASE}"/diag/rdbms/*/*/trace/alert*.log &
childPID=$!
wait $childPID