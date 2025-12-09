terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ==============================================================================
# Service Account for Deploy Server
# ==============================================================================

resource "google_service_account" "deploy" {
  account_id   = "deploy-server-sa"
  display_name = "Deploy Server Service Account"
  description  = "Service account for deploy server to manage infrastructure"
}

# Grant Compute Admin role to service account
resource "google_project_iam_member" "deploy_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.deploy.email}"
}

# Grant Service Account User role (needed to attach service accounts to VMs)
resource "google_project_iam_member" "deploy_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.deploy.email}"
}

# ==============================================================================
# Deploy Server (e2-micro / US region for free tier)
# ==============================================================================

resource "google_compute_instance" "deploy_server" {
  name         = "deploy-server"
  machine_type = "e2-micro"
  zone         = var.deploy_zone

  tags = ["deploy-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"

    # Ephemeral IP (changes on restart)
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  # Attach service account
  service_account {
    email  = google_service_account.deploy.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true

  labels = {
    purpose    = "deploy-server"
    managed_by = "terraform"
  }
}

# ==============================================================================
# Dev Workspace - Work (e2-medium / Osaka region)
# ==============================================================================

resource "google_compute_address" "dev_workspace_work" {
  name   = "dev-workspace-work-ip"
  region = var.region
}

resource "google_compute_instance" "dev_workspace_work" {
  name         = "dev-workspace-work"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["dev-workspace"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.disk_size_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.dev_workspace_work.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  allow_stopping_for_update = true

  labels = {
    purpose    = "work"
    managed_by = "terraform"
  }
}

# ==============================================================================
# Dev Workspace - Personal (e2-medium / Osaka region)
# ==============================================================================

resource "google_compute_address" "dev_workspace_personal" {
  name   = "dev-workspace-personal-ip"
  region = var.region
}

resource "google_compute_instance" "dev_workspace_personal" {
  name         = "dev-workspace-personal"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["dev-workspace"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.disk_size_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.dev_workspace_personal.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  allow_stopping_for_update = true

  labels = {
    purpose    = "personal"
    managed_by = "terraform"
  }
}

# ==============================================================================
# Workload Identity Federation for GitHub Actions
# ==============================================================================

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "assertion.repository == '${var.github_repo}'"
}

# Service Account for GitHub Actions
resource "google_service_account" "github_actions" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions to run Terraform"
}

# Allow GitHub Actions to impersonate the service account
resource "google_service_account_iam_member" "github_actions_workload_identity" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}

# Grant Compute Admin role to GitHub Actions service account
resource "google_project_iam_member" "github_actions_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Grant Service Account User role to GitHub Actions service account
resource "google_project_iam_member" "github_actions_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# ==============================================================================
# Firewall Rules
# ==============================================================================

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-workspace"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["dev-workspace", "deploy-server"]
}
