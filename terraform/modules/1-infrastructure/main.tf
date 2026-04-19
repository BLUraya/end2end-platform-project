
# ---- iam role (with ssm)

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "infinity-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "infinity-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# --------------------------------------------------------
# ---- sg

resource "aws_security_group" "gitlab_sg" {
  name        = "gitlab-sg"
  description = "sg for gitlab"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # network in vpc
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # for image registery
  ingress {
    from_port   = 5050
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # for pull containers
  }
}

resource "aws_security_group" "vault_sg" {
  name        = "vault-sg"
  description = "sg for vault"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8200 # default port for vault
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --------------------------------------------------------
# ec2 intance

resource "aws_instance" "gitlab" {
  ami           = var.gitlab-ami
  instance_type = "m7i-flex.large" # storng cpu and good for  memory
  subnet_id     = var.private_subnet_ids[0]

  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.gitlab_sg.id]

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  tags = {
    Name = "gitLab-server"
  }
}

resource "aws_instance" "vault" {
  ami                    = var.vault-ami
  instance_type          = "c7i-flex.large"
  subnet_id              = var.private_subnet_ids[1]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.vault_sg.id]

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "vault-server"
  }
}


#---------------
# s3 bucket for ansible ssm, there is 70kb for every command in ssm and ansible

resource "aws_s3_bucket" "ansible_ssm_bucket" {
  bucket_prefix = "infinity-ansible-ssm-"
  force_destroy = true
}

# iam
resource "aws_iam_role_policy" "ssm_s3_policy" {
  name = "infinity-ssm-s3-policy"
  role = aws_iam_role.ssm_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.ansible_ssm_bucket.arn,
          "${aws_s3_bucket.ansible_ssm_bucket.arn}/*"
        ]
      }
    ]
  })
}

# end of s3 bucket
