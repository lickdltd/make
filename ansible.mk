# ansible

ANS_VERSION ?= latest
ANS_DIRECTORY ?= $(PWD)

ANS_DOCKER_CMD = docker run --rm \
	-v ~/.aws:/root/.aws:ro \
	-v ~/.ssh:/root/.ssh:ro \
	-v $(ANS_DIRECTORY):/ansible \
	$(ANS_DOCKER_ADDITIONAL) ghcr.io/lickdltd/ansible:$(ANS_VERSION)

ans_galaxy_install:
	$(ANS_DOCKER_CMD) ansible-galaxy install -r requirements.yaml

ans_playbook ans_playbook_%:
	$(ANS_DOCKER_CMD) ansible-playbook $(PLAYBOOK)
