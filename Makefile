REPO           = $(shell basename -s .git `git config --get remote.origin.url`)
CUR_BRANCH     = $(shell git rev-parse --abbrev-ref HEAD)
ROOT_DIR       = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
GIT_USER       = magnussmed
GIT_TOKEN_FILE = /Users/magnussmed/.gittoken
AUTH_TOKEN     = `cat $(GIT_TOKEN_FILE)`

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

wp-app:
ifeq ($(name), )
	@echo "\033[0;32mPlease provide a repository name by writing: make wp-app name=<value>\033[0m"
else
	@echo "\033[0;32mCreating a new WP repository: "$(name)"...\033[0m"
	cd www && mkdir $(name) && cd $(name) && git clone https://github.com/$(GIT_USER)/wp-site-boilerplate.git && cd wp-site-boilerplate; rm -rf .git && mv .[^.]* .. && mv * ..
	cd www/$(name) && rm -rf wp-site-boilerplate
	cd www/$(name) && curl -i -H "Authorization: token "$(AUTH_TOKEN)"" -d '{ "name":"'$(name)'" }' https://api.github.com/user/repos
	cd www/$(name) && git init; git remote add origin https://github.com/$(GIT_USER)/$(name).git
	cd www/$(name) && git add . && git commit -a -m "Imported files from wp-site-boilerplate.git" && git push -u origin master
	@echo "\033[0;32mSuccessfully created "$(name)"\033[0m"
endif
