variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "existing_vpc_id" {
  type    = string
  default = null
}

variable "create_github_oidc" {
  description = "Create GitHub Actions OIDC provider (set false if it already exists in this account)"
  type        = bool
  default     = true
}
