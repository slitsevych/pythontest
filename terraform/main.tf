#Initializing provider in us-east-2 region
provider "aws" {
  shared_credentials_file = "${var.cred_path}"
  region                  = "${var.region}"
}

#Initiliazing backend to store remote state
terraform {
  backend "s3" {
    bucket  = "live-s3storage"
    key     = "pythontest/terraform.tfstate"
    encrypt = true
    region  = "us-east-2"
  }
}
#################################################
#Creating security group for EFS mount
resource "aws_security_group" "EC2_sg" {
  name   = "EC2_SG"
  vpc_id = "${var.vpc_id}"

  dynamic "ingress" {
    for_each = ["22", "80", "5000"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["${var.my_ip}"]
    }
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.public}"]
  }

  tags = {
    Name = "SG-EC2"
  }
}

############################################
#Creating s3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${var.env}-s3"
  region        = "${var.region}"
  force_destroy = true

  #Add versioning
  versioning {
    enabled = true
  }
}

############################################
resource "aws_iam_role" "travisdeploy_role" {
  name               = "${var.env}_role"
  assume_role_policy = "${data.aws_iam_policy_document.travisdeploy_policy.json}"

  tags = {
    tag-key = "${var.env}-role"
  }
}

data "aws_iam_policy_document" "travisdeploy_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "travisdeploy_instance_profile" {
  name = "${var.env}_instance_profile"
  role = "${aws_iam_role.travisdeploy_role.name}"
}

#creating iam policy
resource "aws_iam_role_policy" "travisdeploy_policy" {
  name   = "${var.env}_policy"
  role   = "${aws_iam_role.travisdeploy_role.id}"
  policy = "${data.template_file.travisdeploy_policy.rendered}"
}

data "template_file" "travisdeploy_policy" {
  template = "${file("./travisdeploy_policy.json")}"
}

###########################################################
#Defining user data file for instances
data "template_file" "userdata" {
  template = "${file("./userdata.tpl")}"
}

resource "aws_instance" "travisdeploy_instance" {
  ami                    = "${data.aws_ami.ami.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.public_subnets.0}"
  vpc_security_group_ids = ["${aws_security_group.EC2_sg.id}"]
  key_name               = "${var.key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.travisdeploy_instance_profile.name}"
  user_data              = "${data.template_file.userdata.rendered}"

  tags = {
    Name = "${var.env}-instance"
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

##########################
resource "aws_codedeploy_app" "travisdeploy" {
  compute_platform = "Server"
  name             = "${var.env}-app"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name               = "${aws_codedeploy_app.travisdeploy.name}"
  deployment_group_name  = "${var.env}-group"
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  service_role_arn       = "${aws_iam_role.travisdeploy_role.arn}"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "${var.env}-instance"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
