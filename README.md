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

## Домашнее задание к лекции №7

### Задание:
Что было сделано:
- Установлен packer
- Создан и настроен сервисный account для packer
- Создан и параметризован шаблон packer (ubuntu16.json, variables.json - который добавлен в gitignore + "fantasy" variables)
- Используя шаблон создан образ в облаке (попутно через параметр provisioner pause_before" решена ошибка двух одновременно запускающихся apt)
- Создана через gui VM, запускающая с созданного образа, установлен monolith - проверена работоспособность.

### Дополнительное задание №1:
>Созданный шаблон должен называться immutable.json и содержаться в директории packer, image_family у получившегося
>образа должен быть reddit-full. Дополнительные файлы можно положить в директорию packer/files. Для запуска приложения при
>старте инстанса необходимо использовать systemd unit
- создан immutable.json, который использует те же расширенные variables.json от ubuntu16.json
- изучено создание сервиса для systemd для запуска puma(не с первого раза запустилось, но все получилось, тип сервиса оказался самым важным параметром)
- созданы доп файлы в packer/files:
```
1. deploy.sh - скачивание и установка monolith (+установка парочки доп пакетов и смена root на нужного пользователя)
2. enable_service.sh - установка сервиса в systemd
3. myunit.service - описание сервиса для systemd
4. fantasy_file.txt - выдуманный ключ для variables.json.example
```
- в шаблон добавлены доп provisioners для добавления необходимого файла из /packer/files/ и установки приложения и создания сервиса
- Создан образ с использованием immutable  шаблона.(чтобы не потерять команда для сборки образа: packer build -var-file ./variables.json ./immutable.json)

В результате при создании vm с диском в виде созданного образа получаем сразу запущенный monolith.
(хотя в идеале именно для immutable образа надо допом отключать apt с автозапуска в ОС, иначе при старте он что-нибудь скачает и установит и инфра фактически поменяется)

### Дополнительное задание №2:
>Создайте скрипт create-reddit-vm.sh в директории configscripts, который будет создавать ВМ с помощью Yandex.Cloud CLI.

Создан скрипт config-scripts/create-reddit-vm.sh который создает vm, в качестве boot диска которой используется immutable образ(через семейство образов).
В результате командой создается VM и сразу же имеем уже запущенный monolith.

## Домашнее задание к лекции №8

### Задание:
Что было сделано:
- Установлен terraform
- Сформированы необходимые файлы: main.tf, outputs.tf, variables.tf, terraform.tfvars
- Добавлены provisioners и доп файлы для установки сервиса puma.
- Указаны input, output переменные.
- проверена работоспособность.

( Чтобы не искать: команда для просмотра id образа: yc compute image list )

### Самостоятельное задание №1:
>Определите input переменную для приватного ключа, использующегося в определении подключения для провижинеров (connection);

Добавлена переменная для приватного ключа: в variables.tf (variable private_key_path) и её значение в terraform.tfvars (private_key_path)

>Определите input переменную для задания зоны в ресурсе "yandex_compute_instance" "app". У нее должно быть значение по умолчанию;

Добавлена зона с ссылкой на перменную в main.tf(vm_zone), аналогично заданию выше занесена в variables.tf и в terrafrom.tvars
```
resource "yandex_compute_instance" "app" {
  name = "reddit-app"
  zone = var.vm_zone
...
}
```
>Отформатируйте все конфигурационные файлы используя команду terraform fmt;

Выполнено.

>Так как в репозиторий не попадет ваш terraform.tfvars, то нужно сделать рядом файл terraform.tfvars.example, в котором будут указаны переменные для образца.

Создан файл terraform.tfvars.example с выдуманными значениями.

### Задание с **:
> Создайте файл lb.tf и опишите в нем в коде terraform создание HTTP балансировщика, направляющего трафик на наше развернутое приложение на инстансе reddit-app. Проверьте доступность приложения по адресу балансировщика. Добавьте в output переменные адрес балансировщика.

Создан файл в 1 хостовом варианте с ссылкой на yandex_compute_instance.app.network_interface.0.ip_address.
Но с >1 хостом не интересно, поэтому:

- Было изучено динамическое формирование блоков: https://www.hashicorp.com/blog/hashicorp-terraform-0-12-preview-for-and-for-each/
- И применено, в результате файл lb.tf изменился - target-ы с ip адресами генерируются по общему кол-во compute instance-ов.
- В output добавлен вывод ip балансера.

>Добавьте в код еще один terraform ресурс для нового инстанса приложения, например reddit-app2, добавьте его в балансировщик и проверьте, что при остановке на одном из инстансов приложения (например systemctl stop puma), приложение продолжает быть доступным по адресу балансировщика; Добавьте в output переменные адрес второго инстанса; Какие проблемы вы видите в такой конфигурации приложения? Добавьте описание в README.md.

СОздан отдельный ресурс под второй инстанс, но да ручное копирование полного ресурса - не эффективно, минусы:

- есть вероятность ошибки при внесении изменений - надо везде поправить или если копировать файлами(ресурс на каждую VM в отдельных файлах)
- неэффективная система масштабирования - руками или автоматизация доп "костылями"
- общий минус - не только этого варианта, но и следующего - это разная data у mongo - нет синхронизации.

Вывод ip второго хоста в output закоменчен в силу ненадобности/неактуальности с более интересным вариантом далее:

>Как мы видим, подход с созданием доп. инстанса копированием кода выглядит нерационально, т.к. копируется много кода. Удалите описание reddit-app2 и попробуйте подход с заданием количества инстансов через параметр ресурса count. Переменная count должна задаваться в параметрах и по умолчанию равна 1

Изначально из-за ошибки с циклом с этой задачкой думал нереально без использования full образа(т.е. без connection и без provisioner), спс Максиму показал, что я пропустил.

В результате файл main подправлен на использование self в указании host для connection и это работает.

В output переменные  добавлен динамический вывод id, ip VM, для примера:
```
Outputs:

external_ip_address_app = [
  "fhmfd23rppmk4ekvhgve = 130.193.50.241",
  "fhmc1q7n3tp31kk2h1pu = 84.201.131.190",
]
lb_ip_address = 130.193.51.142
```

Бонусом пошло изучение instance group и под них были созданы lb.tf.old и ig.tf.old
