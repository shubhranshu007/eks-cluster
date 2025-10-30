variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-default-cluster-DR"
}

variable "node_instance_type" {
  description = "Worker node instance type"
  type        = string
  default     = "t3.small"
}

variable "eks_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}
