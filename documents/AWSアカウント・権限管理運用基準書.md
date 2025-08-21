# AWSアカウント・権限管理運用基準書

## 1. AWSアカウント管理方針

本システムのAWSアカウント管理は、以下の方針で運用しています。

- AWS OrganizationsとAWS IAM Identity Center（旧AWS SSO）を連携し、組織的なアカウント・権限管理を実施
- AWSアカウントはOrganizationsのroot直下に以下の構成で管理
    - 管理アカウント: deidra-project
    - 本番環境: ris-prod
    - ステージング環境: ris-stg
    - 開発環境: ris-dev
- 各アカウントの権限付与・ユーザ管理はIAM Identity Center経由で一元化
- rootユーザは緊急時のみ利用し、通常運用はIdentity Center経由のユーザで実施

この構成により、環境ごとの分離・権限管理の厳格化・運用効率化を図っています。

## 2. AWS Identity Center（旧AWS SSO）運用補足

各AWSアカウント環境ごとに、Identity Center上で以下のグループを作成し、公式の許可セット（Permission Set）をアタッチしています。

- **rif-prod-read-only**: 本番用の読み取り専用グループ（ReadOnlyAccess付与）
- **rif-prod-power**: 本番用のパワーユーザーグループ（PowerUserAccess付与）
- **rif-prod-admin**: 本番用の管理者グループ（AdministratorAccess付与）

各グループは手動で管理され、AWS公式のPermission Set（AdministratorAccess, ReadOnlyAccess, PowerUserAccess）を利用しています。
これにより、環境ごと・権限レベルごとに厳格なアクセス制御を実現しています。

## 3. 開発者への権限付与方針

開発者に対するAWS権限付与は、以下の運用方針としています。

- 通常は「読み取り専用グループ（ReadOnlyAccess）」のみ付与
- PowerUserAccess（パワーユーザー権限）が必要な作業は、原則として管理者が実施
- やむを得ず開発者がPowerUserAccessを必要とする場合は、管理者判断のもと、該当ユーザを一時的にパワー権限グループへ手動追加
- 作業完了後は速やかにパワー権限グループから除外

この運用により、最小権限の原則を徹底しつつ、必要時のみ柔軟な権限昇格を可能としています。
