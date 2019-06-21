# vim:ts=2:sw=2:et:

variable "tags" {
  description = ""
  type        = map
  default     = {}
}

variable "cluster_name"        {}
variable "cluster_name_suffix" {}

variable "cluster_version" {
  default = "1.12"
}

variable "cluster_vpc_id" {}

variable "cluster_vpc_config" {
  description = ""
  type        = object({
    subnet_ids              = list(string)
    endpoint_private_access = bool
    endpoint_public_access  = bool
  })
}

variable "cluster_logs_retention_days" {
  description = ""
  type        = number
  default     = 14
}

variable "cluster_log_types" {
  description = ""
  type        = list
  default     = [] # api, audit, authenticator, controllerManager, scheduler
}

variable "cluster_timeouts" {
  description = ""
  type        = object({
    create = string
    update = string
    delete = string
  })
  default      = {
    create = "15m"
    update = "60m"
    delete = "15m"
  }  
}

variable "iam_policies_cluster" {
  type    = list
  default = [
    "AmazonEKSClusterPolicy",
    "AmazonEKSServicePolicy",
  ]
}

variable "iam_policies_workers" {
  type    = list
  default = [
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly",
  ]
}


variable "cluster_sg_ingress" {
  type    = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    self            = bool
    cidr_blocks     = list(string)
    security_groups = list(string)
    description     = string
  }))
  default = []
}

variable "workers_sg_ingress" {
  type    = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    self            = bool
    cidr_blocks     = list(string)
    security_group  = string
    description     = string
  }))
  default = []
}

variable "worker_security_group_ids" {
  description = ""
  type        = list(string)
  default     = []
}

variable "workers_iam_assume_role_root_account" {
  description = ""
  type        = bool
  default     = false
}

variable "workers_iam_assume_role_policy" {
  description = ""
  type        = list(object({
    sid                    = string
    effect                 = string
    principals_type        = string
    principals_identifiers = list(string)
  }))
  default = []
}

