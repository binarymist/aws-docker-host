variable "aws_instance_type" {}
variable "docker_iam_instance_profile" {}

variable "key_pair" { type = "map" }

variable "instance_user" {}
variable "image_name" {}
variable "image_app_content" {}
variable "local_tarred_image_path" {}
variable "remote_tarred_image_path" {}
variable "container_name" {}

variable "tested_docker_version" {}