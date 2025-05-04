# VS Code Server с поддержкой R и Quarto

Этот проект предоставляет полноценную среду разработки на основе VS Code Server с поддержкой R, Python, Quarto и других инструментов для научных вычислений и создания документов.

## Возможности

- VS Code Server с веб-интерфейсом
- Поддержка R и RStudio
- Поддержка Python с виртуальным окружением
- Quarto для создания документов
- Jupyter и JupyterLab
- Поддержка Markdown и LaTeX
- Интеграция с Git и Git LFS
- Поддержка reveal.js для презентаций
- Локализация на русский язык

## Установка

1. Скопируйте `settings.example` в `settings.env`:
```bash
cp settings.example settings.env
```

2. Отредактируйте `settings.env`, установив свои значения для:
   - Паролей (PASSWORD, SUDO_PASSWORD)
   - Путей (HOME_DIR)
   - Порта (PORT)
   - Идентификаторов пользователя (PUID, PGID)
   - Часового пояса (TZ)

3. Создайте домашнюю директорию:
```bash
make init-dirs
```

4. Соберите Docker-образ:
```bash
make build
```

5. Запустите контейнер:
```bash
make run
```

## Структура домашней директории

После первого запуска в домашней директории (`HOME_DIR`) будут созданы:
- `project/` - ваши проекты и файлы
- `.local/share/code-server/` - настройки и расширения VS Code
- `.config/` - конфигурационные файлы
- `.venv/` - Python виртуальное окружение
- `.R/` - настройки R
- `.quarto/` - настройки Quarto
- `.jupyter/` - настройки Jupyter

## Доступные команды

- `make build` - сборка Docker-образа
- `make run` - запуск контейнера
- `make stop` - остановка контейнера
- `make clean` - удаление контейнера
- `make restart` - перезапуск контейнера
- `make shell` - доступ к командной строке контейнера
- `make logs` - просмотр логов

## Доступ к VS Code Server

После запуска контейнера VS Code Server будет доступен по адресу:
```
https://localhost:8443
```

## Установленные расширения

- Python (ms-python.python)
- Jupyter (ms-toolsai.jupyter)
- Markdown All in One (yzhang.markdown-all-in-one)
- Quarto (quarto.quarto)

## Технические детали

- Базовая система: Ubuntu 22.04
- Язык: Python 3
- R: последняя стабильная версия
- Quarto: версия 1.7.29
- Node.js и npm для поддержки reveal.js
- Deno для выполнения JavaScript/TypeScript
- Поддержка LaTeX через TinyTeX
