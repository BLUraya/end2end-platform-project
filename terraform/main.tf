#---- create vpc
module "vpc" {
  source = "./modules/0-vpc"
}

#----- craete infra
module "infra" {
  source             = "./modules/1-infrastructure"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
}



#------ make inventory file for instance id ------------

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.root}/../ansible/inventory.tftpl", {
    gitlab_id  = module.infra.gitlab_id
    vault_id   = module.infra.vault_id
    aws_region = var.aws_region
    ssm_bucket = module.infra.ssm_bucket_name
  })

  #make the inventory filr
  filename = "${path.module}/../ansible/inventory.ini"

  # depens on the creation of the instances
  depends_on = [module.infra]
}

# -------- end inventory -------------------


#--------- create main alb
module "alb" {
  source = "./modules/2-alb"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets 
  gitlab_id      = module.infra.gitlab_id
  vault_id       = module.infra.vault_id
}

# get the dns name for access in web from consule
output "application_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "vault_url" {
  value = "http://${module.alb.alb_dns_name}:8200/ui/"
}


#-------------- eks 

module "eks" {
  source = "./modules/3-eks"

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

output "update_kubeconfig_command" {
  description = "command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}