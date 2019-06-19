# vim:ts=2:sw=2:et:

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.cluster_logs_retention_days

  tags = var.tags
}

