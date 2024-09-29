variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-west-1" # Change as needed
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.2.0/24"
}

variable "ami_public" {
  description = "AMI ID for the public instance"
  default     = "ami-09fd16644beea3565" # Change as needed
}

variable "ami_private" {
  description = "AMI ID for the private instance"
  default     = "ami-00aa9d3df94c6c354" # Change as needed
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type = list(string)
  default = ["us-west-2a, us-west-2b"]
}
