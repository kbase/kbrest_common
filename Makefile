TOP_DIR = ../..
TOOLS_DIR = $(TOP_DIR)/tools
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
include $(TOOLS_DIR)/Makefile.common

default: bin
	cp template/communities.template $(TOP_DIR)/template/.

all: deploy

deploy: deploy-client

bin: $(BIN_PERL) $(BIN_PYTHON)

deploy-client: deploy-scripts
	mkdir -p $(SERVICE_DIR)
	mkdir -p $(SERVICE_DIR)/bin
	mkdir -p $(SERVICE_DIR)/template
	cp template/communities.template $(SERVICE_DIR)/template/.
	cp scripts/* $(SERVICE_DIR)/bin/.
	chmod +x $(SERVICE_DIR)/bin/*
	@echo "client tools deployed"

test:
	@echo "no tests to run"

include $(TOOLS_DIR)/Makefile.common.rules
