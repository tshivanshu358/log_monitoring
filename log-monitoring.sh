#!/bin/bash

# Function to monitor log file
monitor_log_file() {
    local logfile="$1"
    local lines_to_process=10                         # To check limited number of lines
    tail -n "$lines_to_process" -f "$logfile" | while read -r line; do
        echo "$line"
        analyze_log_entry "$line" 
        
    #tail -n0 -f "$logfile" | while read line; do
     #   echo "$line"                               # To display new log entries
    done
}

# Function to analyze log entries
analyze_log_entry() {
    local entry="$1"
    # Perform analysis here (count occurrences, generate summary reports, etc.)

   
    if grep -qE "$http_status_pattern" <<< "$1"; then   # Count occurrences of HTTP status codes
        ((http_status_count++))
    fi
    error_count=$(echo "$entry" | grep -c "error")   # Count occurrences of "error" in log entry
    echo "Error count: $error_count"

    # summary reports
    if ((error_count > 0)); then
        echo "Error count: $error_count"
    fi

    if ((http_status_count > 0)); then
        echo "HTTP status code count: $http_status_count"
    fi
}

# Main function
main() {
    local logfile="/path/to/logfile.log"
    monitor_log_file "$logfile" &    # Start monitoring log file in the background
    local monitor_pid=$!
    
    # Trap SIGINT signal to stop monitoring loop
    trap "kill $monitor_pid; echo 'Monitoring stopped.'; exit" SIGINT
    
    # Loop indefinitely/ to read and analyze new log
    while true; do
        
        read -r new_entry  # Read new log entry
        analyze_log_entry "$new_entry"  # Analyze log entry
        
    done
}

# Start script
main
