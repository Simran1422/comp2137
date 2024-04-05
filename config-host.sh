#!/bin/bash

# Function to log changes
log_changes() {
    local message="$1"
    if [ "$VERBOSE" = true ]; then
        echo "Change: $message"
    fi
    logger -t config-script "$message"
}

# Function to update hostname
update_hostname() {
    local new_name="$1"
    local current_name=$(hostname)
    if [ "$new_name" != "$current_name" ]; then
        sed -i "s/$current_name/$new_name/g" /etc/hosts
        echo "$new_name" > /etc/hostname
        log_changes "Hostname changed to $new_name"
    fi
}

# Function to update IP address
update_ip() {
    local new_ip="$1"
    local current_ip=$(hostname -I | awk '{print $1}')
    if [ "$new_ip" != "$current_ip" ]; then
        sed -i "s/$current_ip/$new_ip/g" /etc/hosts
        log_changes "IP address updated to $new_ip"
    fi
}

# Function to update /etc/hosts entry
update_host_entry() {
    local name="$1"
    local ip="$2"
    if ! grep -q "$name" /etc/hosts; then
        echo "$ip $name" >> /etc/hosts
        log_changes "Added $name with IP $ip to /etc/hosts"
    fi
}

# Ignore signals
trap '' TERM HUP INT

# Parse command line arguments
VERBOSE=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        -verbose) VERBOSE=true;;
        -name) update_hostname "$2"; shift;;
        -ip) update_ip "$2"; shift;;
        -hostentry) update_host_entry "$2" "$3"; shift 2;;
        *) echo "Unknown option: $1" >&2;;
    esac
    shift
done
