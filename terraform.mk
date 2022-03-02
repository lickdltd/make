# terraform

TF_VERSION ?= 1.1.6
TF_DIRECTORY ?= $(PWD)
TF_WORKSPACE ?= default

TF_DOCKER_CMD = docker run --rm \
	-w /terraform \
	-v ~/.aws:/root/.aws:ro \
	-v ~/.ssh:/root/.ssh:ro \
	-v $(TF_DIRECTORY):/terraform \
	$(TF_DOCKER_ADDITIONAL) hashicorp/terraform:$(TF_VERSION)

tf_init:
	$(TF_DOCKER_CMD) init -upgrade

tf_validate:
	$(TF_DOCKER_CMD) validate

tf_plan:
ifdef REFRESH
	$(TF_DOCKER_CMD) plan -compact-warnings -refresh-only
else ifdef TARGET
	$(TF_DOCKER_CMD) plan -compact-warnings -target '$(TARGET)'
else ifdef REPLACE
	$(TF_DOCKER_CMD) plan -compact-warnings -replace '$(REPLACE)'
else
	$(TF_DOCKER_CMD) plan -compact-warnings
endif

tf_apply:
ifdef REFRESH
	$(TF_DOCKER_CMD) apply -compact-warnings -refresh-only
else ifdef TARGET
	$(TF_DOCKER_CMD) apply -compact-warnings -target '$(TARGET)'
else ifdef REPLACE
	$(TF_DOCKER_CMD) apply -compact-warnings -replace '$(REPLACE)'
else
	$(TF_DOCKER_CMD) apply -compact-warnings
endif

tf_destroy:
	$(TF_DOCKER_CMD) destroy

tf_fmt:
	$(TF_DOCKER_CMD) fmt -recursive

tf_import:
	$(TF_DOCKER_CMD) import '$(ADDRESS)' '$(ID)'

tf_state_list:
	$(TF_DOCKER_CMD) state list

tf_state_mv:
	$(TF_DOCKER_CMD) state mv '$(SOURCE)' '$(DESTINATION)'

tf_state_rm:
	$(TF_DOCKER_CMD) state rm '$(ADDRESS)'

tf_workspace_delete:
	$(TF_DOCKER_CMD) workspace delete '$(TF_WORKSPACE)'

tf_workspace_list:
	$(TF_DOCKER_CMD) workspace list

tf_workspace_new:
	$(TF_DOCKER_CMD) workspace new '$(TF_WORKSPACE)'

tf_workspace_select:
	$(TF_DOCKER_CMD) workspace select '$(TF_WORKSPACE)'

tf_workspace_show:
	$(TF_DOCKER_CMD) workspace show
