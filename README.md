# Remote Workspace

GCP上のリモート開発環境をTerraformで管理するリポジトリ。

## 構成

| VM | スペック | リージョン | IP | 用途 |
|----|---------|-----------|-----|------|
| dev-workspace | e2-medium | 大阪 (asia-northeast2) | 静的IP | 開発作業 |
| deploy-server | e2-micro | US Central (us-central1) | エフェメラルIP | Terraform実行 |

## 1. dev-workspace（開発用VM）

### 起動

GCPモバイルアプリまたはコンソールで `dev-workspace` を選択 → 「開始」

### SSH接続

```bash
ssh syalahasu@<dev-workspace-ip>
```

### Zedで接続

Zed → Remote Development → SSH → `syalahasu@<dev-workspace-ip>`

### 停止

GCPアプリで「停止」（コスト節約のため作業終了時に停止推奨）

## 2. deploy-server（Terraform実行用）

### 起動

GCPモバイルアプリで `deploy-server` を選択 → 「開始」

### IP確認（起動後）

エフェメラルIPのため、起動ごとにIPが変わる可能性がある。

```bash
gcloud compute instances describe deploy-server \
  --zone=us-central1-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

### SSH接続

```bash
ssh syalahasu@<確認したIP>
```

### Terraform実行

```bash
cd ~/remote-workspace
terraform plan
terraform apply
```

### 停止

GCPアプリで「停止」

## 3. Terraformの変更を適用する流れ

1. ローカルで `.tf` ファイルを編集
2. `git commit` & `git push`
3. deploy-serverにSSH
4. `git pull` → `terraform plan` → `terraform apply`

## 4. Git管理

### コミット対象

- `main.tf`, `variables.tf`, `outputs.tf`
- `terraform.tfvars.example`
- `.terraform.lock.hcl`
- `.envrc`, `.gitignore`

### コミット対象外（.gitignore済み）

- `terraform.tfvars`（秘密情報）
- `.terraform/`
- `*.tfstate`, `*.tfstate.*`

## 5. deploy-server 初回セットアップ

deploy-serverに初めて接続した際に以下を実行：

```bash
# Terraformインストール
sudo apt update && sudo apt install -y unzip
curl -fsSL https://releases.hashicorp.com/terraform/1.14.1/terraform_1.14.1_linux_amd64.zip -o terraform.zip
unzip terraform.zip && sudo mv terraform /usr/local/bin/
rm terraform.zip

# リポジトリのクローン
git clone <your-repo-url> ~/remote-workspace
cd ~/remote-workspace

# terraform.tfvarsの設定
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvarsを編集（project_id, ssh_user, ssh_public_keyを設定）
```

## 6. ローカル開発環境の前提条件

- `gcloud` CLI がインストール済み
- `gcloud auth application-default login` で認証済み
- `direnv` がインストール済み（プロジェクトディレクトリに入ると自動で `CLOUDSDK_CORE_PROJECT` が設定される）
