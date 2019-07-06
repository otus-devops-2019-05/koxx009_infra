# koxx009_infra

## Домашние задания
### Задание к занятию:
------------
#### 5. "Знакомство с облачной инфраструктурой и облачными сервисами."
- ##### Подключение в одну строку

Команда для подключения в одну строку необходимо выполнить команду:
	`ssh -At koxx009@$EXP_IP_BASTION 'ssh $INT_IP_SOMEINTERNALHOST'`

Следует отменить, что в CentOS 7 для корректной работы SSH Forwarding необходимо выполнить следующие команды:
```bash
# eval `ssh-agent -s`
Agent pid 18042
# ssh-add ~/.ssh/id_rsa
Identity added: /root/.ssh/id_rsa (/root/.ssh/id_rsa)
```

Без выполнения данных команд, при попытки подключиться будет выведен ответ о неудачном подключении:
```bash
# ssh -At koxx009@$EXP_IP_BASTION 'ssh $INT_IP_SOMEINTERNALHOST'
Permission denied (publickey).
Connection to $EXP_IP_BASTION closed.
```

- ##### Подключение по алиасу someinternalhost

Как вариант, можно использовать переменные. Команда для подключения будет выглядеть следующим образом:
```bash
# export someinternalhost='-A -J koxx009@35.207.163.99 koxx009@10.156.0.3'
# ssh $someinternalhost
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.15.0-1034-gcp x86_64)
koxx009@someinternalhost:~$
```
**UPD:**
Более корректный способ:
Необходимо отредактировать файл `/etc/ssh/ssh_config`, добавив в конец следующие строки:

```bash
Host someinternalhost
        IdentityFile ~/.ssh/id_pub
        User koxx009
        Hostname 10.156.0.3
        ProxyJump koxx009@35.207.163.99
```

- ##### Настройка VPN через Pritunl
Данные для подключения:

bastion_IP = 35.207.163.99
someinternalhost_IP = 10.156.0.3


---------

#### 6. "Основные сервисы Google Cloud Platform (GCP)."

Данные для подключения:

    testapp_IP = 35.246.205.229
    testapp_port = 9292

##### Дополнительные задания:
* Startup script для автоматической установки и запуска приложения

Для этого был создан файл  `startup-script.sh`:

    #!/bin/bash
    
    # Installing Ruby
    sudo apt update
    sudo apt install -y ruby-full ruby-bundler build-essential
    
    # Installing MongoDB
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
    sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
    sudo apt update
    sudo apt install -y mongodb-org
    
    # Starting MongoDB
    sudo systemctl start mongod
    
    # Enable autostart MongoDB
    sudo systemctl enable mongod
    
    # Cloning app
    cd ~
    git clone -b monolith https://github.com/express42/reddit.git
    
    # Starting app
    cd reddit
    bundle install
    puma -d
    

Команда для создания инстанса с запуском  `startup-script.sh`:

    gcloud compute instances create reddit-app-2 \
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --restart-on-failure \
    --metadata-from-file startup-script=startup-script.sh

* Создание Firewall правила через gcloud

Удаление текущего правила:

    gcloud compute firewall-rules delete default-puma-server


Добавление нового правила через gcloud:

    gcloud compute firewall-rules create default-puma-server \
    --allow tcp:9292 \
    --target-tags=puma-server \
    --source-ranges="0.0.0.0/0" \
    --description="Puma http access"
    

---------

#### 7. "Модели управления инфраструктурой."

В ходе самостоятельной работы к данному занятию, был создан каталог `packer` содержащий в себе параметры для создания образов VM при помощи packer.

Был создан файл шаблона VM - `ubuntu16.json`
Переменные для этого шаблона находятся в файле - `variables.json`
Образец файла с переменными - `variables.json.example`


Для проверки корректности шаблона, следует выполнить следующую команду в каталоге с шаблоном:

    packer validate -var-file=variables.json ./ubuntu16.json


