#!/bin/sh

set -e

launch(){
    create $1
    start
    shell
}

# Create a new container using a specified image.
# Use the current folder name as container name.
# Map the host users uid/gid to the container user.
create(){
    local image=$1
    local container=${PWD##*/}
    echo Creating container ${container} from image ${image}
    lxc init ${image} ${container}
    lxc config set ${container} boot.autostart false
    lxc config set ${container} raw.idmap "both $(id -u) 0"
    lxc config set ${container} user.lxw.type lxw
    lxc config set ${container} user.lxw.base ${image}
    lxc config set ${container} user.lxw.created "$(date -Iseconds)"
    echo Container ${container} has been created.
}

# Start a container, using the current folder name as container name.
start(){
    local container=${PWD##*/}
    echo Starting container ${container}
    lxc start ${container}
    echo Container ${container} has been started.
    sleep 5
    echo The IP address is $(getip)
}

# Restart a container, using the current folder name as container name.
restart(){
    local container=${PWD##*/}
    echo Restarting container ${container}
    lxc restart ${container}
    echo Container ${container} has been restarted.
    sleep 5
    echo The IP address is $(getip)
}

# Shutdown a container, using the current folder name as container name.
stop(){
    local container=${PWD##*/}
    echo Stopping container ${container}
    lxc stop ${container}
    echo Container ${container} has been stopped.
}

# Destroy a container, using the current folder name as container name.
# Command needs to be confirmed, running containers are stopped before deletion.
destroy(){
    local container=${PWD##*/}
    echo Killing container ${container}
    read -p "Continue (y/n)?" choice
    case "$choice" in
      y|Y ) delete;;
      * ) exit;;
    esac
}

delete(){
    local container=${PWD##*/}
    lxc delete ${container} -f
    echo Container ${container} has been removed.
}

# Open a shell inside a container, using the current folder name as container name.
# We don't know the current shell, so we use a little su tweak here.
shell(){
    local container=${PWD##*/}
    echo Entering container ${container}
    lxc exec ${container} su -
}

# Mount a host folder inside the container, using the current folder name as container name.
# We need to specify an alias for the mount, the (absolute or relative) path on the host,
# and the absolute path inside the container.
mnt(){
    local device=$1
    local source=$(readlink -e $2)
    local target=$3
    local container=${PWD##*/}
    echo Mounting device ${device} to container ${container}: ${source} "=>" ${target}
    lxc config device add ${container} ${device} disk source=${source} path=${target}
    echo Folder has been mounted.
}

# Unmount a shared folder, using the current folder name as container name, and the alias
unmnt(){
    local device=$1
    local container=${PWD##*/}
    echo Unmounting device ${device} from container ${container}
    lxc config device remove ${container} ${device}
    echo Folder has been unmounted.
}

# Show the current status of the container (e.g. the IP)
status(){
    local container=${PWD##*/}
    lxc list ${container}
}

# Show the current ip address of the container
getip(){
    local container=${PWD##*/}
    lxc list ${container} -c4 --format=csv | awk '{print $1;}'
}


# Show usage instructions
usage(){
    echo "LXW is a simple wrapper for LXD cli commands"
    echo ""
    echo "Usage: lxw <command>"
    echo ""
    echo "Commands:"
    echo "  launch <image>                           - Quickly create a container using an image, start it and enter a shell"
    echo "  create <image>                           - Create a container using an image"
    echo "  start                                    - Start the container"
    echo "  restart                                  - Restart the container"
    echo "  stop                                     - Stop the container"
    echo "  kill                                     - Remove the container (needs confirmation)"
    echo "  mount <alias> <host_dir> <container_dir> - Share a host folder with container"
    echo "  unmount <alias>                          - Stop sharing a host folder with container"
    echo "  shell                                    - Open a shell inside the container"
    echo "  status                                   - Show current container status"
    echo "  ip                                       - Show current container ip address"
    echo "  help                                     - Show usage instructions"
}

# We need at least one argument
if [ $# -eq 0 ]; then
   usage
   exit 1
fi

# Run the command given as argument
case "$1" in
    "launch")
    if [ $# -ne 2 ]; then
      usage
      exit 1;
    fi
    launch $2
    ;;
  "create")
    if [ $# -ne 2 ]; then
      usage
      exit 1;
    fi
    create $2
    ;;
  "start")
    start
    ;;
  "restart")
    restart
    ;;
  "stop")
    stop
    ;;
  "kill")
    destroy
    ;;
  "mount")
    if [ $# -ne 4 ]; then
      usage
      exit 1;
    fi
    mnt $2 $3 $4
    ;;
  "unmount")
    if [ $# -ne 2 ]; then
      usage
      exit 1;
    fi
    unmnt $2
    ;;
  "shell")
    shell
    ;;
  "status")
    status
    ;;
  "ip")
    getip
    ;;
  "help")
    usage
    ;;
  *)
    usage
    ;;
esac
