#!/bin/bash

# Function to deploy and configure host settings
deploy_and_configure() {
    local script_path="./configure-host.sh"
    local remote_user="remoteadmin"
    local servers=("server1-mgmt" "server2-mgmt")
    local hostnames=("loghost" "webhost")
    local ips=("192.168.16.3" "192.168.16.4")

    for ((i = 0; i < ${#servers[@]}; i++)); do
        # Transfer script to server
        echo "Transferring configure-host.sh to ${servers[i]}..."
        scp "$script_path" "$remote_user@${servers[i]}:/root/"

        # Apply configurations on the server
        ssh "$remote_user@${servers[i]}" "/root/configure-host.sh -name ${hostnames[i]} -ip ${ips[i]} -hostentry ${hostnames[((i+1)%${#servers[@]})]} ${ips[((i+1)%${#servers[@]})]}"

        # Check if configuration applied successfully
        if [ $? -eq 0 ]; then
            echo "Configuration applied successfully on ${servers[i]}."
        else
            echo "Failed to apply configuration on ${servers[i]}."
        fi
    done

    # Update local machine
    ./configure-host.sh -hostentry ${hostnames[0]} ${ips[0]}
    ./configure-host.sh -hostentry ${hostnames[1]} ${ips[1]}

    echo "All configurations applied."
}

# Execute deployment
deploy_and_configure
