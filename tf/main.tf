provider "aws" {
  version = "~> 1.0"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     =  "${var.aws_region}"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

module "iam" {
  source = "./iam"
}

module "instance_creation" {
  source = "./instance_creation"
  aws_instance_type = "${var.aws_instance_type}"
  docker_iam_instance_profile = "${module.iam.docker_iam_instance_profile}"
  key_pair = "${var.key_pair}"
  instance_user = "${var.instance_user}"
  image_name = "${var.docker_image_name}"
  image_app_content = "${var.image_app_content}"
  local_tarred_image_path = "${var.local_tarred_docker_image_path}"
  remote_tarred_image_path = "${var.remote_tarred_docker_image_path}"
  container_name = "${var.docker_container_name}"
  tested_docker_version = "${var.tested_docker_version}"
}

module "security_rules" {
  source = "./security_rules"
  security_group_rules = "${var.security_group_rules}"
  security_group_id = "${module.instance_creation.dockerhost_security_group}"
}

# Todo: For multiple containers, interate with the different cloudflare_domain's.
module "cdn" {
  source = "./cdn"
  cloudflare_domain = "${var.cloudflare_domain}"
  aws_eip_lb_host = "${module.instance_creation.aws_eip_lb_host}"
}
