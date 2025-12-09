# ==============================================================================
# Dev Workspace - Work Outputs
# ==============================================================================

output "dev_workspace_work_name" {
  description = "Name of the work workspace instance"
  value       = google_compute_instance.dev_workspace_work.name
}

output "dev_workspace_work_ip" {
  description = "Static external IP address of work workspace"
  value       = google_compute_address.dev_workspace_work.address
}

output "dev_workspace_work_ssh" {
  description = "SSH command to connect to work workspace"
  value       = "ssh ${var.ssh_user}@${google_compute_address.dev_workspace_work.address}"
}

output "dev_workspace_work_zone" {
  description = "Zone where work workspace is deployed"
  value       = google_compute_instance.dev_workspace_work.zone
}

# ==============================================================================
# Dev Workspace - Personal Outputs
# ==============================================================================

output "dev_workspace_personal_name" {
  description = "Name of the personal workspace instance"
  value       = google_compute_instance.dev_workspace_personal.name
}

output "dev_workspace_personal_ip" {
  description = "Static external IP address of personal workspace"
  value       = google_compute_address.dev_workspace_personal.address
}

output "dev_workspace_personal_ssh" {
  description = "SSH command to connect to personal workspace"
  value       = "ssh ${var.ssh_user}@${google_compute_address.dev_workspace_personal.address}"
}

output "dev_workspace_personal_zone" {
  description = "Zone where personal workspace is deployed"
  value       = google_compute_instance.dev_workspace_personal.zone
}

# ==============================================================================
# Deploy Server Outputs
# ==============================================================================

output "deploy_server_name" {
  description = "Name of the deploy server instance"
  value       = google_compute_instance.deploy_server.name
}

output "deploy_server_ip" {
  description = "External IP address of deploy server (ephemeral, may change on restart)"
  value       = google_compute_instance.deploy_server.network_interface[0].access_config[0].nat_ip
}

output "deploy_server_ssh" {
  description = "SSH command to connect to deploy server"
  value       = "ssh ${var.ssh_user}@${google_compute_instance.deploy_server.network_interface[0].access_config[0].nat_ip}"
}

output "deploy_server_zone" {
  description = "Zone where deploy server is deployed"
  value       = google_compute_instance.deploy_server.zone
}

output "deploy_service_account" {
  description = "Service account email attached to deploy server"
  value       = google_service_account.deploy.email
}

# ==============================================================================
# GitHub Actions Outputs
# ==============================================================================

output "github_actions_service_account" {
  description = "Service account email for GitHub Actions"
  value       = google_service_account.github_actions.email
}

output "workload_identity_provider" {
  description = "Workload Identity Provider resource name (for GitHub Actions)"
  value       = google_iam_workload_identity_pool_provider.github.name
}
