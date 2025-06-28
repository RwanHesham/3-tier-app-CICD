variable "vpc_cidr" {
    description = "CIDR for the vpc"
    type = string
    default = "10.10.0.0/16"
}

variable "cluster_name" {
    description = "name of cluster"
    type = string
    default = eks-cluster
}

variable "public_subnet_cidr" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
 
}

variable "availability_zones" {
  description = "List of AWS availability zones to deploy the subnets in"
  type        = list(string)
  
}
