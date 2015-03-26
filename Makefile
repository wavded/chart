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
	@printf " ${instance} | synced files with servers\n"
	@ssh ${serverA} "sudo initctl reload-configuration"
	@ssh ${serverB} "sudo initctl reload-configuration"
	@printf " ${instance} | reloaded configuration on servers\n"
	@-ssh ${serverA} "sudo stop ${project}"
	@ssh ${serverA} "sudo start ${project}"
	@-ssh ${serverB} "sudo stop ${project}"
	@ssh ${serverB} "sudo start ${project}"
	@printf " ${instance} | restarted apps on servers\n"
