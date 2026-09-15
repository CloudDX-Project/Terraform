resource "aws_iam_user" "jun" {
  name          = "jun"
  force_destroy = true
  tags          = { Role = "Infra" }
}


resource "aws_iam_user" "min" {
  name          = "min"
  force_destroy = true
  tags          = { Role = "DevOps" }
}

resource "aws_iam_user" "chan" {
  name          = "chan"
  force_destroy = true
  tags          = { Role = "Backend" }
}

resource "aws_iam_user" "woo" {
  name          = "woo"
  force_destroy = true
  tags          = { Role = "Frontend" }
}

resource "aws_iam_user_login_profile" "jun" {
  user                    = aws_iam_user.jun.name
  password_reset_required = false

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }
}

resource "aws_iam_user_login_profile" "min" {
  user                    = aws_iam_user.min.name
  password_reset_required = false

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }
}

resource "aws_iam_user_login_profile" "chan" {
  user                    = aws_iam_user.chan.name
  password_reset_required = false

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }
}

resource "aws_iam_user_login_profile" "woo" {
  user                    = aws_iam_user.woo.name
  password_reset_required = false

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }
}

resource "aws_iam_group" "team_admins" {
  name = "ai-travel-team-admins"
}

resource "aws_iam_group_membership" "team_admins_membership" {
  name  = "ai-travel-team-admins-membership"
  group = aws_iam_group.team_admins.name

  users = [
    aws_iam_user.jun.name,
    aws_iam_user.min.name,
    aws_iam_user.chan.name,
    aws_iam_user.woo.name
  ]
}

resource "aws_iam_group_policy_attachment" "team_admins_full_access" {
  group      = aws_iam_group.team_admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
# Cluster Autoscaler 권한 정책
resource "aws_iam_policy" "cluster_autoscaler" {
  name = "ai-travel-cluster-autoscaler-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# 주의: 아래 'aws_iam_role.EKS_NODE_ROLE_NAME.name' 부분은 
# 기존 iam.tf에 있는 EKS 노드 그룹 역할(Role) 이름으로 변경해야 합니다.
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.eks_node_role.name # <--- 이 부분에 적용 완료
}
# 오토스케일러용 IAM 역할 생성 및 OIDC 신뢰 관계 설정
resource "aws_iam_role" "cluster_autoscaler_role" {
  name = "ai-travel-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity",
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      },
      Condition = {
        "StringEquals" = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler-aws-cluster-autoscaler"
        }
      }
    }]
  })
}

# 역할에 권한(Policy) 연결
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach_oidc" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler_role.name
}