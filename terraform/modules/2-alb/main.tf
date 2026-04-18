#----- sg for alb

resource "aws_security_group" "alb_sg" {
  name        = "infinity-alb-sg"
  description = "sg for the alb"
  vpc_id      = var.vpc_id

  # for gl
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # for vault
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # for gitlab image registery
  ingress {
    from_port   = 5050
    to_port     = 5050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound all*
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#-----main alb for 2 az

resource "aws_lb" "main" {
  name               = "infinity-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  #fro dellete when destroy
  enable_deletion_protection = false
}

#---------- tg and health check

resource "aws_lb_target_group" "gitlab_tg" {
  name     = "gitlab-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/-/health" # hc for git by document
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 15
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "vault_tg" {
  name     = "vault-tg"
  port     = 8200
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/ui/"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 15
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "gitlab_registry_tg" {
  name     = "gitlab-registry-tg"
  port     = 5050
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/" 
    matcher             = "200-401" 
  }
}

# --------- attach tg
resource "aws_lb_target_group_attachment" "gitlab_attach" {
  target_group_arn = aws_lb_target_group.gitlab_tg.arn
  target_id        = var.gitlab_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "vault_attach" {
  target_group_arn = aws_lb_target_group.vault_tg.arn
  target_id        = var.vault_id
  port             = 8200
}

resource "aws_lb_target_group_attachment" "gitlab_registry_attach" {
  target_group_arn = aws_lb_target_group.gitlab_registry_tg.arn
  target_id        = var.gitlab_id
  port             = 5050
}


#------------listeners gl and vault

resource "aws_lb_listener" "gitlab_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gitlab_tg.arn
  }
}

resource "aws_lb_listener" "vault_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "8200"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_tg.arn
  }
}

resource "aws_lb_listener" "gitlab_registry_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "5050"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gitlab_registry_tg.arn
  }
}
