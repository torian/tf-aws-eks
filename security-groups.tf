
resource "aws_security_group" "cluster" {
  name        = "eks-cluster-${var.cluster_name_suffix}-sg"
  description = "EKS cluster security group"
  vpc_id      = var.cluster_vpc_id
  tags        = merge(
    var.tags, 
    map("Name", "eks-cluster-${var.cluster_name_suffix}-sg")
  )

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  dynamic "ingress" {
    iterator = r
    for_each = [ for i in local.cluster_sg_ingress: {
      from_port       = i.from_port
      to_port         = i.to_port
      protocol        = i.protocol
      self            = i.self
      cidr_blocks     = i.cidr_blocks
      security_groups = i.security_groups
      description     = i.description
    }]
  
    content {
      from_port       = r.value.from_port
      to_port         = r.value.to_port
      protocol        = r.value.protocol
      self            = r.value.self
      cidr_blocks     = r.value.cidr_blocks
      security_groups = r.value.security_groups
      description     = r.value.description
    }
  }
}

resource "aws_security_group" "workers" {
  name        = "eks-workers-${var.cluster_name_suffix}-sg"
  description = "EKS workers security group"
  vpc_id      = var.cluster_vpc_id
  tags        = merge(
    var.tags, 
    map("Name", "eks-workers-${var.cluster_name_suffix}-sg")
  )

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group_rule" "workers" {
  count = length(local.workers_sg_ingress)
  
  security_group_id         = aws_security_group.workers.id
  type                      = "ingress"
  from_port                 = local.workers_sg_ingress[count.index]["from_port"]
  to_port                   = local.workers_sg_ingress[count.index]["to_port"]
  protocol                  = local.workers_sg_ingress[count.index]["protocol"]
  self                      = local.workers_sg_ingress[count.index]["self"]
  cidr_blocks               = local.workers_sg_ingress[count.index]["cidr_blocks"]
  source_security_group_id  = local.workers_sg_ingress[count.index]["security_group"]
  description               = local.workers_sg_ingress[count.index]["description"]
}

output "security-groups" {
  value = {
    cluster = aws_security_group.cluster
    workers = aws_security_group.workers
  }
}

