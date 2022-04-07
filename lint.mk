# lint

LINT_VERSION ?= v4
LINT_DIRECTORY ?= $(PWD)
LINT_REGEX_INCLUDE ?= all

LINT_CMD = docker run --rm \
	-e RUN_LOCAL=true \
	-e IGNORE_GITIGNORED_FILES=true \
	-e VALIDATE_PHP_PSALM=false \
	-e VALIDATE_PHP_PHPSTAN=false \
	-e FILTER_REGEX_INCLUDE=$(LINT_REGEX_INCLUDE) \
	-v $(LINT_DIRECTORY):/tmp/lint \
	github/super-linter:$(LINT_VERSION)

lint:
	$(LINT_CMD)
