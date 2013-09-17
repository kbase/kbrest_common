TOP_DIR = ../..
TOOLS_DIR = $(TOP_DIR)/tools
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
include $(TOOLS_DIR)/Makefile.common

SERVICE_NAME = kbrest_common
SERVICE_DIR  = $(TARGET)/services/$(SERVICE_NAME)
SCRIPTS = $(wildcard scripts/*.pl)

default: bin
	cp template/communities.template $(TOP_DIR)/template/.

all: deploy

deploy: deploy-client

bin: $(BIN_PERL) $(BIN_PYTHON)

deploy-client: deploy-scripts
	mkdir -p $(SERVICE_DIR)/template
	cp template/communities.template $(SERVICE_DIR)/template/.
	@echo "client tools deployed"

test: test-scripts

test-scripts:
	@echo "testing scripts ..."
	for t in $(SCRIPTS); do \
		echo $$t; \
		$(DEPLOY_RUNTIME)/bin/perl $$t -h; \
		if [ $$? -eq 0 ]; then \
			echo $$t passed tests; \
		else; \
			echo $$t failed tests; \
		fi \
	done

include $(TOOLS_DIR)/Makefile.common.rules
