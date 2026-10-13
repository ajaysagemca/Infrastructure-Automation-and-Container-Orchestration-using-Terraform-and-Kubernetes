variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "project_name" {
  description = "Project name for resource tags"
  type        = string
  default     = "infrastructure-automation-kubernetes"
}

variable "admin_cidr" {
  description = "Your public IP with /32 for SSH access"
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid CIDR, such as 203.0.113.10/32."
  }
}

variable "ssh_public_key_path" {
  description = "Path to your public SSH key, relative to terraform directory"
  type        = string
  default     = "../id_ed25519.pub"
}