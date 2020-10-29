## Оглавление
0. [Backup-DropBox](#Backup-DropBox)
1. [install-dante](#install-dante)

# Backup-DropBox
This is a small bash script to backup a single file to dropbox

## setup / create dropbox app

Visit https://www.dropbox.com/developers/apps/create and choose the following 

- Dropbox API
- App folder– Access to a single folder created specifically for your app.
- Name: "My Backup"

On the next step on the app's settings generate Access Token 

## Usage 

Make sure you give execute rights to the script 

```
chmod +x backup.sh
```

Add your Access Token inside the bash script and call the script as follows

```
./backup.sh file.zip
```

You should see the `file.zip` in Dropbox `APPS > My Backup > backup` folder





# install-dante
Быстрая установка Dante на базе Ubuntu для запуска собственного Socks5-прокси.

### Предисловие
Для установки и быстрого запуска, вам необходимы лишь прямые руки и собственный сервер (любой конфигурации) на базе Ubuntu 16/18.04 с выделенным IP или NAT-портом. Делайте всё по пунктам и вы получите свой прокси, формата Socks5, всего за 5 минут (*буквально, без шуток*).

### Отказ от ответственности
Автор не несёт никакой ответственности за моральный ущерб при установке, порчу/уничтожение/неработоспособность вашего виртуального/выделенного сервера. Материал предоставляется по формату *"как есть"*.

## Установка

1. `sudo apt-get -y update && sudo apt-get -y upgrade`
2. `sudo apt-get -y install libwrap0-dev libpam0g-dev libkrb5-dev libsasl2-dev`
3. `sudo apt-get -y install build-essential && sudo apt-get -y install dante-server`
4. Сразу после запуска 3-й команды, вы увидите ошибку, что Dante "не может быть запущен". Проблема легко решается путём создания (если отсутствует) или изменения файла `danted.conf` (расположенного по адресу `/etc/danted.conf`).

Создайте или откройте файл, используя любой текстовый редактор и вставьте туда следующий конфиг:

```
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
```

5. Сразу после настройки `danted.conf`, запустите следующую команду `sudo useradd -m proxyuser && sudo passwd proxyuser`. Вам будет предложено установить собственный пароль, который будет использоваться для подключения к прокси-серверу (рекомендуется, если прокси будет использоваться в личных целях).
6. Укажите свой пароль *дважды* и запустите команду `service danted start && service danted status`
7. *После успешного запуска Dante, вам будет возвращён статус `active` зелёным цветом*. Это значит, что сервер уже запущен и готов к использованию.


## Подключение
Если вы не меняли конфиг выше, то ниже указана форма с данными для подключения:

* IP: `адресс вашего (IPv4)`
* Порт: `12345`
* Юзер: `proxyuser`
* Пароль: `указанный вами пароль в пункте 5`

### Ремарка (авторизация и NAT)

* Авторизацию через логин и пароль рекомендуется использовать, если вы не планируете публиковать или делится данными для подключения к прокси-серверу с другими людьми (чисто "под себя и для себя"). Если вы хотите запустить ПУБЛИЧНЫЙ прокси, то замените `method: username` на `method: none`. Тогда, вы можете пропустить 5-ый пункт установки, и перейти сразу к 6-ому.
* Если вы экономите и пользуетесь NAT-серверами, то можете просто сменить значение `12345` в поле `internal: eth0 port = 12345` на любое другое (например: доступные вам порты на NAT-сервере). Dante запустится без особых проблем.


### Нужен прокси для Телеграма?
Воспользуйтесь бесплатным MTProto-прокси:
<br>
* [Подключиться сейчас](https://mtproto.org)
