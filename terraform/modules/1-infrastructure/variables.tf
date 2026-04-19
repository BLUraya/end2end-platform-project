variable "vpc_id" {
  description = "the ID of the vpc from the vpc module"
  type        = string
}

variable "private_subnet_ids" {
  description = "list of private subnet ids for the instances"
  type        = list(string)
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] #the cannociacl owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] #latest
  }
}

variable "gitlab-ami" {
  description = "ami for git lab"
  type = string
  default = "data.aws_ami.ubuntu.id"
}

variable "vault-ami" {
  description = "ami for vault"
  type = string
  default = "data.aws_ami.ubuntu.id"
}