
develop: docker-compose-develop.yml
	docker-compose -f docker-compose-develop.yml up --build

release: docker-compose.yml
	docker-compose -f docker-compose.yml up --build

sh:
	docker run -it memo_app_api_server /bin/ash
