#!/bin/bash

# InfluxDB parameters
INFLUXDB_URL="" # Replace with your InfluxDB instance URL
ORG=""                         # Replace with your organization name
BUCKET=""                   # Replace with your bucket name
TOKEN=""                     # Replace with your InfluxDB token

# Execute the kasa command and capture its output
output=$(kasa --host IP --username EMAILADDRESS --password PASSWORD)

# Extract Primary features
state=$(echo "$output" | awk '/State \(state\):/{print $3}')
current_consumption=$(echo "$output" | awk '/Current consumption \(current_consumption\):/{print $4}')
voltage=$(echo "$output" | awk '/Voltage \(voltage\):/{print $3}')
current=$(echo "$output" | awk '/Current \(current\):/{print $3}')

# Extract Information
signal_level=$(echo "$output" | awk '/Signal Level \(signal_level\):/{print $4}')
consumption_today=$(echo "$output" | awk '/Today'\''s consumption \(consumption_today\):/{print $4}')
consumption_this_month=$(echo "$output" | awk '/This month'\''s consumption \(consumption_this_month\):/{print $5}')

# Print extracted data to console
echo "== Primary Features =="
echo "State: $state"
echo "Current Consumption: $current_consumption W"
echo "Voltage: $voltage V"
echo "Current: $current A"

echo "== Information =="
echo "Signal Level: $signal_level"
echo "Today's Consumption: $consumption_today kWh"
echo "This Month's Consumption: $consumption_this_month kWh"

# Prepare line protocol data for InfluxDB
data="primary_features,device=p110 state=${state},current_consumption=${current_consumption},voltage=${voltage},current=${current}
information,device=p110 signal_level=${signal_level},consumption_today=${consumption_today},consumption_this_month=${consumption_this_month}"

# Write data to InfluxDB
curl -X POST "${INFLUXDB_URL}/api/v2/write?org=${ORG}&bucket=${BUCKET}&precision=s" \
  --header "Authorization: Token ${TOKEN}" \
  --data-raw "${data}"

echo "Data written to InfluxDB."
