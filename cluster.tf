# vim:ts=2:sw=2:et:

resource "aws_eks_cluster" "cluster" {
  name                      = local.cluster_name
  enabled_cluster_log_types = var.cluster_log_types
  role_arn                  = aws_iam_role.cluster.arn
  version                   = var.cluster_version

  vpc_config {
    security_group_ids      = [ aws_security_group.cluster.id ]
    subnet_ids              = var.cluster_vpc_config.subnet_ids
    endpoint_private_access = var.cluster_vpc_config.endpoint_private_access
    endpoint_public_access  = var.cluster_vpc_config.endpoint_public_access
  }

  timeouts {
    create = var.cluster_timeouts.create
    update = var.cluster_timeouts.update
    delete = var.cluster_timeouts.delete
  }
}

output "cluster" {
  value = aws_eks_cluster.cluster
}

