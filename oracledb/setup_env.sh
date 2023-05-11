#!/bin/bash
# This script sets up the linux environment to install oracle 
# following this doc https://oracle-base.com/articles/19c/oracle-db-19c-installation-on-oracle-linux-7

# Install oracle-database prerequisites and clean up cache
yum install -y oracle-database-preinstall-19c && \
yum clean all && \
rm -rf /var/cache/yum && \

# Create the directories in which the Oracle software will be installed
mkdir -p ${ORACLE_HOME} && \
mkdir -p ${DATA_DIR} && \
chown -R oracle:oinstall ${ORACLE_BASE} && \
chmod -R 775 ${ORACLE_BASE}