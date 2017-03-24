.ONESHELL:
.PHONEY: help set-env init update plan plan-destroy show graph apply output output-json taint raw environment
# set to include stages that do not need assume
non_assume_goals := help graph environment

ifneq ($(origin SECRETS), undefined)
SECRET_VARS = "-var-file=$(SECRETS)"
endif

# KMS keys for the statefile buckets
#keys.<env> := arn:aws:kms:eu-west-1:<account id>:alias/<name>

# Identifiers for the AWS accounts
#env.<env>.id := <account id>

# Name of the role to assume
role-name := tf-admin

ifneq ($(strip $(filter-out $(.DEFAULT_GOAL) $(non_assume_goals),$(MAKECMDGOALS))),)
ifndef ENV
$(error ENV was not set)
endif
endif

export TF_VAR_assume_account := $(env.$(ENV).id)
export TF_VAR_assume_role := $(role-name)
export TF_VAR_env := $(ENV)

ifeq (raw,$(firstword $(MAKECMDGOALS)))
# use the rest as arguments for "run"
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(RUN_ARGS):;@:)
endif

help: ## get description of make commands
	@grep -E '^[a-zA-Z_-]+[%]*:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

environment: ## Create new environment. Example: ENV=test make environment
	@if [ -z $(ENV) ]; then\
		echo ENV was not set; exit 1;\
	fi
	@mkdir -p environments/$(ENV)
	@touch environments/$(ENV)/$(notdir $(ENV)).tfvars environments/$(ENV)/$(notdir $(ENV)).tf
	@$(foreach envfile,$(wildcard environments/*.tf),cp $(envfile) environments/$(ENV)/env_$(notdir $(envfile)); )

init: environment
	@cd environments/$(ENV)
	@rm -rf .terraform 1>/dev/null
	@terraform init \
		-backend=true \
		-input=false \
		-backend-config 'bucket=$(ENV).tfstate' \
		-backend-config 'key=$(ENV).tfstate' \
		-backend-config 'region=eu-west-1' \
		-backend-config 'profile=$(ENV)' \
		-backend-config 'role_arn=arn:aws:iam::$(env.$(ENV).id):role/$(role-name)'

update: ## Gets a newer version of the state
	@cd environments/$(ENV)
	@terraform get -update=true 1>/dev/null

plan: update ## Runs a plan to show proposed changes.
	@cd environments/$(ENV)
	@terraform plan -input=false -refresh=true -module-depth=-1 $(SECRET_VARS) \
		-var-file=$(ENV).tfvars -out=terraform_plan

plan-target.%: update ## Runs a plan to show proposed changes. Example: ENV=ops-ss-dt make plan-target.module.tscm-cloud-custodian
	@cd environments/$(ENV)
	@echo "Specifically planning to run $(@:plan-target.%=%)"
	@echo "Example: module.rds.aws_route53_record.rds-master"
	@terraform plan -input=false -refresh=true -module-depth=-1 $(SECRET_VARS) \
		-var-file=$(ENV).tfvars -out=terraform_plan \
		-target=$(@:plan-target.%=%)

plan-destroy: update ## Runs a plan to show what will be destroyed
	@cd environments/$(ENV)
	@terraform plan -input=false -refresh=true -module-depth=-1 \
		-destroy $(SECRET_VARS) -var-file=$(ENV).tfvars

show:
	@cd environments/$(ENV)
	@terraform show -module-depth=-1

graph: ## Creates a graph of the resources that Terraform is aware of
	@cd environments/$(ENV)
	@rm -f graph.png
	@terraform graph -draw-cycles -module-depth=-1 | dot -Tpng > graph.png
	@open graph.png

apply: update ## Apply the changes against your environment
	@cd environments/$(ENV)
	@-terraform apply -input=true -refresh=true terraform_plan
	@rm -f terraform_plan

output: update ## Show Terraform output (optionally specify MODULE in the environment)
	@cd environments/$(ENV)
	@if [ -z $(MODULE) ]; then\
		terraform output;\
	 else\
		terraform output -module=$(MODULE);\
	 fi

taint.%: update ## Taint resource to force re-creation on next plan/apply. Example: ENV=ops-ss-dt MODULE=tscm-cloud-custodian taint.aws_iam_role_policy_attachment.cloudcustodian-lambda-aws-read-everything-policy
	@if [ -z $(MODULE) ]; then\
		echo "MODULE was not set"; exit 10;\
	fi
	@terraform taint $(SECRET_VARS) -var-file=$(ENV).tfvars \
	  -module=$(MODULE) $(@:taint.%=%)
	@echo "You will now want to run a plan to see what changes will take place"

destroy: update ## Destroy a set of resources
	@cd environments/$(ENV)
	@terraform destroy $(SECRET_VARS) -var-file=$(ENV).tfvars

destroy-target.%: update ## Specifically choose a resource to destroy
	@cd environments/$(ENV)
	@echo "Specifically planning to destroy $(@:destroy-target.%=%)"
	@terraform destroy $(SECRET_VARS) -var-file=$(ENV).tfvars \
		-target=$(@:destroy-target.%=%)

raw: ## Initiate raw terraform commands after updating state
	@cd environments/$(ENV)
	@terraform $(RUN_ARGS)
