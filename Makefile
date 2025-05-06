# Загрузка настроек из файла
include settings.env

.PHONY: build run stop clean logs restart shell purge save-image load-image

# Сборка Docker-образа
build:
	sudo docker build -t vscode .

# Сохранение образа в файл
save-image:
	sudo docker save -o vscode.tar $(IMAGE_NAME)

# Загрузка образа из файла
load-image:
	sudo docker load -i vscode.tar

# Запуск контейнера
init:
# Копируем домашние директории при первом запуске в volume
	sudo docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-v $(HOME_DIR):/home2/ \
		--user root \
		$(IMAGE_NAME) \
		/bin/bash -c "cp -Rp /home/* /home2 && touch /home2/.init"

run:
# Запуск рабочего контейнера
# Если нет файла .init, то запускаем init
	if [ ! -f "$(HOME_DIR)/.init" ]; then \
		$(MAKE) init; \
	fi
	sudo chown -R $(PUID):$(PGID) $(HOME_DIR)/coder 
	sudo docker run -d \
		--name $(CONTAINER_NAME) \
		-p $(PORT):8443 \
		--user $(PUID):$(PGID) \
		-e PUID=$(PUID) \
		-e PGID=$(PGID) \
		-e TZ=$(TZ) \
		-e PASSWORD=$(PASSWORD) \
		-e SUDO_PASSWORD=$(SUDO_PASSWORD) \
		-e LANG=$(LANG) \
		-e LANGUAGE=$(LANGUAGE) \
		-e LC_ALL=$(LC_ALL) \
		-v $(HOME_DIR):/home/ \
		--restart unless-stopped \
		$(IMAGE_NAME)

# Остановка контейнера
stop:
	sudo docker stop $(CONTAINER_NAME)

# Удаление контейнера
clean:
	$(MAKE) stop;
	sudo docker rm $(CONTAINER_NAME)

# Просмотр логов
logs:
	sudo docker logs -f $(CONTAINER_NAME)

# Перезапуск контейнера
restart: stop clean run

# Вход в контейнер
shell:
	sudo docker exec -it $(CONTAINER_NAME) /bin/bash 

# Полная очистка с подтверждением
purge:
	@echo "Вы уверены, что хотите удалить контейнер и все данные из $(HOME_DIR)? Это действие нельзя отменить! (y/n)"
	@read -p "Ваш ответ: " answer; \
	if [ "$$answer" = "y" ]; then \
		$(MAKE) clean; \
		sudo rm -rf $(HOME_DIR); \
		echo "Все данные удалены."; \
	else \
		echo "Операция отменена."; \
	fi 