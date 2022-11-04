STAGE=dev
 
.PHONY: init
init: ## [dev環境] 初期化
    # make check
    docker-compose --env-file ./env/.${STAGE}.env run --rm  terraform init -var-file=./${STAGE}/terraform.tfvars ./${STAGE}
 
.PHONY: plan
plan: ## [dev環境] 差分
    make check
    docker-compose --env-file ./env/.${STAGE}.env run --rm terraform plan -var-file=./${STAGE}/terraform.tfvars ./${STAGE}
 
.PHONY: apply
apply: ## [dev環境] デプロイ
    make check
    docker-compose --env-file ./env/.${STAGE}.env run --rm terraform apply -var-file=./${STAGE}/terraform.tfvars ./${STAGE}
 
.PHONY: destroy
destroy: ## [dev環境] destroy
    make check
    docker-compose --env-file ./env/.${STAGE}.env run --rm terraform destroy -var-file=./${STAGE}/terraform.tfvars ./${STAGE}
 
.PHONY: valid
valid: ## [dev環境] 設定のチェック
    docker-compose --env-file ./env/.${STAGE}.env run --rm terraform validate ./${STAGE}
 
.PHONY: check
check: ## [dev環境] check
    docker-compose --env-file ./env/.${STAGE}.env run --rm terraform fmt -recursive ./${STAGE}
    docker-compose --env-file ./env/.${STAGE}.env run --rm terraform fmt -check ./${STAGE}
    docker-compose --env-file ./env/.${STAGE}.env run --rm terraform validate ./${STAGE}
 
 
## 本番環境　（stgはコピペしてSTAGE書き換え）
.PHONY: init_prod
init_prod: ## [prod環境] 初期化
    make init STAGE=prod
 
.PHONY: plan_prod
plan_prod: ## [prod環境] 差分
    make plan STAGE=prod
 
.PHONY: apply_prod
apply_prod: ## [prod環境] デプロイ
    make apply STAGE=prod
 
.PHONY: destroy_prod
destroy_prod: ## [prod環境] destroy
    make destroy STAGE=prod