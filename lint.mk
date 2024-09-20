# lint

LINT_VERSION ?= v4
LINT_DIRECTORY ?= $(PWD)
LINT_REGEX_INCLUDE ?= all

LINT_PRETTIER_FILE ?= .

LINT_CMD = docker run --rm \
	-e RUN_LOCAL=true \
	-e IGNORE_GITIGNORED_FILES=true \
	-e VALIDATE_EDITORCONFIG=false \
	-e VALIDATE_ENV=false \
	-e VALIDATE_JSCPD=false \
	-e VALIDATE_PHP_PHPSTAN=false \
	-e VALIDATE_PHP_PSALM=false \
	-e VALIDATE_TERRAFORM_TFLINT=false \
	-e VALIDATE_TYPESCRIPT_STANDARD=false \
	-e FILTER_REGEX_INCLUDE=$(LINT_REGEX_INCLUDE) \
	-v $(LINT_DIRECTORY):/tmp/lint \
	github/super-linter:$(LINT_VERSION)

lint:
	$(LINT_CMD)

lint_prettier:
	docker run -w /tmp/prettier -v $(PWD):/tmp/prettier node:20-alpine npx prettier --write $(LINT_PRETTIER_FILE)
