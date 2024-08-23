#!/bin/bash

# Function to display the top 10 most CPU and memory-intensive applications
top_applications() {
    echo "==================== Top 10 Applications by CPU and Memory Usage ===================="
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11
    echo "====================================================================================="
}

# Function to monitor network activity
network_monitoring() {
    echo "==================== Network Monitoring ===================="
    echo "Concurrent Connections: $(netstat -an | grep ESTABLISHED | wc -l)"
    echo "Packet Drops:"
    netstat -i | awk '/^[a-z]/ { print $1 " - Dropped: " $4 }'
    echo "MB In and Out:"
    ifconfig | awk '/RX bytes/ {print $0}'
    echo "============================================================"
}

# Function to display disk usage by mounted partitions
disk_usage() {
    echo "==================== Disk Usage ===================="
    df -h | awk 'NR==1 || $5 > 80 {print $0}'
    echo "===================================================="
}

# Function to show system load and CPU usage breakdown
system_load() {
    echo "==================== System Load ===================="
    uptime
    echo "CPU Usage Breakdown:"
    mpstat | awk '$3 ~ /[0-9.]+/ {print "User: " $3 "%, System: " $5 "%, Idle: " $13 "%"}'
    echo "====================================================="
}

# Function to display memory and swap usage
memory_usage() {
    echo "==================== Memory Usage ===================="
    free -h
    echo "Swap Memory Usage:"
    swapon -s
    echo "======================================================"
}

# Function to monitor processes
process_monitoring() {
    echo "==================== Process Monitoring ===================="
    echo "Number of Active Processes: $(ps aux | wc -l)"
    echo "Top 5 Processes by CPU and Memory Usage:"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
    echo "============================================================"
}

# Function to monitor the status of essential services
service_monitoring() {
    echo "==================== Service Monitoring ===================="
    for service in sshd nginx apache2 iptables; do
        systemctl is-active --quiet $service && echo "$service is running" || echo "$service is not running"
    done
    echo "============================================================"
}

# Function to display the full dashboard in real-time
dashboard() {
    while true; do
        clear
        echo "==================== System Resource Monitoring Dashboard ===================="
        top_applications
        echo
        network_monitoring
        echo
        disk_usage
        echo
        system_load
        echo
        memory_usage
        echo
        process_monitoring
        echo
        service_monitoring
        echo "==============================================================================="

        sleep 5
    done
}

# Handling command-line switches to display specific parts of the dashboard
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -cpu )
    top_applications
    ;;
  -network )
    network_monitoring
    ;;
  -disk )
    disk_usage
    ;;
  -load )
    system_load
    ;;
  -memory )
    memory_usage
    ;;
  -process )
    process_monitoring
    ;;
  -service )
    service_monitoring
    ;;
esac; shift; done

# If no command-line switches are provided, run the full dashboard
if [ $# -eq 0 ]; then
    dashboard
fi
