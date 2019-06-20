# vim:ts=2:sw=2:et:

locals {
  cluster_name = "${var.cluster_name}-${var.cluster_name_suffix}"

  worker_security_group_ids = concat(
    list(aws_security_group.workers.id),
    var.worker_security_group_ids,
  )

  cluster_sg_ingress = concat(
    [
      {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        self            = false
        cidr_blocks     = []
        security_groups = [ aws_security_group.workers.id ]
        description     = "EKS cluster - workers communication"
      },
    ],
    var.cluster_sg_ingress,
  )

  workers_sg_ingress = concat(
    [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        self            = true
        cidr_blocks     = []
        security_group  = ""
        description     = "EKS worker nodes communication"
      },
      {
        from_port       = 1025
        to_port         = 65535
        protocol        = "tcp"
        self            = false
        cidr_blocks     = []
        security_group  = aws_security_group.cluster.id
        description     = "EKS control plane"
      },
    ],
    var.workers_sg_ingress,
  )

  workers_iam_assume_role_policy = var.workers_iam_assume_role_root_account ? concat(
    [
      {
        sid                    = "RootAccountAssumeRole"
        effect                 = "Allow"
        principals_type        = "AWS"
        principals_identifiers = [ "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" ]
      }
    ],
    var.workers_iam_assume_role_policy
  ) : []

  tags_worker_groups = merge(
    map("kubernetes.io/cluster/${aws_eks_cluster.cluster.name}",     "true"),
    map("k8s.io/cluster-autoscaler/${aws_eks_cluster.cluster.name}", "true"),
    var.tags,
  )
}

