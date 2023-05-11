#!/bin/bash
# This script installs oracle binaries
# following this doc https://oracle-base.com/articles/19c/oracle-db-19c-installation-on-oracle-linux-7

# unzip and install software
echo " ---> Unzipping ${INSTALL_FILE}..."
cd ${ORACLE_HOME} && \
unzip -oq ${INSTALL_FILE} && \
rm ${INSTALL_FILE}

echo " ---> Running installer in silent mode..."
./runInstaller -ignorePrereq -waitforcompletion -silent                        \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp               \
    oracle.install.option=INSTALL_DB_SWONLY                                    \
    ORACLE_HOSTNAME=${ORACLE_HOSTNAME}                                         \
    UNIX_GROUP_NAME=oinstall                                                   \
    INVENTORY_LOCATION=${ORA_INVENTORY}                                        \
    SELECTED_LANGUAGES=en,en_GB                                                \
    ORACLE_HOME=${ORACLE_HOME}                                                 \
    ORACLE_BASE=${ORACLE_BASE}                                                 \
    oracle.install.db.InstallEdition=${DB_EDITION}                             \
    oracle.install.db.OSDBA_GROUP=dba                                          \
    oracle.install.db.OSBACKUPDBA_GROUP=dba                                    \
    oracle.install.db.OSDGDBA_GROUP=dba                                        \
    oracle.install.db.OSKMDBA_GROUP=dba                                        \
    oracle.install.db.OSRACDBA_GROUP=dba                                       \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                 \
    DECLINE_SECURITY_UPDATES=true

echo " ---> Removing unneeded components..."
if $SLIMMING; then
    # APEX
    rm -rf ${ORACLE_HOME}/apex && \
    # ORDS
    rm -rf ${ORACLE_HOME}/ords && \
    # SQL Developer
    rm -rf ${ORACLE_HOME}/sqldeveloper && \
    # UCP connection pool
    rm -rf ${ORACLE_HOME}/ucp && \
    # All installer files
    rm -rf ${ORACLE_HOME}/lib/*.zip && \
    # OUI backup
    rm -rf ${ORACLE_HOME}/inventory/backup/* && \
    # Network tools help
    rm -rf ${ORACLE_HOME}/network/tools/help && \
    # Database upgrade assistant
    rm -rf ${ORACLE_HOME}/assistants/dbua && \
    # Database migration assistant
    rm -rf ${ORACLE_HOME}/dmu && \
    # Remove pilot workflow installer
    rm -rf ${ORACLE_HOME}/install/pilot && \
    # Support tools
    rm -rf ${ORACLE_HOME}/suptools && \
    # Temp location
    rm -rf /tmp/* && \
    # Database files directory
    rm -rf ${INSTALL_DIR}/database
fi

echo "Installation Complete!"