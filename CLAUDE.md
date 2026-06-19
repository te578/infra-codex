## 絶対にやってはいけないこと
terraform.tfvarsを読み込まないでください
機密情報を読み込まないでください

---

## インフラ構成まとめ

### 概要
AWS東京リージョン（ap-northeast-1）にTerraformで構築。
tfstateはS3バックエンド（tfstate-shimasan-20260529）で管理。

### ネットワーク
- VPC：`my-vpc`（10.0.0.0/16）
- パブリックサブネット：`public-subnet-d1`（1d）、`public-subnet-a1`（1a）
- プライベートサブネット：`private-subnet-d1`（1d）、`private-subnet-a1`（1a）
- IGW：`my-igw`
- パブリックルートテーブル：`public-rt`（IGWあり）
- プライベートルートテーブル：`private-rt`（IGWなし）

### セキュリティグループ
- `alb-sg`：80番を自宅IPのみ許可
- `ecs-sg`：ALBからの8080番のみ許可
- `rds-sg`：ECSからの5432番のみ許可

### ALB
- `my-alb`：インターネット向け、public-subnet-d1+a1に配置
- ターゲットグループ：`my-tg`（IPタイプ、ポート80）
- リスナー：HTTP 80番 → my-tgに転送

### RDS
- エンジン：PostgreSQL 16、インスタンス：db.t3.micro
- ユーザー：`dbadmin`、パスワード：terraform.tfvarsのdb_password変数
- サブネットグループ：private-subnet-d1+a1

### ECS
- クラスター：`my-cluster`
- タスク定義：`my-task`（Fargate、0.25vCPU、512MB、コンテナポート8080）
- 環境変数：DB_HOST、DB_NAME、DB_USER、DB_PASSWORD
- サービス：`my-service`（使わないときはdesired_count=0に）
- IAMロール：`ecs-task-execution-role`

### その他
- ECR：`my-app`
- CloudWatchロググループ：`/ecs/my-task`（7日保持）

### GitHub Actions（JPro/api/demo/.github/workflows/deploy.yml）
- mainブランチpush時に起動
- DockerイメージビルドしてECRにpush（SHAタグ＋latestタグ）
- Dockerレイヤーキャッシュ有効
- ECSサービスを自動更新

### Spring Boot側
- application.propertiesに環境変数でDB接続設定
- ヘルスチェック用に@GetMapping("/")を追加

### 注意事項
- HTTPのみ（HTTPS未対応）
- 使わないときはECSのdesired_countを0に変更すること
