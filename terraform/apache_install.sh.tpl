#!/bin/bash
sudo apt-get -y update && sudo apt-get -y upgrade

sudo apt-get -y install apache2

sudo systemctl enable apache2



echo <<EOF "<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AuditSoft Test Page</title>
    <style>
        body,
        html {
            height: 100%;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: #f0f0f0;
        }

        .centered-content {
            font-size: 48px;
            font-family: Arial, sans-serif;
            color: #333333;
        }
    </style>
</head>

<body>
    <div class="centered-content">
        auditsoft_test
    </div>
</body>

</html>"  > /var/www/html/index.html
EOF



for i in 1 2 3; do
    # Создаем пользователя с именем user$i (где $i - номер итерации)
    useradd -m -s /bin/bash "user$i"

    # Создаем директорию для настроек SSH, если она еще не существует
    mkdir -p /home/user$i/.ssh

    # Добавляем публичный ключ в authorized_keys
    case $i in
        1) echo "${public_key_contents[0]}" >> /home/user$i/.ssh/authorized_keys ;;
        2) echo "${public_key_contents[1]}" >> /home/user$i/.ssh/authorized_keys ;;
        3) echo "${public_key_contents[2]}" >> /home/user$i/.ssh/authorized_keys ;;
    esac

    # Устанавливаем правильные разрешения для директории и файла
    chmod 700 /home/user$i/.ssh
    chmod 600 /home/user$i/.ssh/authorized_keys

    # Меняем владельца директории и файла на созданного пользователя
    chown -R user$i:user$i /home/user$i/.ssh
done