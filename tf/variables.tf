variable "aws_region" {
  description = "AWS region to launch server(s)."
  # Availability zone.
  default     = "ap-southeast-2"
}

variable "access_key" {}
variable "secret_key" {}

variable "cloudflare_email" {}
variable "cloudflare_token" {}

variable "aws_instance_type" {
  default = "t2.micro"
}

variable "security_group_rules" {}

variable "key_pair" {}

variable "instance_user" {}
variable "docker_image_name" {}
variable "image_app_content" {}
variable "local_tarred_docker_image_path" {}
variable "remote_tarred_docker_image_path" {}
variable "docker_container_name" {}

variable "tested_docker_version" {}

variable "cloudflare_domain" {}
