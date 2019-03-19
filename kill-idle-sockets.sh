# Sudo is needed for this program (for TCPKill and KillCX)

# $1 is client ip address and $2 is host/port of service
# $3 is network device (e.g. wlan0)

#!/bin/bash
cat=/bin/cat
grep=/bin/grep
cut=/usr/bin/cut
netstat=/bin/netstat
tcpkill=/usr/sbin/tcpkill
sudo=/usr/bin/sudo
perl=/usr/bin/perl
rev=/usr/bin/rev
sed=/bin/sed

killcx=/home/web/programs/killconnection/killcx.pl

if [ $# -lt 3 ]
then
  echo "You Need To Specify A Command!!!"
  echo "./program client-ip-address host/port-of-service network-device-e.g.-wlan0"
  exit
fi

# $1 is client ip address and $2 is host/port of service
connections=$($netstat -en | $grep $1 | $grep $2)

#hosts=$(echo $connections | $cut -d: -f2 | $rev | $cut -d' ' -f1 | $rev)
#ports=$(echo $connections | $cut -d: -f3 | $cut -d' ' -f1)
#inodes=$(echo $connections | $rev | $cut -d ' ' -f1 | $rev)

IFS="
"
for connection in $connections
do
  inode=$(echo $connection | $rev | $sed -e 's/^[ \t]*//' | $cut -d' ' -f1 | $rev)
  activity=$($cat /proc/net/tcp | $grep $inode | $cut -d' ' -f7)
  server_send=$(echo $activity | $cut -d: -f1)
  server_receive=$(echo $activity | $cut -d: -f1)

  echo "Connection: $connection"
  echo "Inode: $inode Activity: $activity"
  echo "Send: $server_send Receive: $server_receive"
  if [ "$server_send" = "00000000" ] && [ "$server_receive" = "00000000" ]; then
    # Run TCPKill and KillCX only if the server is not currently transmitting data

    host=$(echo $connection | $cut -d: -f2 | $rev | $cut -d' ' -f1 | $rev)
    port=$(echo $connection | $cut -d: -f3 | $cut -d' ' -f1)

    # https://stackoverflow.com/a/33203048/6828099
    echo $connection

    echo "Client Connection: $host:$port"
    echo tcpkill -i $3 port $port
    $tcpkill -i $3 port $port

    #echo $perl $killcx $host:$port $3
    #$perl $killcx $host:$port $3

    echo nmap -g $port -p 0 $host
    nmap -g $port -p 0 $host

    # https://serverfault.com/a/585433/379269
    sleep 7
    for child in $(jobs -p); do
      echo kill "$child" && kill "$child"
    done
    wait $(jobs -p)
  fi
done