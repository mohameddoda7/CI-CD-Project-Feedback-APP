# This file is part of the Terraform with Azure DevOps project.
# It uses the terraform-aws-modules/eks/aws module to create an EKS cluster in AWS.
# The module provisions an EKS cluster with managed node groups, simplifying cluster setup and management.

module "eks" {
  source          = "terraform-aws-modules/eks/aws"                                # Sourcing the EKS module from Terraform AWS Modules
  cluster_name    = "eks-deployment-cluster"                                         # Name of the EKS cluster
  cluster_version = "1.29"                                                         # Specify EKS cluster version
  vpc_id          = aws_vpc.vpc.id                                                 # Link the EKS cluster to the VPC
  subnet_ids      = [aws_subnet.new-pub-subnet.id, aws_subnet.new-pub-subnet-2.id] # Subnets where the cluster nodes will be created

  # Configure managed node groups for the cluster
  eks_managed_node_groups = {
    stagging_nodes = {
      desired_size = 2 # Desired number of nodes
      max_size     = 3 # Maximum number of nodes
      min_size     = 2 # Minimum number of nodes

      instance_types = ["t2.micro"] # Instance type for the nodes

      ssh = {
        enable     = true                  # Enable SSH access to nodes
        public_key = "azure-agent-key.pem" # Public key for SSH access
      }

      tags = {
        Name    = "eks-node-for-deployment-cluster" # Name tag for the node group
        project = "Terraform-with-AzureDevOps"      # Project tag for identification
      }
    }
  }

  tags = {
    Name    = "eks-deployment-cluster"     # Cluster name tag
    project = "Terraform-with-AzureDevOps" # Project tag for identification
  }
}

# Output the name of the created EKS cluster
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

# Output the API endpoint URL for the EKS cluster
output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
