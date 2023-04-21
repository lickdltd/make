# ansible

ANS_VERSION ?= latest
ANS_DIRECTORY ?= $(PWD)

ANS_DOCKER_CMD = docker run --rm -it \
	-v ~/.aws:/root/.aws:ro \
	-v ~/.ssh:/root/.ssh:ro \
	-v $(ANS_DIRECTORY):/ansible \
	$(ANS_DOCKER_ADDITIONAL) ghcr.io/lickdltd/ansible:$(ANS_VERSION)

ANS_GALAXY_INSTALL_CMD = $(ANS_DOCKER_CMD) ansible-galaxy install -r requirements.yaml
ans_galaxy_install:
	$(ANS_GALAXY_INSTALL_CMD)

ANS_PLAYBOOK_CMD = $(ANS_DOCKER_CMD) ansible-playbook $(PLAYBOOK)
ans_playbook:
	$(ANS_PLAYBOOK_CMD)
ans_playbook_%:
	$(ANS_PLAYBOOK_CMD)
