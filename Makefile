TOP_DIR = ../..
TOOLS_DIR = $(TOP_DIR)/tools
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
include $(TOOLS_DIR)/Makefile.common

default:
	for x in `ls scripts`; do cp scripts/$x $(TOP_DIR)/bin/$x; chmod +x $(TOP_DIR)/bin/$x; done
	cp template/communities.template $(TOP_DIR)/template/.

all: deploy

deploy: deploy-client

deploy-client: deploy-scripts
	mkdir -p $(SERVICE_DIR)/template
	cp template/communities.template $(SERVICE_DIR)/template/.
	@echo "client tools deployed"

test:
	@echo "no tests to run"

include $(TOOLS_DIR)/Makefile.common.rules
