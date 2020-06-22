# IsieIam_infra
IsieIam Infra repository

## Домашнее задание к лекции №5

### Самостоятельное задание №1:
>Исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства, проверить работоспособность найденного решения и внести его в README.md в вашем репозитории
```
ssh -J appuser@84.201.157.40 appuser@10.130.0.30
```
### Дополнительное задание №1:
>Предложить вариант решения для подключения из консоли при помощи команды вида ssh someinternalhost из локальной консоли рабочего устройства, чтобы подключение выполнялось по алиасу someinternalhost и внести его в README.md в вашем репозитории
- Добавлен config:
```
cat ~/.ssh/config
### The Bastion Host
Host bastion
  HostName 84.201.157.40
  User appuser

### The Remote Host
Host someinternalhost
  HostName 10.130.0.30
  ProxyJump bastion
  User appuser
```
- Команда для подключения к хосту за бастионом через alias:
```
ssh someinternalhost
```

### Дополнительное задание №2:
>С помощью сервисов sslip.io/xip.io и Let’s Encrypt  реализуйте использование валидного сертификата для панели управления VPN-сервера

- dns имя сервера
```
84.201.157.40.sslip.io
```
- в настройках pritunl вкл использование Let's encrypt сертификата

### Задание:
>1. Выполните задание про подключение через бастион хост.
   - Пройден квест с тех поддержкой Ya с созданием платежного аккаунта.
   - Созданы VM.
   - Созданы сертификаты, проверено подключение.
   - Установлен и настроен vpn-server, проверено подключение.
>2. Добавьте в ваш репозиторий Infra (ветка cloud-bastion):
   - добавлен: файл setupvpn.sh (для ubuntu 18.04)
   - добавлен: cloud-bastion.ovpn
>3. Опишите в README.md и получившуюся конфигурацию и данные для подключения в следующем формате (важно для проверки!):

bastion_IP = 84.201.157.40
someinternalhost_IP = 10.130.0.30

## Домашнее задание к лекции №6
Что было сделано:
Создана VM, установлены ruby, mongo и приложение(monolith) с git, проверн запуск.

>впишите данные для подключения в следующем формате (важно для автоматической проверки ДЗ):

testapp_IP = 130.193.39.133
testapp_port = 9292

### Самостоятельное задание:

>Команды по настройке системы и деплоя приложения нужно завернуть в баш скрипты, чтобы не вбивать эти команды вручную:
>Скрипт install_ruby.sh должен содержать команды по установке Ruby;

Добавлен к репо через git add --chmod=+x: install_ruby.sh

>Скрипт install_mongodb.sh должен содержать команды по установке MongoDB:

Добавлен к репо через git add --chmod=+x: install_mongodb.sh

>Скрипт deploy.sh должен содержать команды скачивания кода, установки зависимостей через bundler и запуск приложен:

Добавлен к репо через git add --chmod=+x: deploy.sh

### Дополнительное задание:

изучены:
- https://cloud.yandex.ru/docs/compute/concepts/vm-metadata
- https://cloudinit.readthedocs.io/en/latest/topics/format.html

Сформированы:
- cloud-config config.yml
- script.sh - объединение скриптов выше
- сформирована user-data через команду и скрипт, взятый с cloudinit:
```
./make_mime.py -a config.yaml:cloud-config -a script.sh:x-shellscript > user-data
```
Пересоздана VM с помощью команды yc ниже с использованием созданной user-data(startup_script)

(Для себя для памяти: сами скрипты в user-data можно посмотреть через https://www.base64decode.org)

```
yc compute instance create
--name reddit-app
--hostname reddit-app
--memory=4
--create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB
--network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4
--metadata serial-port-enable=1
--metadata-from-file user-data=startup_script
```
