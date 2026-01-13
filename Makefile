COMPOSE_V1 := $(shell command -v docker-compose 2> /dev/null)
DOCKER_CONFIG := -f docker-compose.yml

ifdef COMPOSE_V1
  DC = docker-compose $(DOCKER_CONFIG)
else
  DC = docker compose $(DOCKER_CONFIG)
endif

RUN_WEB = $(DC) run --rm web
RUN_TEST = $(DC) run --rm -e RAILS_ENV=test web

.PHONY: setup server test console shell sidekiq clean


setup:
	$(DC) build
	$(DC) up -d db redis
	@echo "Aguardando banco subir..." && sleep 5
	$(RUN_WEB) bin/rails db:create db:migrate db:seed
	$(RUN_TEST) bin/rails db:create db:migrate


server:
	$(DC) up

test:
	$(RUN_TEST) bundle exec rspec

console:
	$(RUN_WEB) bin/rails c

shell:
	$(RUN_WEB) bash

clean:
	$(DC) down -v