# terraform

* [setup](#setup)
  * [version override](#version-override)
  * [directory definitions](#directory-definitions) - single directory, multi directory
  * [additional options](#additional-options)
* [commands](#commands)
  * [init](#init)
  * [validate](#validate)
  * [plan](#plan) - refresh, target, replace
  * [apply](#apply) - refresh, target, replace
  * [destroy](#destroy)
  * [fmt](#fmt)
  * [import](#import)
  * [state](#state) - list, mv, rm
  * [workspace](#workspace) - delete, list, new, select, show

## setup

### version override

```makefile
TF_VERSION = 1.0.0
```

### directory definitions

#### single directory

```makefile
tf_%: TF_DIRECTORY = $(PWD)/path/to/terraform
```

#### multi directory

```makefile
tf_%_shared: TF_DIRECTORY = $(PWD)/path/to/terraform/shared
tf_%_environment: TF_DIRECTORY = $(PWD)/path/to/terraform/environment
```

### additional options

```makefile
tf_%: TF_DOCKER_ADDITIONAL = -e TF_VAR_variable_name=$(VARIABLE_VALUE)
tf_%_environment: TF_DOCKER_ADDITIONAL = -e TF_VAR_variable_name=$(VARIABLE_VALUE)
```

## commands

### init

```shell
make tf_init
make tf_init_environment
```

### validate

```shell
make tf_validate
make tf_validate_environment
```

### plan

```shell
make tf_plan
make tf_plan_environment
```

#### refresh

```shell
REFRESH=true make tf_plan
REFRESH=true make tf_plan_environment
```

#### target

```shell
TARGET='terraform.target' make tf_plan
TARGET='terraform.target' make tf_plan_environment
```

#### replace

```shell
REPLACE='terraform.target' make tf_plan
REPLACE='terraform.target' make tf_plan_environment
```

### apply

```shell
make tf_apply
make tf_apply_environment
```

#### refresh

```shell
REFRESH=true make tf_apply
REFRESH=true make tf_apply_environment
```

#### target

```shell
TARGET='terraform.target' make tf_apply
TARGET='terraform.target' make tf_apply_environment
```

#### replace

```shell
REPLACE='terraform.target' make tf_apply
REPLACE='terraform.target' make tf_apply_environment
```

### destroy

```shell
make tf_destroy
make tf_destroy_environment
```

### fmt

```shell
make tf_fmt
make tf_fmt_environment
```

### import

```shell
ADDRESS='terraform.target' ID='resource-id' make tf_import
ADDRESS='terraform.target' ID='resource-id' make tf_import_environment
```

### state

#### list

```shell
make tf_state_list
make tf_state_list_environment
```

#### mv

```shell
SOURCE='terraform.target.from' DESTINATION='terraform.target.to' make tf_state_mv
SOURCE='terraform.target.from' DESTINATION='terraform.target.to' make tf_state_mv_environment
```

#### rm

```shell
ADDRESS='terraform.target' make tf_state_rm
ADDRESS='terraform.target' make tf_state_rm_environment
```

### workspace

#### delete

```shell
TF_WORKSPACE=example make tf_workspace_delete
TF_WORKSPACE=example make tf_workspace_delete_environment
```

#### list

```shell
make tf_workspace_list
make tf_workspace_list_environment
```

#### new

```shell
TF_WORKSPACE=example make tf_workspace_new
TF_WORKSPACE=example make tf_workspace_new_environment
```

#### select

```shell
TF_WORKSPACE=example make tf_workspace_select
TF_WORKSPACE=example make tf_workspace_select_environment
```

#### show
 
```shell
make tf_workspace_show
make tf_workspace_show_environment
```
