REPO       = $(shell basename -s .git `git config --get remote.origin.url`)
CUR_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
ROOT_DIR   = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

start:
	docker-compose -f docker-compose.yml up -d --build

stop:
	docker-compose -f docker-compose.yml stop

deploy-base:
	mkdir www/$(app)
	git clone https://github.com/magnussmed/$(app) www/$(app)
