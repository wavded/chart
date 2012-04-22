.PHONY: deploy_live watch
project=chart
path=/var/www/chart
instance=\033[31;01m${project}\033[m

all: watch

deploy_live: serverA = sawyer@172.25.20.111
deploy_live: serverB = sawyer@172.25.20.120
deploy_live:
	@coffee -c app.coffee
	@rsync -az --exclude=".git" --exclude='node_modules/**/build' --delete --delete-excluded * ${serverA}:${path}
	@rsync -az --exclude=".git" --exclude='node_modules/**/build' --delete --delete-excluded * ${serverB}:${path}
	@echo -e " ${instance} | copied files to ${serverA} and ${serverB}"
	@ssh ${serverA} "cd ${path} && npm rebuild"
	@ssh ${serverB} "cd ${path} && npm rebuild"
	@echo -e " ${instance} | updated npm packages on ${serverA} and ${serverB}"
	@ssh -t ${serverA} "sudo cp -f ${path}/upstart.conf /etc/init/${project}.conf"
	@ssh -t ${serverB} "sudo cp -f ${path}/upstart.conf /etc/init/${project}.conf"
	@echo -e " ${instance} | setting up upstart on ${serverA} and ${serverB}";
	@ssh -t ${serverA} "sudo restart ${project}"
	@ssh -t ${serverB} "sudo restart ${project}"
	@echo -e " ${instance} | restarting app on ${serverA} and ${serverB}";
	@rm app.js

watch:
	@if ! which supervisor > /dev/null; then echo "supervisor required, installing..."; sudo npm install -g supervisor; fi
	@supervisor -w app.coffee,lib,views,assets,data app.coffee
