# terraform

TF_VERSION ?= 1.1.7
TF_DIRECTORY ?= $(PWD)
TF_WORKSPACE ?= default

TF_DOCKER_CMD = docker run --rm -it \
	-w /terraform \
	-v ~/.aws:/root/.aws:ro \
	-v ~/.ssh:/root/.ssh:ro \
	-v $(TF_DIRECTORY):/terraform \
	$(TF_DOCKER_ADDITIONAL) hashicorp/terraform:$(TF_VERSION)

tf_init tf_init_%:
	$(TF_DOCKER_CMD) init -upgrade

tf_validate tf_validate_%:
	$(TF_DOCKER_CMD) validate

tf_plan tf_plan_%:
ifdef REFRESH
	$(TF_DOCKER_CMD) plan -compact-warnings -refresh-only
else ifdef TARGET
	$(TF_DOCKER_CMD) plan -compact-warnings -target '$(TARGET)'
else ifdef REPLACE
	$(TF_DOCKER_CMD) plan -compact-warnings -replace '$(REPLACE)'
else
	$(TF_DOCKER_CMD) plan -compact-warnings
endif

tf_apply tf_apply_%:
ifdef REFRESH
	$(TF_DOCKER_CMD) apply -compact-warnings -refresh-only
else ifdef TARGET
	$(TF_DOCKER_CMD) apply -compact-warnings -target '$(TARGET)'
else ifdef REPLACE
	$(TF_DOCKER_CMD) apply -compact-warnings -replace '$(REPLACE)'
else
	$(TF_DOCKER_CMD) apply -compact-warnings
endif

tf_destroy tf_destroy_%:
	$(TF_DOCKER_CMD) destroy

tf_fmt tf_fmt_%:
	$(TF_DOCKER_CMD) fmt -recursive

tf_import tf_import_%:
	$(TF_DOCKER_CMD) import '$(ADDRESS)' '$(ID)'

tf_state_list tf_state_list_%:
	$(TF_DOCKER_CMD) state list

tf_state_mv tf_state_mv_%:
	$(TF_DOCKER_CMD) state mv '$(SOURCE)' '$(DESTINATION)'

tf_state_rm tf_state_rm_%:
	$(TF_DOCKER_CMD) state rm '$(ADDRESS)'

tf_workspace_delete tf_workspace_delete_%:
	$(TF_DOCKER_CMD) workspace delete '$(TF_WORKSPACE)'

tf_workspace_list tf_workspace_list_%:
	$(TF_DOCKER_CMD) workspace list

tf_workspace_new tf_workspace_new_%:
	$(TF_DOCKER_CMD) workspace new '$(TF_WORKSPACE)'

tf_workspace_select tf_workspace_select_%:
	$(TF_DOCKER_CMD) workspace select '$(TF_WORKSPACE)'

tf_workspace_show tf_workspace_show_%:
	$(TF_DOCKER_CMD) workspace show
