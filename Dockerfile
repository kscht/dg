FROM ubuntu:22.04

# Настройка SHELL с pipefail
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Настройка базовых переменных окружения
ENV LANG=ru_RU.UTF-8 \
    LANGUAGE=ru_RU:ru \
    LC_ALL=ru_RU.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Moscow \
    R_HOME=/usr/lib/R \
    R_LIBS_USER=/usr/local/lib/R/site-library \
    QUARTO_PYTHON=/home/coder/venv/bin/python \
    QUARTO_JUPYTER=/home/coder/venv/bin/jupyter \
    QUARTO_CHROME=/usr/bin/chromium \
    QUARTO_DENO=/usr/bin/deno \
    QUARTO_DART_SASS=true \
    QUARTO_PREVIEW_PORT=4200 \
    QUARTO_PATH=/usr/lib/quarto/bin/quarto \
    QUARTO_PANDOC=/usr/lib/quarto/bin/tools/pandoc \
    QUARTO_RENDER_PANDOC=/usr/lib/quarto/bin/tools/pandoc

# Настройка PATH
RUN printf 'export PATH="/usr/lib/quarto/bin:/home/coder/.TinyTeX/bin/x86_64-linux:%s"\n' "$PATH" > /etc/profile.d/path.sh && \
    chmod +x /etc/profile.d/path.sh

USER root

# Базовые системные пакеты и локализация
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dumb-init \
    git \
    git-lfs \
    htop \
    locales \
    lsb-release \
    man-db \
    nano \
    openssh-client \
    procps \
    sudo \
    vim-tiny \
    wget \
    zsh \
    jq \
    gdebi \
    gdal-bin \
    libgdal-dev \
  && git lfs install \
  && rm -rf /var/lib/apt/lists/*


# Локализация
RUN sed -i '/ru_RU.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=ru_RU.UTF-8

# Создание и настройка пользователя coder с UID/GID 1000
RUN set -eux; \
    # Если есть запись с UID 1000 — удаляем этого пользователя целиком
    if getent passwd 1000 >/dev/null; then \
      userdel -r "$(getent passwd 1000 | cut -d: -f1)"; \
    fi; \
    # Создаём группу с GID 1000
    addgroup --gid 1000 coder; \
    # Создаём пользователя с UID 1000 и помещаем его в группу coder
    adduser \
      --uid 1000 \
      --ingroup coder \
      --disabled-password \
      --gecos "" \
      --shell /bin/bash \
      coder; \
    # Даем ему право sudo без пароля
    printf 'coder ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/coder; \
    chmod 0440 /etc/sudoers.d/coder

# Установка fixuid и правка UID
RUN ARCH="$(dpkg --print-architecture)" \
    && curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.6.0/fixuid-0.6.0-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - \
    && chown root:root /usr/local/bin/fixuid \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf 'user: %s\ngroup: %s\n' 'coder' 'coder' > /etc/fixuid/config.yml

# Python и инструменты
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# R и dev-пакеты
RUN apt-get update && apt-get install -y --no-install-recommends \
    r-base \
    r-base-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libfontconfig1-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Создание директории для R пакетов и настройка прав
RUN mkdir -p /usr/local/lib/R/site-library && \
    chown -R coder:coder /usr/local/lib/R/site-library && \
    printf 'R_LIBS_USER=%s\n' '/usr/local/lib/R/site-library' >> /etc/environment

# Node.js и npm
RUN apt-get update \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g npm@11.3.0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && node --version \
    && npm --version

# Установка reveal.js
USER root
RUN npm install -g reveal.js && \
    mkdir -p /usr/local/lib/node_modules/reveal.js && \
    chown -R coder:coder /usr/local/lib/node_modules/reveal.js && \
    ls -la /usr/local/lib/node_modules/reveal.js && \
    npm list -g reveal.js && \
    printf 'Reveal.js установлен успешно\n'

# Java и PlantUML
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-jre \
    graphviz \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка PlantUML
RUN curl -fsSL https://github.com/plantuml/plantuml/releases/download/v1.2025.2/plantuml-1.2025.2.jar -o /usr/local/bin/plantuml.jar && \
    echo '#!/bin/bash\njava -jar /usr/local/bin/plantuml.jar "$@"' > /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

# Графика, браузер и зависимости для рендеринга
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium-browser \
    chromium-chromedriver \
    libgbm1 \
    libasound2 \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Шрифты и утилиты для документов
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-liberation \
    fonts-noto \
    fonts-noto-cjk \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Pandoc
RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка Quarto CLI (последняя стабильная версия)
RUN curl -fsSL https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.29/quarto-1.7.29-linux-amd64.deb -o quarto-1.7.29-linux-amd64.deb && \
    gdebi -n quarto-1.7.29-linux-amd64.deb && \
    rm quarto-1.7.29-linux-amd64.deb

# Установка Deno
RUN curl -fsSL https://deno.land/install.sh | sh && \
    install -Dm755 /root/.deno/bin/deno /usr/local/bin/deno && \
    ln -s /usr/local/bin/deno /usr/bin/deno

RUN deno --version

# Проверка наличия quarto
RUN quarto --version

# Заглушка
#CMD ["tail", "-f", "/dev/null"]

# Установка code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Копируем настройки
COPY --chown=coder:coder settings.json /home/coder/.local/share/code-server/User/settings.json

# Установка расширений
USER coder
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-toolsai.jupyter
RUN code-server --install-extension yzhang.markdown-all-in-one
RUN code-server --install-extension quarto.quarto

# Установка R-пакетов для Quarto
USER coder
RUN R -e ".libPaths('/usr/local/lib/R/site-library'); install.packages(c( \
    'knitr', \
    'rmarkdown', \
    'leaflet', \
    'ggplot2', \
    'dplyr', \
    'tidyr', \
    'shiny', \
    'plotly', \
    'DT', \
    'htmltools', \
    'htmlwidgets', \
    'tinytex', \
    'bookdown', \
    'blogdown', \
    'xaringan', \
    'flexdashboard', \
    'tidyverse', \
    'devtools', \
    'reticulate' \
    ))"

# Создание Python окружения и настройка прав
RUN chown -R coder:coder /home/coder/ && \
    python3 -m venv /home/coder/venv && \
    mkdir -p /home/coder/.local/share/code-server/User/ && \
    mkdir -p /home/coder/.local/share/code-server/extensions && \
    mkdir -p /home/coder/project

# Переключение на пользователя coder
WORKDIR /home/coder/

# Установка Python пакетов
RUN if [ -f /home/coder/venv/bin/activate ]; then \
    . /home/coder/venv/bin/activate && \
    pip install --no-cache-dir \
    jupyter \
    jupyterlab \
    matplotlib \
    plotly \
    numpy \
    pandas \
    scipy \
    seaborn \
    folium \
    plotnine \
    dash \
    dash-bootstrap-components \
    dash-core-components \
    dash-html-components \
    dash-table \
    jupyter-book \
    jupyterlab-git \
    rpy2 \
    nbconvert \
    nbformat \
    jupyter-contrib-nbextensions \
    jupyter-nbextensions-configurator \
    ipywidgets \
    ipyleaflet \
    bqplot \
    ipyvolume \
    ipyvuetify \
    ipywebrtc \
    ipydatetime \
    ipycanvas \
    ipyevents \
    ipytree \
    ipysheet \
    ipyaggrid && \
    python -c "import jupyter, matplotlib, plotly, numpy, pandas, scipy, seaborn, folium, plotnine, dash, rpy2, nbconvert, nbformat, ipywidgets, ipyleaflet, bqplot"; \
fi

# Настройка .bashrc
RUN printf 'source %s\n' '/home/coder/venv/bin/activate' >> ~/.bashrc && \
    printf 'export QUARTO_PANDOC=%s\n' '/usr/lib/quarto/bin/tools/pandoc' >> ~/.bashrc && \
    printf 'export QUARTO_RENDER_PANDOC=%s\n' '/usr/lib/quarto/bin/tools/pandoc' >> ~/.bashrc

# Возвращаемся в рабочую директорию
WORKDIR /home/coder/project

# Открытие порта
EXPOSE 8443

# Запуск code-server
USER coder
ENTRYPOINT ["fixuid", "-q", "--"]
CMD ["code-server", "--bind-addr", "0.0.0.0:8443", "."]
