#!/bin/bash
echo "Создание Squid прокси"
# get the VPS IP
ip=`ifconfig eth0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
 
echo
echo "установка и настройка Squid"
apt-get update
apt-get install squid3
 
echo
echo "Создание конфигурации сервера"
cat > /etc/squid/squid.conf <<END
acl SSL_ports port 443
acl Safe_ports port 80 # http
acl Safe_ports port 21 # ftp
acl Safe_ports port 443 # https
acl Safe_ports port 70 # gopher
acl Safe_ports port 210 # wais
acl Safe_ports port 1025-65535 # unregistered ports
acl Safe_ports port 280 # http-mgmt
acl Safe_ports port 488 # gss-http
acl Safe_ports port 591 # filemaker
acl Safe_ports port 777 # multiling http
acl CONNECT method CONNECT
http_access allow all
http_port 3128
coredump_dir /var/spool/squid3
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern (Release|Packages(.gz)*)$ 0 20% 2880
refresh_pattern . 0 20% 4320
END


echo
echo "Переадресация IPv4 и добавление этого в автозагрузку"
cat >> /etc/sysctl.conf <<END
net.ipv4.ip_forward=1
END
sysctl -p
 
echo
echo "Обновление IPtables Routing и добавление этого в автозагрузку"
iptables -t nat -A POSTROUTING -j SNAT --to $ip
# saves iptables routing rules and enables them on-boot
iptables-save > /etc/iptables.conf
echo
echo "Перезапуск Squid"
service squid3 restart
 
echo
echo "Настройка вашего собственного VPN завершена!"
echo "Ваш IP: $ip"