# default provider
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "template_file" "user_data" {
  vars {
    s3_bucket        = "${var.s3_bucket}"
    s3_bucket_key    = "${var.s3_bucket_key}/backups/"
    ecs_cluster_name = "${var.tag_name}-cluster"
    restore_backup   = "${var.restore_backup}"
    restore_point    = "${var.restore_point}"
  }

  template = "${file("templates/user_data.tpl")}"
}

data "template_file" "template_instance_role_policy" {
  vars {
    s3_bucket_name = "${var.s3_bucket}"
    s3_bucket_key  = "${var.s3_bucket_key}/backups/"
  }

  template = "${file("${path.module}/policies/ecs-instance-role-policy.tpl.json")}"
}

resource "aws_security_group" "sg_nginx" {
  name        = "${var.tag_name}_sg"
  description = "Allows SSH and port 80 traffic for all IPs"
  vpc_id      = "${aws_vpc.nginx.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//image_id = "${lookup(var.amis, var.region)}"

resource "aws_ecs_cluster" "nginx" {
  name = "${var.tag_name}-cluster"
}

resource "aws_autoscaling_group" "asg_nginx" {
  name                      = "${var.tag_name}-asg"
  availability_zones        = ["${var.availability_zone}"]
  min_size                  = "${var.min_instance_size}"
  max_size                  = "${var.max_instance_size}"
  desired_capacity          = "${var.desired_instance_capacity}"
  health_check_type         = "EC2"
  health_check_grace_period = 300
  launch_configuration      = "${aws_launch_configuration.lc_nginx.name}"

  vpc_zone_identifier = [
    "${aws_subnet.nginx.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.tag_name}-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "lc_nginx" {
  name_prefix                 = "${var.tag_name}-lc-"
  image_id                    = "${lookup(var.amis, var.region)}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.sg_nginx.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.iam_instance_profile.name}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "host_role_nginx" {
  name               = "${var.tag_name}-inst-host-role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "instance_role_policy_nginx" {
  name   = "${var.tag_name}-inst-role-policy"
  policy = "${data.template_file.template_instance_role_policy.rendered}"
  role   = "${aws_iam_role.host_role_nginx.id}"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name  = "${var.tag_name}-inst-profile"
  path  = "/"
  roles = ["${aws_iam_role.host_role_nginx.name}"]
}
