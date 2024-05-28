# Use the official Oracle Database image as the base
FROM container-registry.oracle.com/database/free:23.3.0.0

# Set the working directory in the container
WORKDIR /opt/oracle/scripts/startup

# Copy the setup script into the container
COPY --chmod=755 ./startup/setup.sh ./setup.sh
COPY ./startup/setup.sql-setup ./setup.sql-setup