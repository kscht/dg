# VSCode в Docker

Этот проект предоставляет VSCode в контейнере Docker с настроенной русской локализацией и дополнительными инструментами разработки.

## Требования

- Docker
- Make
- sudo (для Linux)

## Установка

1. Клонируйте репозиторий:
```bash
git clone <url-репозитория>
cd <директория-проекта>
```

2. Настройте параметры в файле `settings.env`:
- Измените пароли (`PASSWORD` и `SUDO_PASSWORD`)
- При необходимости измените порт (`PORT`)
- Настройте `PUID` и `PGID` в соответствии с вашей системой

## Использование

### Основные команды

- `make build` - сборка Docker-образа
- `make run` - запуск контейнера
- `make stop` - остановка контейнера
- `make clean` - удаление контейнера
- `make logs` - просмотр логов
- `make restart` - перезапуск контейнера
- `make shell` - вход в контейнер

### Перенос на другую машину

1. Сохранение образа:
```bash
make save-image
```

2. Перенесите файл `vscode.tar` на целевую машину

3. Загрузка образа:
```bash
make load-image
```

### Полная очистка

Для полного удаления контейнера и всех данных:
```bash
make purge
```

## Доступ

После запуска VSCode будет доступен по адресу:
```
https://localhost:8443
```

## Настройка

Основные настройки находятся в файле `settings.env`:

- `IMAGE_NAME` - имя Docker-образа
- `CONTAINER_NAME` - имя контейнера
- `PORT` - порт для веб-интерфейса
- `PUID/PGID` - ID пользователя и группы
- `TZ` - часовой пояс
- `PASSWORD` - пароль для входа
- `SUDO_PASSWORD` - пароль для sudo
- `LANG/LANGUAGE/LC_ALL` - настройки локали
- `HOME_DIR` - путь к домашней директории

## Безопасность

- Обязательно измените пароли по умолчанию в `settings.env`
- Используйте HTTPS для доступа к VSCode
- Регулярно обновляйте Docker-образ

## Устранение неполадок

1. Если контейнер не запускается:
```bash
make logs
```

2. Если нужно пересоздать контейнер:
```bash
make restart
```

3. Если нужно полностью очистить и начать заново:
```bash
make purge
make build
make run
```
