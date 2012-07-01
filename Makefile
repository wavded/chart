.PHONY: deploy_live watch
project=chart
path=/var/www/chart
instance=\033[31;01m${project}\033[m

all: watch

deploy_live: serverA = sawyer@172.25.20.111
deploy_live: serverB = sawyer@172.25.20.120
deploy_live:
	@rsync -az --exclude=".git" --delete --delete-excluded * ${serverA}:${path}
	@rsync -az --exclude=".git" --delete --delete-excluded * ${serverB}:${path}
	@echo -e " ${instance} | copied files to ${serverA} and ${serverB}"
	@ssh -t ${serverA} "sudo cp -f ${path}/upstart.conf /etc/init/${project}.conf"
	@ssh -t ${serverB} "sudo cp -f ${path}/upstart.conf /etc/init/${project}.conf"
	@echo -e " ${instance} | setting up upstart on ${serverA} and ${serverB}";
	-ssh -t ${serverA} "sudo stop ${project}"
	@ssh -t ${serverA} "sudo start ${project}"
	-ssh -t ${serverB} "sudo stop ${project}"
	@ssh -t ${serverB} "sudo start ${project}"
	@echo -e " ${instance} | restarting app on ${serverA} and ${serverB}";

watch:
	@if ! which supervisor > /dev/null; then echo "supervisor required, installing..."; sudo npm install -g supervisor; fi
	@supervisor -w app.js,lib,views,assets,data app.js
