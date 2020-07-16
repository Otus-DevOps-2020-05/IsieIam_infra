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

Создан файл lb.tf в 1 хостовом варианте с ссылкой на
```
yandex_compute_instance.app.network_interface.0.ip_address
```

Но с >1 хостом явно перечислять target не интересно, поэтому:

- Было изучено динамическое формирование блоков: https://www.hashicorp.com/blog/hashicorp-terraform-0-12-preview-for-and-for-each/
- И применено, в результате файл lb.tf изменился - target-ы с ip адресами генерируются по общему кол-во compute instance-ов.
- В output добавлен вывод ip балансера.

>Добавьте в код еще один terraform ресурс для нового инстанса приложения, например reddit-app2, добавьте его в балансировщик и проверьте, что при остановке на одном из инстансов приложения (например systemctl stop puma), приложение продолжает быть доступным по адресу балансировщика; Добавьте в output переменные адрес второго инстанса; Какие проблемы вы видите в такой конфигурации приложения? Добавьте описание в README.md.

СОздан отдельный ресурс под второй инстанс, но да ручное копирование полного ресурса - не эффективно, минусы:

- есть вероятность ошибки при внесении изменений - надо везде поправить или если копировать файлами(ресурс на каждую VM в отдельных файлах), то
- неэффективная система масштабирования - руками или автоматизация доп "костылями"
- общий минус - не только этого варианта, но и следующего - это разная data у mongo - нет синхронизации (т.е. в идеале надо из бд кластер тоже собрать)

Вывод ip второго хоста в output закоменчен в силу ненадобности/неактуальности по сравнению с более интересным вариантом далее:

>Как мы видим, подход с созданием доп. инстанса копированием кода выглядит нерационально, т.к. копируется много кода. Удалите описание reddit-app2 и попробуйте подход с заданием количества инстансов через параметр ресурса count. Переменная count должна задаваться в параметрах и по умолчанию равна 1

Изначально из-за ошибки с циклом с этой задачкой думал нереально без использования full образа(т.е. без connection и без provisioner), спс Максиму показал, что я пропустил.

В результате в файл main добавлен count у resource c VM(смотрящий на input переменную), host в connection подправлен на использование self для получения ip.

В output переменные  добавлен форматированный вывод id, ext-ip, int-ip VM, для примера:
```
Outputs:

App_ip_address = [
  "id = fhme1s8q6o5i2bvnhpde: ext ip = 130.193.50.218, int ip = 10.130.0.35",
  "id = fhmg6gj7pjkm00jupn2b: ext ip = 130.193.49.167, int ip = 10.130.0.28",
]
```

Бонусом пошло изучение instance group и под них были созданы lb.tf.old и ig.tf.old

## Домашнее задание к лекции №10

### Задание:
Что было сделано:
- Изучена, проверена на практике зависимость ресурсов тераформа.
- Конфигурация терраформа разбита на app, db, net.
- Изучены и опробованы на практике процессы создание и использование модулей, причем с зависимостями одних модулей от параметров других.
В частности: созданы модули: app, db, и "невидимый" модуль vpc(vpc не параметризовал, т.к. общий принцип уже понятен :))
- Созданы отельно конфигурации тераформа для stage и прома.

### Самостоятельное задание №1:
```
1. Удалите из папки terraform файлы main.tf, outputs.tf, terraform.tfvars, variables.tf, так как они теперь перенесены в stage и prod
```

Выполнено.
```
2. Параметризируйте конфигурацию модулей насколько считаете нужным
```

Выполнено: добавлена параметризация "железных" ресурсов инстансов, а также имени с тегом.
```
3. Отформатируйте конфигурационные файлы, используя команду terraform fmt
```

Выполнено.

### Задание с *:

>1. Настройте хранение стейт файла в удаленном бекенде (remote backends) для окружений stage и prod, используя Yandex Object Storage в качестве бекенда. Описание бекенда нужно вынести в отдельный файл backend.tf

Создан бакет(через gui), увы создать его в этом же описании инфраструктуры терраформа нельзя - он не может инициализироваться, бакета еще нет, а он уже нужен.

Создан backend s3(см prod/backend.tf), ключи доступа вынесены в переменные окружения provider, как описано здесь:
https://www.terraform.io/docs/providers/yandex/index.html
```
export AWS_ACCESS_KEY_ID="O..N"
export AWS_SECRET_ACCESS_KEY="t..n"
```
Добавлены skip в настройки бекенда согласно рекомендациям yandex(иначе ошибка с проверкой account_id).

(Также, простым указанием storage input переменных в описании provider создать backend так и не получилось - он их просто не видит(хотя документация говорит что должно работать)).

Проверен результат: если попробовать выполнить любую команду terraform(apply, plan) после добавления backend, то он просит переинцилизроваться и в случае успеха реинициализации - state файл уже локально не появляется, а хранится и используется в бакете.

>2. Перенесите конфигурационные файлы Terraform в другую директорию (вне репозитория). Проверьте, что state-файл (terraform.tfstate) отсутствует. Запустите Terraform в обеих директориях и проконтролируйте, что он "видит" текущее состояние независимо от директории, в которой запускается

Скопировал директорию prod, modules в другой каталог, terraform show показывает актуальный статус из обеих диеркторий.
State файлов уже нет локально.

>3. Попробуйте запустить применение конфигурации одновременно, чтобы проверить работу блокировок

Каких-то проблем со стороны бакета не увидел, а вот ресурcы оно ни создать, ни удалить одновременно не может:
- При создании:

Error: Error while requesting API to create instance: server-request-id = 6790295b-c573-ba84-94ae-dc4b29e5e2d5 server-trace-id = 6695a14fe5809b12:8a156820ac70e968:6695a14fe5809b12:1 client-request-id = 695eadf5-faff-4a22-99ba-bd9abb1a836f client-trace-id = 37c5c0eb-fb6d-4228-bc6c-5873d36f6275 rpc error: code = AlreadyExists desc = Instance with such name already exists.

- При удалении:

Error: error reading Subnet "app-subnet": server-request-id = 10b9cc82-e9c4-b5da-9ac1-21df13a44d90 server-trace-id = fac2ba51de23abe4:7919dd1867f2ed61:fac2ba51de23abe4:1 client-request-id = 0e457816-a5a9-4c38-88fc-983d460ef415 client-trace-id = e4f1fd22-8f28-46db-b000-f4db4595cfc6 rpc error: code = FailedPrecondition desc = Invalid subnet state

Чтобы включить систему блокировок aws ресурс требует dynamo-db table:
https://www.terraform.io/docs/backends/types/s3.html#dynamodb_table

Только у yandex облака по ходу такой фичи нет, по крайней мере нигде в их документации про это не указано:
https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-state-storage

В backend.tf попробовал создать таблицу с dynamodb, но тогда нужен провайдер aws, но общий принцип понятен в принципе и цель тоже.

>4. Добавьте описание в README.md

Выполнено.

### Задание с **:

>В процессе перехода от конфигурации, созданной в предыдущем ДЗ к модулям мы перестали использовать provisioner для деплоя приложения. Соответственно, инстансы поднимаются без приложения.

>1. Добавьте необходимые provisioner в модули для деплоя и работы приложения. Файлы, используемые в provisioner, должны находится в директории модуля.
- Добавлены Provisioner в main.tf модулей через отдельный null ресурс, чтобы можно было воспользоваться "хаком" c count для включения/выключения ресурса, пример:
```
resource "null_resource" "app" {
  count = var.install_enable ? 1 : 0
  connection {...}
  provisioner "file" {...}
...
}
```
- Добавлен provisioner-ы для app: деплоит monolith(используются те же доп файлы из пред задания: deploy.sh и файл сервиса, скопированные в каталог модуля, скорректированы пути в модуле к ним), выставляет в переменную окружения внутренний ip БД, который берется как параметр в конфигурации.
- Добавлен provisioner для DB: который через sed меняет ip binding у mongo(разрешает подключение, помимо localhost, для ip инстанса БД, который берется из переменной) и перезапускает её.
- Добавлены все необходимые input переменные.

>2. Опционально можете реализовать отключение provisioner в зависимости от значения переменной

Реализовано через доп переменные и null ресурс:
- install_app_enable, install_db_enable - входные для основной конфигурации
- install_enable для модулей - входные параметры для модулей

Проверено - все работает как ожидалось :)

>3. Добавьте описание в README.md

Описание добавлено.

## Домашнее задание к лекции №11 (Управление конфигурацией. Знакомство с Ansible )

### Задание:
Что было сделано:
 - установлен python,pip и сам ansible через pip.
 - созданы базовые inventory(ini,yml) и проверено выполнение различных команд через модули ansible (ping, command, shell и пр.).
 - проверена на практике работа с модулем ansible git
 - проверена работа с группами хостов.
 - проверен в работе ansible-playbook clone.

По поводу вопроса с rm -rf: волшебство в том, что на хосте уже есть каталог reddit и при первом выполнении команда выполнилась, но ничего не изменилось:  changed = 0:
```
PLAY RECAP *********************************************************************************************
appserver                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Далее мы удаляем каталог через rm -rf и выполняем плейбук еще раз, а т.к. каталога нет, то он создается и данные клонируются(т.е. изменения по факту произошли), соответственно видим, что changed = 1:
```
PLAY RECAP *********************************************************************************************
appserver                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### Задание с *:

>1. Ознакомьтесь с документацией на формат JSON для динамического инвентори

Изучено:
- https://medium.com/@Nklya/динамическое-инвентори-в-ansible-9ee880d540d6
- https://docs.ansible.com/ansible/latest/dev_guide/developing_inventory.html#developing-inventory

>2. Создайте файл inventory.json в формате, описанном в п.1 для нашей GCP-инфраструктуры и скрипт для работы с ним.

- Создан файл ansible/inventory.json в формате из описания: https://docs.ansible.com/ansible/latest/dev_guide/developing_inventory.html#inventory-script-conventions
- А также создан файл ansible/get_inventory.sh - который просто делает cat inventory.json всегда(т.е. и при входном параметре --list, который требуется по документации)
- sh файл добавлен в дефолтное инвентори в конфиге ansible.

```
inventory = ./get_inventory.sh
```

>(реализовывать api YC даже для простого получения инфо об инстансах - я буду долго :), к тому же это будет всего одна команда и с учетом наличия https://github.com/rodion-goritskov/yacloud_compute и пр. готовых плагинов - это точно не эффективно).

>3. Добейтесь успешного выполнения команды ansible all -m ping и опишите шаги в README .

С подготовленными файлами выше, работает:
```
пинг хостов через скрипт:
$ ansible all -m ping
130.193.36.65 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
130.193.36.248 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}

----------------
список хостов через скрипт:
$ ansible --list-hosts all
  hosts (2):
    130.193.36.248
    130.193.36.65
```
>4. Добавьте параметры в файл ansible.cfg для работы с инвентори в формате JSON.

Здесь не совсем понятно: каких-то специальных параметров нет, кроме как указания откуда брать inventory.
Ansible сам на ходу может определять какой формат инвентори пришел ему на вход(используются дефолтные значения из настройки: https://docs.ansible.com/ansible/latest/reference_appendices/config.html#inventory-enabled),
а yml плагин умеет читать json: https://docs.ansible.com/ansible/latest/plugins/inventory/yaml.html

На практике:

- инвентори в формате "json из yml" ansible парсит без каких-либо доп параметров :) )
- Если попробовать и попытаться json c динамическим инвентори отдать просто так, то будет ошибка след вида(видно что ошибку выдал yml плагин):
```
[WARNING]:  * Failed to parse ansiblee/inventory.json with yaml plugin: Invalid "hosts" entry for "app" group, requires a dictionary, found "<type 'list'>" instead.
```

>5. Если вы разобрались с отличиями схем JSON для динамического и статического инвентори, также добавьте описание в README:

- Описание формата json для динамического инвентори: https://docs.ansible.com/ansible/latest/dev_guide/developing_inventory.html#inventory-script-conventions
- Json для статического получается простым конвертированием yml2json

В качестве примера можно посмотреть в файлах:
 - Формат(немного упрощенный) динамического: inventory.json
 - Формат статического: yml_inventory.json

При запросе списка хостов оба работают(ip могут быть не актуальны):
```
$ ansible --list-hosts all
  hosts (2):
    130.193.36.248
    130.193.36.65
$ ansible --list-hosts all -i ./yml_inventory.json
  hosts (2):
    dbserver
    appserver
```

## Домашнее задание к лекции №12 (Продолжение знакомства с Ansible: templates, handlers, dynamic inventory, vault, tags)

### Задание:
Что было сделано:
 - Написан и проверен на практике playbook(reddit_app.yml) с одним сценарием для установки всего необходимого по на app, db сервера, а также деплой самого приложения.
 - добавлен в плейбук модуль apt (установку git то где-то потеряли на app ...)
 - опробована работа ansible templates, vars, handlers, tags и работа limits
```
чтобы не забыть формат запуска с лимитам и тегами
ansible-playbook reddit_app.yml --limit db  --tags db-tag
ansible-playbook reddit_app.yml --limit app --tags app-tag
ansible-playbook reddit_app.yml --limit app --tags deploy-tag
```
 - Реализован чуть более продвинутый вариант вариант playbook(reddit_app2.yml), когда в одном плейбуке отдельные сценарии для app, db и деплоя разбитые по тегам.
 - Реализован вариант с 3 разными playbook-ами: установка на app(app.yml), установка db(db.yml) и отдельно деплой приложения(deploy.yml).
 - Изучен и опробован import плейбуков(site.yml)
 - Вместе с этим изучены настройки основных модулей.

### Самостоятельное задание:

>Опишите с помощью модулей Ansible в плейбуках ansible/packer_app.yml и ansible/packer_db.yml действия, аналогичные bash-скриптам, которые сейчас используются в нашей конфигурации Packer.

 - Написаны: ansible/packer_app.yml и ansible/packer_db.yml
 - исправлены packer/app.json и packer/db.json
 - проверена работоспособность, все работает, но с доработками :)
 - Подправлены provisioner в packer, команда для запуска packer(чтобы не искать):
```
packer build -var-file packer/variables.json packer/app.json
packer build -var-file packer/variables.json packer/db.json
```
 - Изучен модуль apt(установка пакетов, update_cache): циклы в apt модуле отныне deprecated:

```
    yandex: TASK [Install ruby with addons] ************************************************
    yandex: [DEPRECATION WARNING]: Invoking "apt" only once while using a loop via
    yandex: squash_actions is deprecated. Instead of using a loop to supply multiple items
    yandex: and specifying `name: "{{ item }}"`, please use `name: ['ruby-full', 'ruby-
    yandex: bundler', 'build-essential']` and remove the loop. This feature will be removed
    yandex:  in version 2.11. Deprecation warnings can be disabled by setting
    yandex: deprecation_warnings=False in ansible.cfg.
```
 - вместо цикла рекомендуют делать след образом:
```
 apt:
      name: ['ruby-full', 'ruby-bundler', 'build-essential']
```
 - добавлена обработка блокировки dpkg на старте образа(shell остается - более красивого решения не нашёл):
```
  # обходим проблему блокировки dpkg
  - name: Wait for /var/lib/dpkg/lock-frontend to be released
    shell: while lsof /var/lib/dpkg/lock-frontend ; do sleep 10; done;
```
 - Опробован модуль apt_key, apt_repository

### Задание с *:

>Исследуйте возможности использования dynamic inventory для GCP (для этого есть не только gce.py ).

 - С gcp как-то не очень, т.к. вся практика была на yandex cloud, поэтому поискал варианты для YC, но ничего не понравилось :), поэтому:
 - в дополнение к пред дз - реализовано более честное dynamic inventory с ya cloud - get_inventory.py:
```
- создается токен для yandex api
- выбирается id облака из уз (пока ограничение что облако у уз одно)
- далее по имени каталога получается его id
- и собирается inventory
- для текущего задания добавляются в inventory доп переменные: internal_ip
- увы, много хардкода, но все-таки цель была не написать полноценной скрипт для inventory под YC :)
```
 - изменены playbook только для 3 случая: когда все playbook разделены(убраны переменные в playbook).
 - в template добавлено использование переменных из inventory hostvars (пока считаем что у нас БД одна и больше хостов быть не может :))

В качестве результата после запуска terraform apply, достаточно запустить ansible-playbook site.yml, ничего редактировать в переменных не надо и все запустится.
