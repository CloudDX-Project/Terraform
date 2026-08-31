resource "aws_iam_user" "jun" {
  name          = "jun"
  force_destroy = true
  tags          = { Role = "Infra" }
}

resource "aws_iam_user" "soo" {
  name          = "soo"
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

resource "aws_iam_group_policy_attachment" "team_admins_full_access" {
  group      = aws_iam_group.team_admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}