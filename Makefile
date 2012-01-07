.PHONY: deploy_live watch
project=chart
path=/var/www/chart
instance=\033[31;01m${project}\033[m

all: watch

deploy_live: server = sawyer@ubox1
deploy_live:
	@coffee -c app.coffee
	@rsync -az --exclude=".git" --exclude='node_modules/**/build' --delete --delete-excluded * ${server}:${path}
	@echo " ${instance} | copied files to ${server}"
	@ssh ${server} "cd ${path} && npm rebuild"
	@echo " ${instance} | updated npm packages on ${server}"
	@ssh -t ${server} "sudo cp -f ${path}/upstart.conf /etc/init/${project}.conf"
	@echo " ${instance} | setting up upstart on ${server}";
	@ssh -t ${server} "sudo restart ${project}"
	@echo " ${instance} | restarting app on ${server}";
	@rm app.js

watch:
	@if ! which supervisor > /dev/null; then echo "supervisor required, installing..."; sudo npm install -g supervisor; fi
	@supervisor -w app.coffee,lib,views,assets,data app.coffee
