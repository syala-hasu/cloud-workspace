variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-northeast2"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-northeast2-a"
}

# Deploy server region/zone (US for free tier)
variable "deploy_region" {
  description = "GCP region for deploy server"
  type        = string
  default     = "us-central1"
}

variable "deploy_zone" {
  description = "GCP zone for deploy server"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "Machine type for the instance"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "ssh_source_ranges" {
  description = "Source IP ranges allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "github_repo" {
  description = "GitHub repository (owner/repo format) for Workload Identity Federation"
  type        = string
}
