# System Resource Monitoring Dashboard

## Overview
This Bash script monitors various system resources on a proxy server and displays them in a dashboard format with real-time updates. The script provides insights into CPU and memory usage, network activity, disk space usage, system load, process monitoring, and essential services status. Additionally, users can call specific parts of the dashboard individually using command-line switches.

## Features
- **Top 10 Most Used Applications**: Displays the top 10 applications consuming the most CPU and memory.
- **Network Monitoring**: Shows the number of concurrent connections, packet drops, and network bandwidth usage.
- **Disk Usage**: Displays disk space usage and highlights partitions using more than 80% of the space.
- **System Load**: Shows the current load average and CPU usage breakdown.
- **Memory Usage**: Displays total, used, and free memory, along with swap memory usage.
- **Process Monitoring**: Displays the number of active processes and the top 5 processes by CPU and memory usage.
- **Service Monitoring**: Monitors the status of essential services like `sshd`, `nginx`, `apache2`, `iptables`, etc.
- **Custom Dashboard**: Allows users to view specific parts of the dashboard using command-line switches.

## Requirements
- **Bash**: Ensure you are running this script in a Bash-compatible shell.
- **Utilities**: The script uses standard utilities like `ps`, `df`, `uptime`, `free`, `netstat`, and `systemctl`.

## Installation
1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/system-monitoring-dashboard.git
    cd system-monitoring-dashboard
    ```
2. Make the script executable:
    ```bash
    chmod +x system_monitor.sh
    ```

## Usage
You can run the script in multiple ways, depending on what you want to monitor:

### Full Dashboard (Real-Time Monitoring)
To start the full dashboard, run:
```bash
./system_monitor.sh
To monitor only network activity and disk usage, you can run:
./system_monitor.sh -network -disk


 
