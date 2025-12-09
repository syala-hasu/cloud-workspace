# Cloud Workspace

GCP上のリモート開発環境をTerraformで管理するリポジトリ。

## 構成

| リソース | 説明 |
|----------|------|
| dev-workspace-work | 仕事用VM (e2-medium, 静的IP) |
| dev-workspace-personal | 個人用VM (e2-medium, 静的IP) |
| deploy-server | Terraform実行用VM (e2-micro, エフェメラルIP) |

## CI/CD

GitHub Actions で自動化：

- **PR作成時**: `terraform plan` を実行
- **mainマージ時**: `terraform apply` を自動実行

認証には Workload Identity Federation を使用。

## セットアップ

### 1. terraform.tfvars の作成

```bash
cp terraform.tfvars.example terraform.tfvars
```

以下を設定：
- `project_id`: GCPプロジェクトID
- `ssh_user`: SSHユーザー名
- `ssh_public_key`: SSH公開鍵
- `github_repo`: GitHubリポジトリ (owner/repo)

### 2. 初回 apply

```bash
terraform init
terraform apply
```

### 3. GitHub Secrets の設定

`terraform apply` 完了後、以下を GitHub Secrets に追加：

| Secret 名 | 値 |
|-----------|-----|
| `WORKLOAD_IDENTITY_PROVIDER` | `terraform output workload_identity_provider` |
| `SERVICE_ACCOUNT` | `terraform output github_actions_service_account` |
| `GCP_PROJECT_ID` | GCPプロジェクトID |
| `SSH_USER` | SSHユーザー名 |
| `SSH_PUBLIC_KEY` | SSH公開鍵 |
