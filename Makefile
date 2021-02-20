REPO       = $(shell basename -s .git `git config --get remote.origin.url`)
CUR_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
ROOT_DIR   = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
GIT_USER   = magnussmed

start:
	docker-compose -f docker-compose.yml up -d --build

stop:
	docker-compose -f docker-compose.yml stop

deploy-base:
	rm -rf www/$(app)
	mkdir www/$(app)
	@echo "\033[0;32mCloning "$(app)" repository from GitHub ($(GIT_USER))...\033[0m"
	git clone https://github.com/$(GIT_USER)/$(app) www/$(app)
	@echo "\033[0;32mInstalling Wordpress and other composer dependencies...\033[0m"
	cd www/$(app) && curl -s https://getcomposer.org/installer | php -- --install-dir=./ --version=1.9.0 && rm -rf composer.lock && php composer.phar install
	@echo "\033[0;32mExecuting repository make command...\033[0m"
	cd www/$(app) && make db-import-prod
	@echo "\033[0;32mSuccessfully deployed "$(app)" to your local airbase environment.\033[0m"
	@echo "\033[0;32mAccess URL: http://"$(app)".test\033[0m"

stop-dnsmasq:
	sudo brew services stop dnsmasq
