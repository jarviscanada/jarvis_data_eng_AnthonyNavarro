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
    echo "Usage: ./host_info.sh psql_host psql_port db_name psql_user psql_password"
    exit 1
fi

# Get hardware specifications
hostname=$(hostname -f)
cpu_number=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
cpu_architecture=$(lscpu | grep "Architecture" | awk '{print $2}')
cpu_model=$(lscpu | grep "Model name" | awk '{for (i=3; i<=NF; i++) printf $i " "; print ""}')
cpu_mhz=$(lscpu | grep "CPU MHz" | awk '{print $3}')
L2_cache=$(lscpu | grep "L2 cache" | awk '{print $3}' | sed 's/K//')
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Construct the INSERT statement
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, L2_cache, total_mem, timestamp) \
VALUES ('$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$L2_cache', '$total_mem', '$timestamp');"

# Export password and execute the INSERT statement
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

# Exit with the status of the last command
exit $?

