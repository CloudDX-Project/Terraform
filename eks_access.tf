# =======================================================
# 1. EKS 접근을 허용할 팀원 IAM ARN 정의
# =======================================================
locals {
  eks_admin_users = [
    "arn:aws:iam::782913119640:user/jun",  # 인프라 담당
    "arn:aws:iam::782913119640:user/soo",  # 데브옵스/CI/CD 담당
    "arn:aws:iam::782913119640:user/chan", # 백엔드 개발 담당
  ]
}

# =======================================================
# 2. EKS Access Entry 생성 (IAM 사용자 등록)
# =======================================================
resource "aws_eks_access_entry" "team_access" {
  for_each      = toset(local.eks_admin_users)
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
  type          = "STANDARD"
}

# =======================================================
# 3. 클러스터 관리자 정책 연결 (AmazonEKSClusterAdminPolicy)
# =======================================================
resource "aws_eks_access_policy_association" "team_admin_policy" {
  for_each      = toset(local.eks_admin_users)
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.team_access]
}