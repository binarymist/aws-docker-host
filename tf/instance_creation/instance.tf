# https://www.terraform.io/docs/providers/aws/r/instance.html
# https://www.andreagrandi.it/2017/08/25/getting-latest-ubuntu-ami-with-terraform/
data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "access-dockerhost" {
  name = "access-dockerhost"
  tags {
    Name = "dockerhost-env"
  }
}

# Todo: For multiple containers, will need to interate on:
#   image_name
#   image_app_content
#   local_tarred_image_path
#   remote_tarred_image_path
#   container_name
resource "aws_instance" "dockerhost" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.aws_instance_type}"
  iam_instance_profile = "${var.docker_iam_instance_profile}"

  tags {
    Name = "dockerhost"
  }

  security_groups = [ "access-dockerhost" ]

  provisioner "local-exec" {
    command = "docker build --tag ${var.image_name} ${var.image_app_content}"
  }
  provisioner "local-exec" {
    command = "docker save -o ${var.local_tarred_image_path} ${var.image_name}"
  }

  # Copy publick key to instance.
  key_name = "${aws_key_pair.deployer.key_name}"
  
  connection {
    type = "ssh"
    #agent = false
    user = "${var.instance_user}"    
    private_key = "${file("${var.key_pair["private_key_file_path"]}")}"    
    timeout = "3m"
  }

  provisioner "file" {
    # Copy docker image
    source = "${var.local_tarred_image_path}"
    destination = "${var.remote_tarred_image_path}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"##### Performing apt-get update #####\"",
      "sudo apt-get update",
      "echo \"##### Installing packages #####\"",
      "sudo apt-get install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "echo \"##### The Docker repo Key fingerprint should be: #####\"",
      "echo 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88",
      "sudo apt-key fingerprint 0EBFCD88",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "echo \"##### Performing apt-get update #####\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce=${var.tested_docker_version}",
      "sudo usermod -aG docker ubuntu",
      "echo \"##### Logging out -> in so that user added to docker group can perform docker operations #####\""
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"##### About to load ${var.remote_tarred_image_path} #####\"",
      "docker load -i ${var.remote_tarred_image_path}",
      "echo \"##### About to run container: ${var.container_name} #####\"",
      "docker run -e \"NODE_ENV=production\" -p 80:3000 -d --restart=unless-stopped --name ${var.container_name} ${var.image_name}",
      "echo \"##### The container is running as: #####\"",
      "docker ps --quiet | xargs docker inspect --format '{{ .Id }}: User={{ .Config.User }}'",
      "echo \"##### Removing tarred docker image. #####\"",
      "rm ${var.remote_tarred_image_path}"
    ]
  }
}

# Output the security group Id to be used to add rules.
output "dockerhost_security_group" {
  value = "${aws_security_group.access-dockerhost.id}"
}

# EC2 instances public DNS can change if instance is stopped -> started, so best to use EIP: https://serverfault.com/questions/329585/ec2-is-an-instances-public-dns-stable-can-i-rely-on-it-not-changing
# Elastic IPs are changed only if instances are terminated: https://aws.amazon.com/premiumsupport/knowledge-center/elastic-ip-charges/
# EIPs cost if there are no instances using them.
resource "aws_eip" "lb" {
  instance = "${aws_instance.dockerhost.id}"
  # EC2 instances are setup with a default VPC, the only charges apply when you add a VPN to your VPC.
  vpc      = false
}

# Output the elastic IP to add to CDN.
output "aws_eip_lb_host" {
  # Public DNS would be nicer, but it's not available.
  value = "${aws_eip.lb.public_ip}"
}

# Todo: For multiple containers, add an ngnx container:
#   http://www.bogotobogo.com/DevOps/Docker/Docker-Compose-Nginx-Reverse-Proxy-Multiple-Containers.php
#   https://medium.com/@francoisromain/host-multiple-websites-with-https-inside-docker-containers-on-a-single-server-18467484ab95
