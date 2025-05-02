# Terraform provider and version setup
# This block specifies the AWS provider and the version to use for the configuration.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region  = "us-east-1" # Set the AWS region to use
  profile = "default"   # Use the default AWS profile for credentials
}

# Security Group setup
# This resource creates a security group with specified rules to control inbound and outbound traffic.
resource "aws_security_group" "SG-for-devops" {
  name        = var.SG_name                         # Name of the security group
  description = "Security group for DevOps project" # Description of the security group
  vpc_id      = aws_vpc.vpc.id                      # The VPC where the security group is applied

  # Inbound rules: Allow SSH (port 22) from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from any IP address
  }

  # Inbound rules: Allow HTTP (port 80) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rules: Allow all traffic from anywhere
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules: Allow all traffic to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "aws_security_group"
    project = "Terraform-with-AzureDevOps"
  }
}

# VPC setup
# This block creates a Virtual Private Cloud (VPC) with a specified CIDR block.
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16" # VPC address range
  tags = {
    Name    = "azure_vpc"
    project = "Terraform-with-AzureDevOps"
  }
}

# Public Subnet setup
# This block creates a public subnet in the specified VPC within an availability zone.
resource "aws_subnet" "new-pub-subnet" {
  vpc_id                  = aws_vpc.vpc.id # Associate subnet with the VPC
  cidr_block              = "10.0.1.0/24"  # Subnet address range
  availability_zone       = "us-east-1a"   # Availability zone
  map_public_ip_on_launch = true           # Automatically assign public IPs to instances launched here
}

# Second Public Subnet setup
# Creates another public subnet in a different availability zone.
resource "aws_subnet" "new-pub-subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Internet Gateway setup
# This resource creates an internet gateway and attaches it to the VPC for internet access.
resource "aws_internet_gateway" "new-igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "Internet Gateway"
    project = "Terraform-with-AzureDevOps"
  }
}

# Route Table setup
# This creates a route table that defines routing rules for the VPC's subnets.
resource "aws_route_table" "new-route-table" {
  vpc_id = aws_vpc.vpc.id # Associate route table with the VPC

  # Route for all outbound traffic (0.0.0.0/0) to go through the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-igw.id
  }

  tags = {
    Name    = "Route Table"
    project = "Terraform-with-AzureDevOps"
  }
}

# Associate route table with the first public subnet
resource "aws_route_table_association" "new-route-table-assoc" {
  subnet_id      = aws_subnet.new-pub-subnet.id # Associate the route table with the subnet
  route_table_id = aws_route_table.new-route-table.id
}

# Associate route table with the second public subnet
resource "aws_route_table_association" "new-route-table-assoc-2" {
  subnet_id      = aws_subnet.new-pub-subnet-2.id
  route_table_id = aws_route_table.new-route-table.id
}

# EC2 Instance setup
# This block creates an EC2 instance with a specified AMI ID, instance type, subnet, security group, and key pair.
resource "aws_instance" "NewInstance-SSH" {
  ami                         = var.ami_id                   # The AMI ID to use for the instance
  instance_type               = var.instance_type            # The type of EC2 instance
  subnet_id                   = aws_subnet.new-pub-subnet.id # Subnet for the instance
  associate_public_ip_address = true                         # Associate a public IP with the instance
  user_data                   = file("User_Data.sh")

  tags = {
    Name    = var.tags_name
    project = "Terraform-with-AzureDevOps"
  }

  vpc_security_group_ids = [aws_security_group.SG-for-devops.id] # Associate security group
  key_name               = "azure-agent-key"                     # Key pair for SSH access to the instance
}

# Output the EC2 instance's public IP address
# This block outputs the public IP address of the created EC2 instance.
output "instance_public_ip" {
  value = aws_instance.NewInstance-SSH.public_ip
}
