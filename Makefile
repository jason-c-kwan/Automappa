.PHONY: clean docker test_environment create_environment

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROFILE = default
PROJECT_NAME = automappa
PYTHON_INTERPRETER = python3

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

ifeq (,$(shell which docker))
HAS_DOCKER=False
else
HAS_DOCKER=True
endif



#################################################################################
# COMMANDS                                                                      #
#################################################################################

# Retrieve test dataset for testing Automappa
# test_data: requirements
# 	$(PYTHON_INTERPRETER) -m pip install -U gdown
# 	gdown https://drive.google.com/uc\?\id=1M6cCOGX-lcM7ymIA5BsXwm6CbaDau0Qm -O test/bins.tsv

## Retrieve automappa docker image
docker:
ifeq (True,$(HAS_DOCKER))
	@echo ">>> Detected docker, pulling automappa docker image."
	docker pull evanrees/automappa:latest
else
	@echo ">>> Docker not detected. Please install docker to use the Automappa docker image"
endif

## Build docker image from Dockerfile (auto-taggged as evanrees/automappa:<current-branch>)
image: Dockerfile
	docker build . -f $< -t evanrees/automappa:`git branch --show-current`

## Install automappa entrypoint into current environment
install: 
	$(PYTHON_INTERPRETER) -m pip install . --ignore-installed --no-deps -vvv

# Run Automappa on test data
# test: test_data
# 	$(PYTHON_INTERPRETER) index.py -i test/bins.tsv

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf dist build Automappa.egg-info

## Test python environment is setup correctly
test_environment: scripts/test_environment.py
	$(PYTHON_INTERPRETER) $<

## Set up python interpreter environment
create_environment: requirements.txt
ifeq (True,$(HAS_CONDA))
	@echo ">>> Detected conda, creating conda environment."
ifeq (3,$(findstring 3,$(PYTHON_INTERPRETER)))
	conda create -c conda-forge --name $(PROJECT_NAME) python=3.7 --file=$<
else
	conda create -c conda-forge --name $(PROJECT_NAME) python=3.7 --file=$<
endif
	@echo ">>> New conda env created. Activate with:\nsource activate $(PROJECT_NAME)"
else
	$(PYTHON_INTERPRETER) -m pip install -q virtualenv virtualenvwrapper
	@echo ">>> Installing virtualenvwrapper if not already installed.\nMake sure the following lines are in shell startup file\n\
	export WORKON_HOME=$$HOME/.virtualenvs\nexport PROJECT_HOME=$$HOME/Devel\nsource /usr/local/bin/virtualenvwrapper.sh\n"
	@bash -c "source `which virtualenvwrapper.sh`;mkvirtualenv $(PROJECT_NAME) --python=$(PYTHON_INTERPRETER)"
	@echo ">>> New virtualenv created. Activate with:\nworkon $(PROJECT_NAME)"
endif

## Remove python interpreter environment
delete_environment:
	conda env remove -n $(PROJECT_NAME)

#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
