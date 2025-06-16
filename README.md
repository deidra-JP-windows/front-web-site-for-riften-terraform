# 概要
ゲームコミュニティ用ウェブサイトのインフラ部分を実装しています。

## 構成
- /front-front-web-site-for-riften-terraform/riften_web_server/terraform/base
  - modules
- a

## 構成図
構成図を格納しています。
- /front-web-site-for-riften-terraform/diagram/architecture.drawio
  - アーキテクチャ図
- /front-web-site-for-riften-terraform/diagram/workflow.md
  - ワークフロー図

## 開発
ソースを更新する際にはフォーマッタとバリデートのコマンドを実行・修正したのちPRを作成してください。
- フォーマッタ
```
cd /front-web-site-for-riften-terraform/riften_web_server/terraform/${ENV}
terraform fmt -recursive
```
- バリデータ
```
cd /front-web-site-for-riften-terraform/riften_web_server/terraform/${ENV}
terraform validate
```

## 実行
デプロイする各環境に対して実行してください。
```
cd /front-web-site-for-riften-terraform/riften_web_server/terraform/{ENV}
terraform init -var-file=terraform.tfvars
terraform plan -var-file=terraform.tfvars
terraform deploy -var-file=terraform.tfvars
```

## デストロイ
デストロイする各環境に対して実行してください。
```
cd /front-web-site-for-riften-terraform/riften_web_server/terraform/{ENV}
terraform destroy -var-file=terraform.tfvarss
```
