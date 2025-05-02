# Define the instance type for the EC2 instance
variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro" # Default to t2.micro for low-cost, general-purpose instance
}

# Define the AMI ID for the EC2 instance
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-084568db4383264d4" # Set to the desired AMI ID for your region
}

# Define the name tag for the EC2 instance
variable "tags_name" {
  description = "Tag name for the instance"
  type        = string
  default     = "Azure-Agent" # Default instance name
}

# Define the Security Group name
variable "SG_name" {
  description = "Name of the Security Group"
  type        = string
  default     = "SG-for-Agent" # Default security group name for DevOps-related access
}
