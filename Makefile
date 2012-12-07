.PHONY: deploy_live watch
project=chart
path=/var/www/chart
instance=\033[31;01m${project}\033[m

all: watch

deploy: serverA = sawyer@wwt-virt-util-web25
deploy: serverB = sawyer@wwt-virt-util-web26
deploy:
	@rsync -az --exclude=".git" --delete --delete-excluded * ${serverA}:${path}
	@rsync -az --exclude=".git" --delete --delete-excluded * ${serverB}:${path}
	@echo -e " ${instance} | synced files with servers"
	@ssh ${serverA} "sudo initctl reload-configuration"
	@ssh ${serverB} "sudo initctl reload-configuration"
	@echo -e " ${instance} | reloaded configuration on servers"
	@-ssh ${serverA} "sudo stop ${project}"
	@ssh ${serverA} "sudo start ${project}"
	@-ssh ${serverB} "sudo stop ${project}"
	@ssh ${serverB} "sudo start ${project}"
	@echo -e " ${instance} | restarted apps on servers"

watch:
	@if ! which supervisor > /dev/null; then echo "supervisor required, installing..."; sudo npm install -g supervisor; fi
	@supervisor -w app.js,lib,views,assets,data app.js
