ENV=dev

## dev環境境
.PHONY: init
init: ## [dev環境] 初期化
    docker-compose --env-file ./env/.${ENV}.env run --rm  terraform init -var-file=./${ENV}/terraform.tfvars ./terraform/${ENV}

.PHONY: plan
plan: ## [dev環境] 差分
    docker-compose --env-file ./env/.${ENV}.env run --rm terraform plan -var-file=./${ENV}/terraform.tfvars ./terraform/${ENV}

.PHONY: apply
apply: ## [dev環境] デプロイ
    docker-compose --env-file ./env/.${ENV}.env run --rm terraform apply -var-file=./${ENV}/terraform.tfvars ./terraform/${ENV}

.PHONY: destroy
destroy: ## [dev環境] destroy
    docker-compose --env-file ./env/.${ENV}.env run --rm terraform destroy -var-file=./${ENV}/terraform.tfvars ./terraform/${ENV}

## ステージング環境
.PHONY: init_stg
init_stg:
    make init ENV=stg
 
.PHONY: plan_stg
plan_stg:
    make plan ENV=stg
 
.PHONY: apply_stg
apply_stg:
    make apply ENV=stg
 
.PHONY: destroy_stg
destroy_stg:
    make destroy ENV=stg

## 本番環境
.PHONY: init_prod
init_prod:
    make init ENV=prod
 
.PHONY: plan_prod
plan_prod:
    make plan ENV=prod
 
.PHONY: apply_prod
apply_prod:
    make apply ENV=prod
 
.PHONY: destroy_prod
destroy_prod:
    make destroy ENV=prod
