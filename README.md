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

---------

#### 8. "Практика Infrastructure as a Code (IaC)."

В ходе самостоятельной работы к данному занятию, был создан каталог `terraform` содержащий в себе файлы необходимые для управления инфраструктурой при помощи terraform, применяя подход "IaC"

Был создан основной файл, описывающий наш сервер - `main.tf`
Для указания используемых переменных, используется файл - `variables.tf`
Сами переменные указывается в файле - `terraform.tfvars`
Т.к. мы не хотим открывать общий доступ к этому файлу, мы указали его в файле `.gitignore`, но при этом оставили в каталоге `terraform` файл-пример `terraform.tfvars.example`, в котором в общем виде показано каким должен быть файл `terraform.tfvars`

Основные команды утилиты `terraform` (запускать из каталога где находится основной файл конфигурации terraform):

Для проверки что будет выполнено:

    terraform plan

Для примерения параметров:

    terraform apply

Для удаления объектов описанных данной конфигурацией:

    terraform destroy


---------


#### 9. "Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform."

В ходе самостоятельной работы к данному занятию, был изучен модульный подход к инфраструктуре terraform.

С помощью Packer были созданы новые образы VM - `reddit-app-base-1562523004` и `reddit-db-1562522781`, для сервера приложений и сервера БД соответственно.

Дальнейшее описание путей к файлам, соответствует при нахождении в каталоге `./terraform`

Были созданы следующие модули:
1. app - модуль для приложения reddit - файл `modules/app/main.tf`
2. db - модуль для БД MongoDB - файл `modules/db/main.tf`
3. vpc - модуль для Firewall открывающий доступ для SSH - файл `modules/vpc/main.tf`

Были созданы 2 окружения "stage" и "prod". Конфигурации окружений находятся в каталогах `stage` и `prod`. В обоих случаях идет переиспользование ранее созданных модулей, при этом в среде "prod" добавлено ограничение по входящему IP для SSH подключения.

Также был добавлен внешний модуль "storage-bucket", для создания бакета в сервисе Storage. Файл конфигурации - `storage-bucket.tf`
    terraform destroy


---------


#### 10. "Управление конфигурацией."
При выполнении комманды `ansible app -m command -a 'rm -rf~/reddit'` было выполнено удаление каталога `~/reddit`.
В связи с этим, при выполнении `ansible-playbook clone.yml`, было выполнено клонирование git-репозитория, со следующим выводом:

    TASK [Clone repo] ***************************************
    changed: [appserver]
    
    PLAY RECAP **********************************************
    appserver                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

`ok=2    changed=1` означает что было выполнено изменение.

При попытки повторного запуска `ansible-playbook clone.yml` мы получим следующий результат:

    TASK [Clone repo] ***************************************
    ok: [appserver]
    
    PLAY RECAP **********************************************
    appserver                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 

`ok=2    changed=0` означает что задание выполенено успешно, при этом никаких действий на удаленном сервере для этого выполнено не было.


#### 11. "Продолжение знакомства с Ansible: templates, handlers, dynamic inventory, vault, tags."
В ходе задания, были созданы различные плейбуки. Было создан сценарий описывающий все действия (`reddit_app_one_play.yml`), но он оказался не удобным т.к. для указания что-нужно установить на какой сервер небходимо указывать через `--limit` к какому хосту применять условия.
Также был создан `reddit_app_multiple_plays.yml`, но у него присутствует аналогичная проблема. В данном случае разделение происходит засчет 'tags'.
В конечном итоге было выполнено разделение раз отдельные плейбуки `app.yml`, `db.yml` и `deploy.yml` каждый из которых выполняет свою конкретную функцию. Для их объединения был создан плейбук - `site.yml`, который содержит в себе импорт всех остальный плейбуков.

Также, в ходе задания были созданы новые образы через 'Packer' с измененными параметрами 'provisioners', в которых был заменен Bash-скрипт на Ansible.

