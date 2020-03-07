.PHONY: tests all unit functional clean dependencies tdd docs html purge

GIT_ROOT		:= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DOCS_ROOT		:= $(GIT_ROOT)/docs
HTML_ROOT		:= $(DOCS_ROOT)/build/html
VENV_ROOT		:= $(GIT_ROOT)/.venv

DOCS_INDEX		:= $(HTML_ROOT)/index.html

export VENV		?= $(VENV_ROOT)



all: dependencies tests

$(VENV):  # creates $(VENV) folder if does not exist
	python3 -mvenv $(VENV)
	$(VENV)/bin/pip install -U pip setuptools

$(VENV)/bin/sphinx-build $(VENV)/bin/nosetests $(VENV)/bin/python $(VENV)/bin/pip: # installs latest pip
	test -e $(VENV)/bin/pip || make $(VENV)
	$(VENV)/bin/pip install -r development.txt
	$(VENV)/bin/pip install -e .

# Runs the unit and functional tests
tests: $(VENV)/bin/nosetests  # runs all tests
	$(VENV)/bin/nosetests tests --with-random --cover-erase

tdd: $(VENV)/bin/nosetests  # runs all tests
	$(VENV)/bin/nosetests tests --with-watch --cover-erase

# Install dependencies
dependencies: | $(VENV)/bin/nosetests
	$(VENV)/bin/pip install -r development.txt

# runs unit tests
unit: $(VENV)/bin/nosetests  # runs only unit tests
	$(VENV)/bin/nosetests --cover-erase tests/unit

# runs functional tests
functional: $(VENV)/bin/nosetests  # runs functional tests
	$(VENV)/bin/nosetests tests/functional


$(DOCS_INDEX): | $(VENV)/bin/sphinx-build
	cd docs && make html

html: $(DOCS_INDEX)

docs: $(DOCS_INDEX)
	open $(DOCS_INDEX)

# cleanup temp files
clean:
	rm -rf $(HTML_ROOT) build


# purge all virtualenv and temp files, causes everything to be rebuilt
# from scratch by other tasks
purge: clean
	rm -rf $(VENV)
