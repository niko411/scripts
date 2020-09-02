#!/bin/bash
echo "Выберите, что вы хотите сделать:"
echo "1) Настроить новый PoPToP VPN сервер И создать нового пользователя"
echo "2) Создать дополнительных пользователей (к уже существующему VPN)"
read x
if test $x -eq 1; then
    echo "Введите имя пользователя, которое нужно создать (н.п.. client1 or john):"
    read u
    echo "Введите пароль для этого пользователя:"
    read p
 
# get the VPS IP
ip=`ifconfig eth0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
 
echo
echo "установка и настройка PoPToP"
apt-get update
apt-get install pptpd
 
echo
echo "Создание конфигурации сервера"
cat > /etc/ppp/pptpd-options <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
nodefaultroute
lock
nobsdcomp
END
 
# setting up pptpd.conf
echo "option /etc/ppp/pptpd-options" > /etc/pptpd.conf
echo "logwtmp" >> /etc/pptpd.conf
echo "localip $ip" >> /etc/pptpd.conf
echo "remoteip 10.1.0.1-100" >> /etc/pptpd.conf
 
# adding new user
echo "$u    *   $p  *" >> /etc/ppp/chap-secrets
 
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
 
cat > /etc/network/if-pre-up.d/iptables <<END
#!/bin/sh
iptables-restore < /etc/iptables.conf
END
 
chmod +x /etc/network/if-pre-up.d/iptables
cat >> /etc/ppp/ip-up <<END
ifconfig ppp0 mtu 1400
END
 
echo
echo "Перезапуск PoPToP"
/etc/init.d/pptpd restart
 
echo
echo "Настройка вашего собственного VPN завершена!"
echo "Ваш IP: $ip? логин и пароль:"
echo "Имя пользователя (логин):$u ##### Пароль: $p"
 
# runs this if option 2 is selected
elif test $x -eq 2; then
    echo "Введите имя пользователя для создания (eg. client1 or john):"
    read u
    echo "введите пароль для создаваемого пользователя:"
    read p
 
# get the VPS IP
ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
 
# adding new user
echo "$u    *   $p  *" >> /etc/ppp/chap-secrets
 
echo
echo "Дополнительный пользователь создан!"
echo "IP сервера: $ip, данные для доступа:"
echo "Имя пользователя (логин):$u ##### Пароль: $p"
 
else
echo "Неправильный выбор, выход из программы..."
exit
fi
