module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "infinity-eks-cluster"
  cluster_version = "1.30" 

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  cluster_endpoint_public_access = true 


  node_security_group_additional_rules = {
    ingress_allow_lb_nodeports = {
      description = "allow Ingress from vpc to np for lb"
      protocol    = "tcp"
      from_port   = 30000
      to_port     = 32767
      type        = "ingress"
      
      cidr_blocks = ["10.0.0.0/16"] 
    }
  }

  eks_managed_node_groups = {
    infinity_nodes = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }
}