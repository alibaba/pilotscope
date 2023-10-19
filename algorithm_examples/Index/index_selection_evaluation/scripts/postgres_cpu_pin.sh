#!/bin/bash

# Start the postgresql service and pin it to the NUMA node of the current process
# (e.g. after creating a process on a specific NUMA node `numactl -N2 -m2 zsh`)

sudo service postgresql start

numacpu_ids=$(numactl --show | sed -n -e 's/^.*physcpubind: //p' | awk '{$1=$1};1' | sed -e "s/ /,/g")
postmaster_pid=$(pidof postgres | xargs -n1 | sort | head -n1)
sudo taskset -pc $numacpu_ids $postmaster_pid
pidof postgres -o $postmaster_pid | sudo xargs -n1 taskset -pc $numacpu_ids
