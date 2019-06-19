# vim:ts=2:sw=2:et:

resource "aws_iam_role" "cluster" {
  name                  = "eks-cluster-${var.cluster_name_suffix}"
  assume_role_policy    = data.aws_iam_policy_document.assume-role-cluster.json
  path                  = "/"
  force_detach_policies = true

  tags = merge(
    var.tags,
    map("role", "eks-cluster"),
  )
}

resource "aws_iam_role_policy_attachment" "cluster" {
  count = length(var.iam_policies_cluster)

  role       = aws_iam_role.cluster.name
  policy_arn = data.aws_iam_policy.cluster[count.index].arn
}

resource "aws_iam_role" "workers" {
  name                  = "eks-workers-${var.cluster_name_suffix}"
  assume_role_policy    = data.aws_iam_policy_document.assume-role-workers.json
  path                  = "/"
  force_detach_policies = true
  
  tags = merge(
    var.tags,
    map("role", "eks-worker"),
  )
}

resource "aws_iam_instance_profile" "workers" {
  name = "eks-workers-${var.cluster_name_suffix}"
  role = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers" {
  count = length(var.iam_policies_workers)

  role       = aws_iam_role.workers.name
  policy_arn = data.aws_iam_policy.workers[count.index].arn
}

resource "aws_iam_role_policy" "workers-policies" {
  name   = "workers-policies"
  role   = aws_iam_role.workers.name
  policy = data.aws_iam_policy_document.workers-policies.json
}

data "aws_iam_policy_document" "assume-role-cluster" {
  statement {
    sid = "EKSAssumeRole"
    effect  = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "eks.amazonaws.com" ]
    }
  }
}

data "aws_iam_policy_document" "assume-role-workers" {
  statement {
    sid = "AssumeRole"
    effect  = "Allow"
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ 
        "ec2.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy" "cluster" {
  count = length(var.iam_policies_cluster)
  arn   = "arn:aws:iam::aws:policy/${element(var.iam_policies_cluster, count.index)}"
}

data "aws_iam_policy" "workers" {
  count = length(var.iam_policies_workers)
  arn   = "arn:aws:iam::aws:policy/${element(var.iam_policies_workers, count.index)}"
}

data "aws_iam_policy_document" "workers-policies" {
  statement {
    sid     = "Kube2IAM"
    effect  = "Allow"
    actions = [ 
      "sts:AssumeRole",
    ]
    resources = [ "*" ]
  }

  statement {
    sid     = "EC2Describe"
    effect  = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:CreateTags",
    ]
    resources = [ "*" ]
  }
}

# FIXME: autoscaling role/policy

output "iam_roles" {
  value = {
    cluster = aws_iam_role.cluster
    workers = aws_iam_role.workers
  }
}

output "iam_instance_profiles" {
  value = {
    workers = aws_iam_instance_profile.workers
  }
}
