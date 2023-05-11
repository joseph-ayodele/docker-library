# Setup Stage
FROM oraclelinux:7-slim as base

# Build arguments
ARG VERSION=19.0.0
ARG SETUP_SCRIPT=setup_env.sh
ARG ORACLE_BASE=/u01/app/oracle
ARG DATA_DIR=${ORACLE_BASE}/oradata

# Environment variables
ENV SLIMMING=true \
 ORACLE_SID=ORCL \
 ORACLE_HOSTNAME=0.0.0.0 \
 DB_PWD=renaissance \
 ORACLE_BASE=${ORACLE_BASE} \
 ORA_INVENTORY=${ORACLE_BASE}/oraInventory \
 DATA_DIR=${DATA_DIR} \
 INSTALL_DIR=${ORACLE_BASE}/install \
 ORACLE_HOME=${ORACLE_BASE}/product/${VERSION}/dbhome_1

ENV PATH=${ORACLE_HOME}/bin:/usr/sbin:/usr/local/bin:${PATH} \
 LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/lib:/usr/lib \
 CLASSPATH=${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib

# Copy setup script
COPY ${SETUP_SCRIPT} ${INSTALL_DIR}/${SETUP_SCRIPT}

# Run setup script
RUN chmod ug+x ${INSTALL_DIR}/${SETUP_SCRIPT} && \
 sync && \
 /bin/bash ${INSTALL_DIR}/${SETUP_SCRIPT}

# Installation Stage
FROM base AS builder

# More build arguments
ARG INSTALL_SCRIPT=install_db.sh
ARG INSTALL_FILE=LINUX.X64_193000_db_home.zip

# More environment variables
ENV INSTALL_FILE=${INSTALL_FILE} \
 DB_EDITION=SE2

# Copy DB install file and install script
COPY --chown=oracle:oinstall ${INSTALL_FILE} ${ORACLE_HOME}/${INSTALL_FILE}
COPY --chown=oracle:oinstall ${INSTALL_SCRIPT} ${INSTALL_DIR}/${INSTALL_SCRIPT}

# Change user and install script
USER oracle
RUN chmod ug+x ${INSTALL_DIR}/${INSTALL_SCRIPT} && \
 sync && \
 /bin/bash ${INSTALL_DIR}/${INSTALL_SCRIPT} 

# Database Creation Stage
FROM base

# More build arguments
ARG SQL_SCRIPTS_DIR=sql_scripts

# More environment variables
ENV CREATE_DB_SCRIPT=create_db.sh

# Change user and copy ORACLE_BASE
USER oracle
COPY --chown=oracle:dba --from=builder ${ORACLE_BASE} ${ORACLE_BASE}

# Change user and run scripts 
USER root
RUN ${ORA_INVENTORY}/orainstRoot.sh && \
    ${ORACLE_HOME}/root.sh 

ENV USER_SCRIPTS=${ORACLE_BASE}/scripts

USER oracle
COPY --chown=oracle:dba ${CREATE_DB_SCRIPT} ${INSTALL_DIR}/${CREATE_DB_SCRIPT}
COPY --chown=oracle:dba ${SQL_SCRIPTS_DIR} ${USER_SCRIPTS}

RUN chmod ug+x ${INSTALL_DIR}/${CREATE_DB_SCRIPT}

# Entrypoint is create db script
CMD ${INSTALL_DIR}/${CREATE_DB_SCRIPT}