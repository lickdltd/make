# lint

* [setup](#setup)
  * [directory definitions](#directory-definitions)
  * [logs](#logs)
* [commands](#commands)
  * [lint](#lint)

## setup

### directory definitions

```makefile
lint: LINT_DIRECTORY = $(PWD)/path/to/anywhere
```

```shell
LINT_DIRECTORY=./path/to/anywhere make lint
```

### logs

This will create a log file on execution, it is recommended to add `**/super-linter.log` in the `.gitignore` file in the root of the project repo.

## commands

### lint:

```shell
make lint
```
