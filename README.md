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

