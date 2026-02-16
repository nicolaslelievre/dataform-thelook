DATAFORM_VERSION := 3.0.0
DATAFORM         := npx @dataform/cli@$(DATAFORM_VERSION)

.PHONY: help versions init-creds compile run run-staging run-intermediate run-marts run-dry

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

versions: ## Print Node, Dataform CLI, and Dataform Core versions
	@echo "Node:          $$(node --version)"
	@echo "Dataform CLI:  $(DATAFORM_VERSION)"
	@echo "Dataform Core: $$(grep dataformCoreVersion workflow_settings.yaml | awk '{print $$2}')"

init-creds: ## Authenticate with BigQuery (generates .df-credentials.json via OAuth)
	$(DATAFORM) init-creds

compile: ## Compile the project and validate the DAG (no BigQuery calls)
	$(DATAFORM) compile

run: ## Run all models
	$(DATAFORM) run

run-staging: ## Run staging layer only
	$(DATAFORM) run --tags staging

run-intermediate: ## Run intermediate layer only
	$(DATAFORM) run --tags intermediate

run-marts: ## Run mart layer only
	$(DATAFORM) run --tags marts

run-dry: ## Dry run — print SQL without executing
	$(DATAFORM) run --dry-run
