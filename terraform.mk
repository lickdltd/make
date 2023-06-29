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

TF_INIT_CMD = $(TF_DOCKER_CMD) init -upgrade
tf_init:
	$(TF_INIT_CMD)
tf_init_%:
	$(TF_INIT_CMD)

TF_VALIDATE_CMD = $(TF_DOCKER_CMD) validate
tf_validate:
	$(TF_VALIDATE_CMD)
tf_validate_%:
	$(TF_VALIDATE_CMD)


TF_PLAN_CMD = $(TF_DOCKER_CMD) plan -compact-warnings
tf_plan:
ifdef REFRESH
	$(TF_PLAN_CMD) -refresh-only
else ifdef TARGET
	$(TF_PLAN_CMD) -target '$(TARGET)'
else ifdef REPLACE
	$(TF_PLAN_CMD) -replace '$(REPLACE)'
else
	$(TF_PLAN_CMD)
endif
tf_plan_%:
ifdef REFRESH
	$(TF_PLAN_CMD) -refresh-only
else ifdef TARGET
	$(TF_PLAN_CMD) -target '$(TARGET)'
else ifdef REPLACE
	$(TF_PLAN_CMD) -replace '$(REPLACE)'
else
	$(TF_PLAN_CMD)
endif

TF_APPLY_CMD = $(TF_DOCKER_CMD) apply -compact-warnings
tf_apply:
ifdef REFRESH
	$(TF_APPLY_CMD) -refresh-only
else ifdef TARGET
	$(TF_APPLY_CMD) -target '$(TARGET)'
else ifdef REPLACE
	$(TF_APPLY_CMD) -replace '$(REPLACE)'
else
	$(TF_APPLY_CMD)
endif
tf_apply_%:
ifdef REFRESH
	$(TF_APPLY_CMD) -refresh-only
else ifdef TARGET
	$(TF_APPLY_CMD) -target '$(TARGET)'
else ifdef REPLACE
	$(TF_APPLY_CMD) -replace '$(REPLACE)'
else
	$(TF_APPLY_CMD)
endif

TF_DESTROY_CMD = $(TF_DOCKER_CMD) destroy
tf_destroy:
	$(TF_DESTROY_CMD)
tf_destroy_%:
	$(TF_DESTROY_CMD)

TF_FMT_CMD = $(TF_DOCKER_CMD) fmt -recursive
tf_fmt:
	$(TF_FMT_CMD)
tf_fmt_%:
	$(TF_FMT_CMD)

TF_IMPORT_CMD = $(TF_DOCKER_CMD) import '$(ADDRESS)' '$(ID)'
tf_import:
	$(TF_IMPORT_CMD)
tf_import_%:
	$(TF_IMPORT_CMD)

TF_STATE_LIST_CMD = $(TF_DOCKER_CMD) state list
tf_state_list:
	$(TF_STATE_LIST_CMD)
tf_state_list_%:
	$(TF_STATE_LIST_CMD)

TF_STATE_MV_CMD = $(TF_DOCKER_CMD) state mv '$(SOURCE)' '$(DESTINATION)'
tf_state_mv:
	$(TF_STATE_MV_CMD)
tf_state_mv_%:
	$(TF_STATE_MV_CMD)

TF_STATE_RM_CMD = $(TF_DOCKER_CMD) state rm '$(ADDRESS)'
tf_state_rm:
	$(TF_STATE_RM_CMD)
tf_state_rm_%:
	$(TF_STATE_RM_CMD)

TF_WORKSPACE_DELETE_CMD = $(TF_DOCKER_CMD) workspace delete '$(TF_WORKSPACE)'
tf_workspace_delete:
	$(TF_WORKSPACE_DELETE_CMD)
tf_workspace_delete_%:
	$(TF_WORKSPACE_DELETE_CMD)

TF_WORKSPACE_LIST_CMD = $(TF_DOCKER_CMD) workspace list
tf_workspace_list:
	$(TF_WORKSPACE_LIST_CMD)
tf_workspace_list_%:
	$(TF_WORKSPACE_LIST_CMD)

TF_WORKSPACE_NEW_CMD = $(TF_DOCKER_CMD) workspace new '$(TF_WORKSPACE)'
tf_workspace_new:
	$(TF_WORKSPACE_NEW_CMD)
tf_workspace_new_%:
	$(TF_WORKSPACE_NEW_CMD)

TF_WORKSPACE_SELECT_CMD = $(TF_DOCKER_CMD) workspace select '$(TF_WORKSPACE)'
tf_workspace_select:
	$(TF_WORKSPACE_SELECT_CMD)
tf_workspace_select_%:
	$(TF_WORKSPACE_SELECT_CMD)

TF_WORKSPACE_SHOW_CMD = $(TF_DOCKER_CMD) workspace show
tf_workspace_show:
	$(TF_WORKSPACE_SHOW_CMD)
tf_workspace_show_%:
	$(TF_WORKSPACE_SHOW_CMD)
