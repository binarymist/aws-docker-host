# Create an IAM role for the docker host.
resource "aws_iam_role" "docker_iam_role" {
  name = "docker_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach policy to the role.
resource "aws_iam_role_policy" "docker_iam_role_policy" {
  name = "docker_iam_role_policy"
  role = "${aws_iam_role.docker_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:Describe*"],
      "Resource": "*"
    }
  ]
}
EOF
}

# Create instance profile, associate the new role.
resource "aws_iam_instance_profile" "docker_instance_profile" {
  name = "docker_instance_profile"
  role = "${aws_iam_role.docker_iam_role.name}"
}

# Output the profile to be attached to the instance.
output "docker_iam_instance_profile" {
  value = "${aws_iam_instance_profile.docker_instance_profile.id}"
}


