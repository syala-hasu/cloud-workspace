# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

GCP上のリモート開発環境をTerraformで管理するリポジトリ。2つのVMを管理している:

- **dev-workspace**: 開発作業用VM（e2-medium, 大阪リージョン, 静的IP）
- **deploy-server**: Terraform実行用VM（e2-micro, US Central, エフェメラルIP, Free Tier対象）

## Terraform Commands

Terraformの実行は `deploy-server` 上で行う:

```bash
terraform init      # 初回のみ
terraform plan      # 変更内容の確認
terraform apply     # 変更の適用
```

## Architecture

```
main.tf           # リソース定義（VM, Service Account, Firewall）
variables.tf      # 変数定義
outputs.tf        # 出力定義（IP, SSH接続コマンド等）
terraform.tfvars  # 秘密情報（git管理外）
```

### リソース構成

1. **google_service_account.deploy**: deploy-server用サービスアカウント（Compute Admin, Service Account User権限）
2. **google_compute_instance.deploy_server**: Terraform実行用VM
3. **google_compute_instance.dev_workspace**: 開発用VM（静的IP付き）
4. **google_compute_firewall.allow_ssh**: SSH許可ルール

## Important Notes

- `terraform.tfvars` には `project_id`, `ssh_user`, `ssh_public_key` が含まれる（Git管理外）
- direnvで `CLOUDSDK_CORE_PROJECT` が自動設定される
- dev-workspaceは静的IP、deploy-serverはエフェメラルIP（起動ごとに変わる可能性あり）
