# LXW - Simple cli wrapper for LXD containers

## Introduction

### About LXD/LXC
Linux containers are great for local development environments, quickly testing stuff, and much more.
Nowadays everybody talks Docker, but Docker might be an overkill in terms of complexity and learning curve.
There's a lightweight alternative: Linux containers built with [LXD](https://linuxcontainers.org/lxd).

There are two major differences between Docker containers and LXD containers:

* LXD containers are persistent by default. Things you change inside containers are kept.
* Docker containers normally run a single process. LXD doesn't have this limitation.

In fact, LXD container are much more like traditional VMs. They are a good bet e.g. for simple
local development environments. There are caveats for sure:

* The ecosystem is much smaller, e.g. there's a lack of orchestration tools
* The technology is still young, and might be a moving target. 

### Why LXW ?
LXW is a simple wrapper for LXD's command line interface, lxc. It's no replacement, but a small addition
to make some things simpler, e.g. mounting host folders inside containers, and sharing file access rights.
In fact, it just uses plain lxc commands and some shell script magic to achieve this goal.

### Basic concept
LXW uses preconfigured LXD images to spin up containers. So for example you might use a LXD stock image,
start a container, orchestrate it for your needs and publish it as a new local image. So you might end up
with some local base images like 'drupal-7', 'nodejs', whatever.

That's the point where LXW comes in:

Using your custom images, you'll spin up new containers for your projects in no time. LXW uses your current
folder as container name, so it might go like this:

* Your project is located in ~/projects/someproject
* The source files are located in ~/projects/someproject/source
* You want to use a customized local image named 'nodejs' 
* Inside your folder, just create a new container using LXW:`lxw create nodejs`, this
gives you a container named "someproject"
* Share your source folder using LXW: `lxw mount code ./source /var/www/html`
* Start the container: `lxw start`
* Open a shell:`lxw shell`

And so on, you get it.

## Requirements
The wrapper scripts needs [LXD](https://linuxcontainers.org/lxd) installed and configured.
While it might work on many Linux distributions, it has been tested on current Ubuntu releases only.
Stock images for LXD containers are located on the [LXD image server](https://us.images.linuxcontainers.org/)
It's your part to create suitable custom images for use with LXW.

## Installation

### LXD/LXC
Instructions for installing LXD can be found [here](https://linuxcontainers.org/lxd/getting-started-cli/)

### LXW
Installing LXW is simple: just copy the script to /usr/local/bin, naming it 'lxw' and make it executable:

```
sudo mv lxw.sh /user/local/bin/lxw
sudo chmod +x /usr/local/bin/lxw
```

## Commands

### lxw create \<image>
Create a container using a local or remote image

Examples:

```
lxw create images:alpine/3.5
lxw create mylocalimage
```

### lxw start
Start the container

### lxw restart
Restart the container

### lxw stop
Stop (shutdown) the container

### lxw kill
Destroy the container. Displays a confirmation message and deletes the container. All data outside of shared folders will get lost.  

### lxw mount \<alias> \<host_path> \<container_path>
Share a folder on the host system with the container. Both the host user and the user inside the container get full access rights. Arguments:

* *alias* - a custom name for the share, as there can be multiple ones
* *host_path* - The path on the host system (relative or absolute)
* *container_path* - The path inside the container (must be absolute)

Example:

```
lxw mount code ./source /var/www/html
```

### lxw unmount \<alias>

Unmounts a shared folder using the alias

Example:

```
lxw unmount code
```

### lxw shell
Open a shell inside the container, using the default shell configured inside the container.

### lxw status
Display the current status of the container, including the IP

### lxw help
Show usage instructions

## License: MIT
