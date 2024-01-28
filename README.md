# Palworld Reset scirpt

> This script validates the memory that is available to decide if it should do a reboot.
> Additionally, validate the running time and if it is more than the setted, will also restart the server.

> [!IMPORTANT]
> This script was made to work with this XX image and on a Linux server.
> however it should be able to work with any other image that enables rcon.

## Server Requirements

Linux, only tested on Ubuntu 22 and Debian 12

## How to use

1. You need to change the following variables in the script
   * DISCORD_URL：   // Your own webhock for Discord.
   * MEM_LIMIT=300   // Available memory limit (unit: MB), here is 300MB.
   * MAX_TIME=14400  // Maximum execution time to restart, in seconds

2. Copy the script to the root of your server
3. Add execute permission to a file Ex chmod +x /home/user/palworld/check_and_restart.sh
4. Run the script ./home/user/palworld/check_and_restart.sh
