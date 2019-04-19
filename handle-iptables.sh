#!/bin/bash
iptables=/sbin/iptables
tee=/usr/bin/tee
grep=/bin/grep
wc=/usr/bin/wc
mkdir=/bin/mkdir

log=/var/log/sesame-gateway/iptables-handler.log

sudo $mkdir -p "$log"

if [ $# -lt 4 ]
then
  echo "You Need To Specify A Command!!!"
  echo "./program action ipaddress port protocol <ipaddress2> <port2>"
  exit
fi

action="$1"
ipaddress="$2"
port="$3"
protocol="$4"
ipaddress2="$5"
port2="$6"

echo "IPTables Handler" | $tee -a $log
# Delete Rules
if [ "$action" = "delete-accept" ]; then
  echo "Delete Accept Tables" | $tee -a $log
  echo $iptables -D INPUT -s $ipaddress -p $protocol --dport $port -j ACCEPT | $tee -a $log
  $iptables -D INPUT -s $ipaddress -p $protocol --dport $port -j ACCEPT | $tee -a $log
fi

if [ "$action" = "delete-dnat" ] && [ $# -eq 6 ]; then
  echo "Delete DNAT Tables" | $tee -a $log
  echo $iptables -t nat -D PREROUTING -s $ipaddress -p $protocol --dport $port -j DNAT --to-destination $ipaddress2:$port2 | $tee -a $log
  $iptables -t nat -D PREROUTING -s $ipaddress -p $protocol --dport $port -j DNAT --to-destination $ipaddress2:$port2 | $tee -a $log
fi

# Add Rules
if [ "$action" = "accept" ]; then
  echo "Accept Tables" | $tee -a $log

  echo "Checking If Rule Already Exists" | $tee -a $log
  rules=$($iptables -L INPUT -n | grep $ipaddress | grep $protocol | grep $port | $wc -l)
  echo "Debug Rules: \"$rules\"" | $tee -a $log

  if [ "$rules" -eq "0" ]; then
    echo $iptables -A INPUT -s $ipaddress -p $protocol --dport $port -j ACCEPT | $tee -a $log
    $iptables -A INPUT -s $ipaddress -p $protocol --dport $port -j ACCEPT | $tee -a $log
  else
    echo "\"$iptables -A INPUT -s $ipaddress -p $protocol --dport $port -j ACCEPT\" Already Exists!!!" | $tee -a $log
  fi
fi

if [ "$action" = "dnat" ] && [ $# -eq 6 ]; then
  echo "DNAT Tables" | $tee -a $log

  echo "Checking If Rule Already Exists" | $tee -a $log
  rules=$($iptables -t nat -L PREROUTING -n | grep $ipaddress | grep $protocol | grep $port | $wc -l)
  echo "Debug Rules: \"$rules\"" | $tee -a $log

  if [ "$rules" -eq "0" ]; then
    echo $iptables -t nat -I PREROUTING 1 -s $ipaddress -p $protocol --dport $port -j DNAT --to-destination $ipaddress2:$port2 | $tee -a $log
    $iptables -t nat -I PREROUTING 1 -s $ipaddress -p $protocol --dport $port -j DNAT --to-destination $ipaddress2:$port2 | $tee -a $log
  else
    echo "\"$iptables -t nat -I PREROUTING 1 -s $ipaddress -p $protocol --dport $port -j DNAT --to-destination $ipaddress2:$port2\" Already Exists!!!" | $tee -a $log
  fi
fi
echo "End IPTables Handler\n" | $tee -a $log