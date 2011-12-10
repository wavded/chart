.PHONY: deploy_live watch
project=chart
path=/var/www/chart
instance=\033[36;01m${project}\033[m

all: watch

deploy_live: server = sawyer@ubox1
deploy_live:
	@rsync -az --exclude=".git" --exclude='node_modules' --delete * ${server}:${path}
	@echo " ${instance} | copied files to ${server}"
	@ssh ${server} "cd ${path} && rm -rf node_modules && npm install"
	@echo " ${instance} | updated npm packages on ${server}"
	@ssh -t ${server} "sudo cp -f ${path}/upstart.conf /etc/init/${project}.conf"
	@echo " ${instance} | setting up upstart on ${server}";
	@ssh -t ${server} "sudo restart ${project}"
	@echo " ${instance} | restarting app on ${server}";

watch:
	@if ! which supervisor > /dev/null; then echo "supervisor required, installing..."; sudo npm install -g supervisor; fi
	@supervisor -w app.coffee,lib,views,assets,data app.coffee
