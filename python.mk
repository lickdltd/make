# python

python_pip_%: CONTAINER = python
python_pip_%: DKR_COMPOSE_ADDITIONAL_RUN = --no-deps

python_pip_install: DKR_COMPOSE_PROJECT = $(NAME)-python-pip-install
python_pip_install: COMMAND = pip install -r requirements.txt
python_pip_install:
	$(DKR_COMPOSE_CMD_RUN) || { $(DKR_COMPOSE_CMD_DOWN); exit 1; }
	$(DKR_COMPOSE_CMD_DOWN)
