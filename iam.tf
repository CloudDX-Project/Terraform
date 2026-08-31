# =======================================================
# 1. IAM 사용자 정의 (팀원 4명)
# =======================================================
resource "aws_iam_user" "jun" {
  name = "jun"
  force_destroy = true
  tags = { Role = "Infra" }
}

resource "aws_iam_user" "soo" {
  name = "soo"
  force_destroy = true
  tags = { Role = "DevOps" }
}

resource "aws_iam_user" "chan" {
  name = "chan"
  force_destroy = true
  tags = { Role = "Backend" }
}

resource "aws_iam_user" "woo" {
  name = "woo"
  force_destroy = true
  tags = { Role = "Frontend" }
}

# =======================================================
# 2. 콘솔 로그인 프로필 설정
# =======================================================
resource "aws_iam_user_login_profile" "jun" {
  user                    = aws_iam_user.jun.name
  password_reset_required = false

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }
}

resource "aws_iam_user_login_profile" "soo" {
  user                    = aws_iam_user.soo.name
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

# =======================================================
# 3. 통합 관리자 그룹 생성 및 모든 팀원 배정
# =======================================================
resource "aws_iam_group" "team_admins" {
  name = "ai-travel-team-admins"
}

resource "aws_iam_group_membership" "team_admins_membership" {
  name  = "ai-travel-team-admins-membership"
  group = aws_iam_group.team_admins.name

  users = [
    aws_iam_user.jun.name,
    aws_iam_user.soo.name,
    aws_iam_user.chan.name,
    aws_iam_user.woo.name
  ]
}

# =======================================================
# 4. 모든 권한(AdministratorAccess) 부여
# =======================================================
resource "aws_iam_group_policy_attachment" "team_admins_full_access" {
  group      = aws_iam_group.team_admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}