#!/bin/sh
echo "Adding Kangle monitor script for Zabbix"
test ! -d /etc/zabbix/scripts && echo "Zabbix scripts directory doesn't exist, creating..." && mkdir /etc/zabbix/scripts
tee -a /etc/zabbix/scripts/kangle_status.sh << END
#/bin/sh
curl http://127.0.0.1:3311/core.whm?whm_call=info &>/dev/null  > /tmp/kangle-info.xml
echo cat //\$1 | xmllint --shell /tmp/kangle-info.xml | sed '/^\/ >/d' | sed 's/<[^>]*.//g'
rm -f /tmp/kangle-info.xml
END
chmod +x /etc/zabbix/scripts/kangle_status.sh

echo "Setting up Zabbix-agent"
echo "UserParameter=kangle.stat[*],/etc/zabbix/scripts/kangle_status.sh \$1" > /etc/zabbix/zabbix_agentd.d/userparameter_kangle.conf

echo "Restarting Zabbix-agent"
/etc/init.d/zabbix-agent restart
