# ansible

* [setup](#setup)
  * [directory definitions](#directory-definitions)
  * [additional options](#additional-options)
* [commands](#commands)
  * [install](#install)
  * [playbook](#playbook)

## setup

### directory definitions

```makefile
ans_%: ANS_DIRECTORY = $(PWD)/path/to/ansible
```

### additional options

```makefile
ans_playbook_%: PLAYBOOK = main.yaml

ans_playbook_deploy_%: PLAYBOOK = deploy.yaml
ans_playbook_deploy_%: ANS_DOCKER_ADDITIONAL = -e VARIABLE_NAME=$(VARIABLE_VALUE)
```

## commands

### install

```shell
make ans_galaxy_install
```

### playbook

```shell
make ans_playbook
make ans_playbook_deploy
```
