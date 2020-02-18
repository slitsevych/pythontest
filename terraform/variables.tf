variable "region" {
  default = "us-east-2"
}

variable "env" {
  default = "travisdeploy"
}

variable "key_pair" {
  default = "s.litsevychkeys"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "my_ip" {
  default = "159.224.7.123/32"
}

variable "public" {
  default = "0.0.0.0/0"
}

variable "vpc_id" {
  default = "vpc-39f15050"
}

variable "cred_path" {
  #default = "/home/aim/.aws/credentials"
  #default = "./credentials"
}

variable "public_subnets" {
  type    = "list"
  default = ["subnet-60ac691b", "subnet-47f6e80d", "subnet-932796fa"]
}

data "aws_ami" "ami" {
  owners      = ["290148839206"]
  most_recent = true
  filter {
    name   = "name"
    values = ["*ami-ubuntu-18*"]
  }
}
