# lint

LINT_VERSION ?= v4
LINT_DIRECTORY ?= $(PWD)

LINT_CMD = docker run --rm \
	-e RUN_LOCAL=true \
	-e IGNORE_GITIGNORED_FILES=true \
	-e VALIDATE_PHP_PSALM=false \
	-v $(LINT_DIRECTORY):/tmp/lint \
	github/super-linter:$(LINT_VERSION)

lint:
	$(LINT_CMD)
