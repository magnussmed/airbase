REPO           = $(shell basename -s .git `git config --get remote.origin.url`)
CUR_BRANCH     = $(shell git rev-parse --abbrev-ref HEAD)
ROOT_DIR       = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
GIT_USER       = magnussmed
GIT_TOKEN_FILE = /Users/magnussmed/.gittoken
AUTH_TOKEN     = $(shell cat $(GIT_TOKEN_FILE))
APPS_COUNT     = `cd $(ROOT_DIR)/www && ls -l | grep -c ^d`

start:
	docker-compose -f docker-compose.yml up -d --build

stop:
	docker-compose -f docker-compose.yml stop

stop-dnsmasq:
	sudo brew services stop dnsmasq

deploy-base:
ifeq ($(app), )
	@echo "\033[0;32mPlease provide a repository name by writing: make deploy-base app=<value>\033[0m"
else
	rm -rf www/$(app)
	mkdir www/$(app)
	@echo "\033[0;32mCloning "$(app)" repository from GitHub ($(GIT_USER))...\033[0m"
	git clone https://github.com/$(GIT_USER)/$(app) www/$(app)
	@echo "\033[0;32mInstalling Wordpress and other composer dependencies...\033[0m"
	cd www/$(app) && curl -s https://getcomposer.org/installer | php -- --install-dir=./ --version=2.1.3 && rm -rf composer.lock && php composer.phar install
	@echo "\033[0;32mExecuting repository make command...\033[0m"
	cd www/$(app) && make db-import-prod
	@echo "\033[0;32mSuccessfully deployed "$(app)" to your local airbase environment.\033[0m"
	@echo "\033[0;32mAccess URL: http://"$(app)".test\033[0m"
endif

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

mass-update:
ifeq ($(message), )
	@echo "\033[0;32mYou have to provide a commit message: message=<commit-message>!\033[0m"
	exit 1
endif
ifeq ($(package), )
	@echo "\033[0;32mYou have to provide a package: package=<name-of-package>!\033[0m"
	exit 1
endif
ifeq ($(version), )
	@echo "\033[0;32mYou have to provide a version: version=<version>!\033[0m"
	exit 1
endif
	chmod +x $(shell pwd)/scripts/mass-update.sh
	git-xargs --repos ./repos.txt --branch-name mass-update-2 --commit-message $(message) $(shell pwd)/scripts/mass-update.sh $(package) $(version)

mass-gcp:
	@echo "\033[0;32mStarting mass gcp of $(APPS_COUNT) apps...\033[0m"
	@for f in $(shell ls $(ROOT_DIR)/www/); \
	do echo "\033[0;32mMoving to next app in the line...\033[0m"; \
	$(MAKE) -C $(ROOT_DIR)/www/$${f} update-repo; \
	done
	@echo "\033[0;32mMass gcp successfully finished ($(APPS_COUNT)/$(APPS_COUNT))!\033[0m"

mass-pull:
	@echo "\033[0;32mStarting mass updating local branches of $(APPS_COUNT) apps...\033[0m"
	@for f in $(shell ls $(ROOT_DIR)/www/); \
	do echo "\033[0;32mMoving to next app in the line...\033[0m"; \
	$(MAKE) -C $(ROOT_DIR)/www/$${f} update-local-repo; \
	done
	@echo "\033[0;32mMass updating successfully finished ($(APPS_COUNT)/$(APPS_COUNT))!\033[0m"

mass-deploy:
	@echo "\033[0;32mStarting mass deployment of $(APPS_COUNT) apps...\033[0m"
	@for f in $(shell ls $(ROOT_DIR)/www/); \
	do echo "\033[0;32mMoving to next app in the line...\033[0m"; \
	echo "\033[0;32m$${f} password:\033[0m"; $(MAKE) -C $(ROOT_DIR)/www/$${f} get-pass; \
	$(MAKE) -C $(ROOT_DIR)/www/$${f} app-deploy e=prod; \
	done
	@echo "\033[0;32mMass deployment successfully finished ($(APPS_COUNT)/$(APPS_COUNT))!\033[0m"
