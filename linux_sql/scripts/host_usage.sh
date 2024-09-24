#!/bin/bash

# Assign CLI arguments to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check the number of arguments
if [ "$#" -ne 5 ]; then
    echo "Error: Illegal number of parameters"
    echo "Usage: ./host_usage.sh psql_host psql_port db_name psql_user psql_password"
    exit 1
fi

# Get machine statistics and hostname
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

# Extract the data from vmstat output
memory_free=$(echo "$vmstat_mb" | awk '{print $4}' | tail -n 1 | xargs)
cpu_idle=$(echo "$vmstat_mb" | awk '{print $15}' | tail -n 1 | xargs)
cpu_kernel=$(echo "$vmstat_mb" | awk '{print $14}' | tail -n 1 | xargs)
disk_io=$(vmstat -d | awk '{print $10}' | tail -n 1 | xargs)
disk_available=$(df -BM / | grep -v 'Available' | awk '{print $4}' | sed 's/M//')

# Get current timestamp
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Subquery to find matching id in host_info table
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

# Construct the INSERT statement
insert_stmt="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) \
VALUES ('$timestamp', $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available');"

# Export password and execute the INSERT statement
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

# Exit with the status of the last command
exit $?

