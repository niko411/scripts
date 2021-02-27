#!/bin/bash
echo "Выберите, что вы хотите сделать:"
echo "1) Настроить новый dante VPN сервер И создать нового пользователя"
echo "2) Создать дополнительных пользователей (к уже существующему VPN)"
read x
if test $x -eq 1; then
    echo "Введите имя пользователя, которое нужно создать (н.п.. client1 or john):"
    read u
    echo "Введите пароль для этого пользователя:"
    read p
 
echo
echo "установка и настройка dante-server"
sudo apt-get -y update && sudo apt-get -y upgrade
sudo apt-get -y install libwrap0-dev libpam0g-dev libkrb5-dev libsasl2-dev
sudo apt-get -y install build-essential && sudo apt-get -y install dante-server
 
echo
echo "Создание конфигурации сервера"
cat > /etc/danted.conf <<END
logoutput: /var/log/socks.log

internal: eth0 port = 12345
external: eth0

method: username
user.privileged: root
user.notprivileged: nobody

client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: error connect disconnect
}
client block {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect error
}
pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: error connect disconnect
}
block {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect error
}
END

sudo useradd -m $u
(echo $p; echo $p) | passwd $u
service danted restart
 
# runs this if option 2 is selected
elif test $x -eq 2; then
    echo "Введите имя пользователя для создания (eg. client1 or john):"
    read u
    echo "введите пароль для создаваемого пользователя:"
    read p
 
 
# adding new user
sudo useradd -m $u
(echo $p; echo $p) | passwd $u
 
echo
echo "Дополнительный пользователь создан!"
echo "Имя пользователя (логин):$u ##### Пароль: $p"
service danted restart
else
echo "Неправильный выбор, выход из программы..."
exit
fi
