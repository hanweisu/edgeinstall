#!/bin/bash
echo "Install zabbix agent"
mgtint=eth0
twnet="10.10.13"
hknet="10.11.51"
ipc=`which ip`
ip=`$ipc addr show $mgtint | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}'`
net=`$ipc addr show $mgtint | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' | cut -d'.' -f1-3`
echo "Installing Zabbix agent"
rpm -Uvh https://repo.zabbix.com/zabbix/3.4/rhel/6/x86_64/zabbix-agent-3.4.15-1.el6.x86_64.rpm
#yum -y install zabbix-agent
chkconfig zabbix-agent on

echo "Setting Zabbix agent"
if [ $net = $twnet ]; then
        echo "Add Zabbix agent to TW"
        sed -i 's/Server=127.0.0.1/Server=10.10.13.219/g' /etc/zabbix/zabbix_agentd.conf
elif [ $net = $hknet ]; then
        echo "Add Zabbix agent to HK"
        sed -i 's/Server=127.0.0.1/Server=10.11.52.249/g' /etc/zabbix/zabbix_agentd.conf
	sed -i "s/ListenIP=0.0.0.0/ListenIP=$ip/g" /etc/zabbix/zabbix_agentd.conf

else
        echo "Please check $mgtint $ip settings" && exit 0
fi

echo "Restarting zabbix-agent service"
service zabbix-agent restart
