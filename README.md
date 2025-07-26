# 概要
ゲームコミュニティ用ウェブサイトのインフラ部分を実装しています。
管理対象として当システム全体のドキュメントを含みます。
全体を通して運用に影響がない限りフォーマットや可読性で工数をかけないことを意識しています。

## 構成
- /front-front-web-site-for-riften-terraform/diagram
  - ドキュメントをまとめたディレクトリ
- /front-front-web-site-for-riften-terraform/riften_web_infra/terraform/00_modules
  - モジュールが配置されているディレクトリ
-  /front-front-web-site-for-riften-terraform/riften_web_infra/terraform/&{ENV}
  - 環境別のモジュール呼び出し元ディレクトリ
- /front-front-web-site-for-riften-terraform/riften_web_infra/tools
  - 開発の tips や雑多な情報などを格納したディレクトリ
  - 運用には乗らないディレクトリになります
- /front-front-web-site-for-riften-terraform/build_command.sh
  - 開発環境のコンテナ設定を操作する際に使用するスクリプト
- /front-front-web-site-for-riften-terraform/Dockerfile
  - 開発環境のコンテナ設定が記載されたファイル

## ドキュメント
ドキュメントを格納しています。
- /front-web-site-for-riften-terraform/diagram/architecture.drawio
  - アーキテクチャ図
- /front-web-site-for-riften-terraform/diagram/workflow.md
  - ワークフロー図
- /front-web-site-for-riften-terraform/diagram/要件定義書_RIFシステム.md
  - 要件定義書
- /front-web-site-for-riften-terraform/diagram/調達仕様書_RIFシステム.md
  - 調達仕様書

## 開発
### 事前準備
1. Windows 11 以上の環境で `git` と `docker` をインストールし、`openssh` で鍵を作成してください。
2. VS Code の拡張機能`Dev Containers`をインストールしてください。

### 外部の拡張機能
効率的な開発を行う為、個人開発の拡張機能で以下の2つを採用しています。
- Draw.io Integration
  - VS Code で Draw.io を操作することが可能
- Markdown Preview Mermaid Support
  - マーメイド記法で書かれたコードをプレビューすることが可能

### 開発環境
以下のコマンドを`Git Bash`環境で実行してください。
コンテナ起動後、リポジトリを `Dev Containers` で開いてください。
```
# 初回起動時
bash build_command.sh first-up
```
```
# 起動時
bash build_command.sh up
```
```
# 接続時
bash build_command.sh exec
# 上記のコマンド、または Remote Explorer → Dev Containers からコンテナを選択し、Attach in New Window からコンテナを起動・接続してください。
```
```
# コンテナ停止時
bash build_command.sh exec
# 上記のコマンド、または Remote Explorer → Dev Containers からコンテナを選択し、Attach in New Window からコンテナを起動・接続してください。
```
```
# イメージ更新時
bash build_command.sh rebuild
```
```
# コンテナ削除
bash build_command.sh down
```

### プッシュ
github に差分をプッシュする際には git-flow を簡略化し運用してください。Github Actions などの実装を簡略化するためタグは使用しません。
- git-flow
  - https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

| ブランチ名      | 用途・説明                                      | 直接コミット禁止 | マージ先          | ブランチ作成元     |
|:---------------|:-----------------------------------------------|:----------------|:-------------------|:-------------------|
| main           | stg・prod 環境へリリースするブランチ               | ○               | -                 | -            |
| release        | 本番リリース後証跡｜切り戻し用ブランチ              | ○               | -                 | main          |
| hotfix         | main へ修正を入れる際に使用（リリース後のバグ修正等）| ×               | main              | main               |
| develop        | dev 環境へリリースするブランチ                     | ○               | main              | -  |
| feature/*      | 作業ブランチ（ローカル・dev 環境での動作確認も実施） | ×               | develop           | develop            |

### ブランチ運用フロー
Mermaid 記法のため必要に応じて VS Code に拡張機能をインストールしてください。
例：Markdown Preview Mermaid
```mermaid
gitGraph
   commit id: "初期コミット"
   branch develop
   commit id: "develop作業"
   branch feature/xxx
   commit id: "feature作業"
   checkout develop
   merge feature/xxx
   commit id: "developマージ"
   checkout main
   merge develop
   branch release
   commit id: "リリース証跡（release分岐のみ、マージやタグは行わない）"
   checkout main
   branch hotfix
   commit id: "hotfix修正"
   checkout main
   merge hotfix
```

### コミットメッセージ
関数単位や同じ修正内容のまとまり単位でコミットしてください。
フォーマットに細かい指定はないですが、作業内容の概要だけ記載をお願いします。
例：[構成変更]_README修正

### PR事前作業
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

### 実行
デプロイする各環境に対して実行してください。
```
cd /front-web-site-for-riften-terraform/riften_web_server/terraform/{ENV}
terraform init -var-file=terraform.tfvars
terraform plan -var-file=terraform.tfvars
terraform deploy -var-file=terraform.tfvars
```

### デストロイ
デストロイする各環境に対して実行してください。
```
cd /front-web-site-for-riften-terraform/riften_web_server/terraform/{ENV}
terraform destroy -var-file=terraform.tfvarss
```
