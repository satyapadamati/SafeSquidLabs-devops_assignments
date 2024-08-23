#!/bin/bash

# Define variables
REPORT_FILE="/var/log/security_audit_report.log"
CONFIG_FILE="./custom_security_checks.conf"

# Function to log and print messages
log_message() {
    echo "$1" | tee -a "$REPORT_FILE"
}

# 1. User and Group Audits
user_group_audit() {
    log_message "========== User and Group Audits =========="
    log_message "All Users:"
    cut -d: -f1 /etc/passwd | tee -a "$REPORT_FILE"
    
    log_message "All Groups:"
    cut -d: -f1 /etc/group | tee -a "$REPORT_FILE"

    log_message "Users with UID 0 (root privileges):"
    awk -F: '($3 == "0") {print $1}' /etc/passwd | tee -a "$REPORT_FILE"

    log_message "Users without passwords or with weak passwords:"
    awk -F: '($2 == "" || length($2) < 6) {print $1}' /etc/shadow | tee -a "$REPORT_FILE"
}

# 2. File and Directory Permissions Audit
file_permission_audit() {
    log_message "========== File and Directory Permissions Audit =========="
    log_message "World-writable files and directories:"
    find / -type f -perm -o+w -exec ls -l {} \; | tee -a "$REPORT_FILE"

    log_message "Checking .ssh directory permissions:"
    find /home -type d -name ".ssh" -exec ls -ld {} \; | tee -a "$REPORT_FILE"

    log_message "Files with SUID or SGID bits set:"
    find / -perm /6000 -type f -exec ls -l {} \; | tee -a "$REPORT_FILE"
}

# 3. Service Audits
service_audit() {
    log_message "========== Service Audits =========="
    log_message "Running Services:"
    systemctl list-units --type=service --state=running | tee -a "$REPORT_FILE"

    log_message "Checking critical services:"
    for service in sshd iptables; do
        systemctl is-active --quiet $service && log_message "$service is running" || log_message "$service is not running"
    done

    log_message "Checking for services listening on non-standard ports:"
    netstat -tuln | awk '$4 !~ /:22|:80|:443/ {print $0}' | tee -a "$REPORT_FILE"
}

# 4. Firewall and Network Security Audit
network_security_audit() {
    log_message "========== Firewall and Network Security Audit =========="
    log_message "Firewall Status:"
    if command -v ufw >/dev/null 2>&1; then
        ufw status | tee -a "$REPORT_FILE"
    elif command -v iptables >/dev/null 2>&1; then
        iptables -L | tee -a "$REPORT_FILE"
    else
        log_message "No firewall detected."
    fi

    log_message "Open Ports:"
    netstat -tuln | tee -a "$REPORT_FILE"

    log_message "IP Forwarding Status:"
    sysctl net.ipv4.ip_forward | tee -a "$REPORT_FILE"
}

# 5. IP and Network Configuration Checks
ip_network_configuration() {
    log_message "========== IP and Network Configuration Checks =========="
    log_message "Public vs. Private IPs:"
    ip addr show | awk '/inet / {print $2 " " $7}' | tee -a "$REPORT_FILE"

    log_message "Checking if sensitive services (SSH) are exposed on public IPs:"
    if netstat -tuln | grep -q ":22"; then
        log_message "SSH is listening on public IP"
    else
        log_message "SSH is not exposed on public IP"
    fi
}

# 6. Security Updates and Patching
security_updates() {
    log_message "========== Security Updates and Patching =========="
    log_message "Checking for available updates:"
    apt-get update && apt-get -s upgrade | grep -i "upgrade" | tee -a "$REPORT_FILE"

    log_message "Configuring unattended-upgrades for automatic updates:"
    dpkg-reconfigure -plow unattended-upgrades
}

# 7. Log Monitoring
log_monitoring() {
    log_message "========== Log Monitoring =========="
    log_message "Checking for suspicious SSH login attempts:"
    grep "Failed password" /var/log/auth.log | tail -n 10 | tee -a "$REPORT_FILE"
}

# 8. Server Hardening Steps
server_hardening() {
    log_message "========== Server Hardening =========="

    log_message "Implementing SSH key-based authentication:"
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd

    log_message "Disabling IPv6:"
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p

    log_message "Setting GRUB bootloader password:"
    grub-mkpasswd-pbkdf2 | tee -a "$REPORT_FILE"
    
    log_message "Configuring iptables firewall:"
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables-save > /etc/iptables/rules.v4
}

# 9. Custom Security Checks
custom_security_checks() {
    log_message "========== Custom Security Checks =========="
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_message "Running custom checks..."
        custom_checks | tee -a "$REPORT_FILE"
    else
        log_message "No custom checks configured."
    fi
}

# 10. Reporting and Alerting
send_report() {
    log_message "========== Sending Report =========="
    mail -s "Security Audit Report" admin@example.com < "$REPORT_FILE"
}

# Run all functions
user_group_audit
file_permission_audit
service_audit
network_security_audit
ip_network_configuration
security_updates
log_monitoring
server_hardening
custom_security_checks
send_report

log_message "Security audit and server hardening completed. Check $REPORT_FILE for details."
