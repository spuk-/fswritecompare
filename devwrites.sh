#!/bin/bash

[ -n "$DEBUG" ] && set -x

read DEV FSTYPE < <(df --output=source,fstype / | tail -n1)

# time_t,hostname,pid,device,devsn,fstype,data_units_written,host_writes,controller_busy_time,power_on_hours,cmd
JQUERYCSV=". | [ .local_time.time_t, \"${HOSTNAME%%.*}\", \"PID=$$\", .device.name, .serial_number, \"$FSTYPE\", .nvme_smart_health_information_log.data_units_written, .nvme_smart_health_information_log.host_writes, .nvme_smart_health_information_log.controller_busy_time, .nvme_smart_health_information_log.power_on_hours, \"$*\" ] | @csv"

BASE="/tmp/smart_${HOSTNAME%%.*}_${DEV##*/}_${1##*/}"

echo "BASE: $BASE"

rm -vf "${BASE}_0.json" "${BASE}_1.json"

smartctl -j -x "$DEV" >"${BASE}_0.json"
jq -r <"${BASE}_0.json" "$JQUERYCSV" | tee -a "$0.csv"
if [ -n "$DEBUG" ]; then
    echo "$@"
else
    "$@"
fi
[ -n "$DEBUG" ] || echo "Sleeping ${WAIT:-40}..." >&2 && sleep "${WAIT:-40}"
smartctl -j -x "$DEV" >"${BASE}_1.json"
jq -r <"${BASE}_1.json" "$JQUERYCSV" | tee -a "$0.csv"
