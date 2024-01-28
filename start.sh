#!/bin/bash

# The name of the container
PAL_CONTAINER_NAME="palworld-server"
CONTAINER_ID=$(docker ps --filter name="${CONTAINER_NAME}" --format '{{.ID}}')

# The URL to send the request.
DISCORD_URL="https://discord.com/api/webhooks/1201205960362963075/90Q9q15yamGQmXsYnq4gCO2YE4irJurg2vyUjfaU_TPBcyY04f0GLnBaPZwn3HQfAq12"

# Available memory limit (unit: MB), here is 300MB.
MEM_LIMIT=50000

# Maximum execution time to restart, in seconds
SEC_LIMIT=14400

# Function to send messages to WeCom Bot
send_discord_message() {
    local message=$1
    local json_data=$(cat <<EOF
{
  "content": "$message",
  "username": "PalBot",
  "avatar_url": "https://tech.palworldgame.com/assets/logo.jpg"
}
EOF
)

    curl -s -w "\n" "$DISCORD_URL" \
        -H 'Content-Type: application/json' \
        -d "$json_data"
    echo "Message sent to Discord: $message"
}

start_pal_server() {
    docker exec -it "${CONTAINER_ID}" /usr/bin/rcon-cli "Broadcast El_servidor_se_reiniciara_en_30_segundos."
    docker exec -it "${CONTAINER_ID}" rcon-cli Save
    docker exec -it "${CONTAINER_ID}" rcon-cli Shutdown
    sleep 10
    docker stop "${CONTAINER_ID}"
    docker start "${CONTAINER_ID}"
    echo "$PAL_CONTAINER_NAME" " started"
}

# Function to check memory and running time and restart.
check_and_restart() {
    # Get the available memory of the entire system (unit: MB)
    AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')
    echo "Available Memory - ${AVAILABLE_MEM}MB..."
    # If the available memory is below the limit, restart the server
    if [ "$AVAILABLE_MEM" -lt "$MEM_LIMIT" ]; then
        echo "Memory limit exceeded: Available - ${AVAILABLE_MEM}MB, Limit - ${MEM_LIMIT}MB. Restarting PalServer.sh..."
        send_discord_message "Memory limit exceeded: Available - ${AVAILABLE_MEM}MB, Limit - ${MEM_LIMIT}MB. Restarting PalServer.sh..."
        start_pal_server
    else
        echo 'Palworld memory is healthy'
        START=$(docker inspect --format='{{.State.StartedAt}}' "${CONTAINER_ID}")
        START_TIMESTAMP=$(date --date=$START +%s)
        STOP_TIMESTAMP=$(date +%s)
        RUNNING_TIME=$(($STOP_TIMESTAMP-$START_TIMESTAMP))
        if [ "$RUNNING_TIME" -gt "$SEC_LIMIT" ]; then
            echo "The maximum execution time was reached, restarting the server"
            send_discord_message "The maximum execution time was reached, restarting the server"
            start_pal_server
        else
            echo "Execution time: " "${RUNNING_TIME}"
        fi
    fi
}

echo "Checking server..."
check_and_restart
