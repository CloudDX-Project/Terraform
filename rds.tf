# ==========================================
# 1. RDS 서브넷 그룹
# 현재는 Private App Subnet A/B 사용
# DB 전용 Subnet은 다음 단계에서 분리 예정
# ==========================================
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "ai-travel-rds-subnet-group"
  description = "RDS DB subnet group in private subnets"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "ai-travel-rds-subnet-group"
  }
}


# ==========================================
# 2. RDS 전용 Security Group
# EKS Worker/Pod -> MariaDB 3306 허용
# ==========================================
resource "aws_security_group" "rds_sg" {
  name = "ai-travel-rds-sg"

  # 기존 SG replacement 방지를 위해 기존 description 유지
  description = "Allow inbound traffic from Backend only"

  vpc_id = aws_vpc.main.id

  # EKS Cluster Security Group에서
  # MariaDB 3306 접근 허용
  ingress {
    description = "MariaDB from EKS workloads"

    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [
      aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
    ]
  }

  # Outbound 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ai-travel-rds-sg"
  }
}


# ==========================================
# 3. Amazon RDS for MariaDB
# Multi-AZ
# ==========================================
resource "aws_db_instance" "mariadb" {
  identifier = "ai-travel-mariadb"

  # ------------------------------------------
  # Database Engine
  # ------------------------------------------
  engine         = "mariadb"
  engine_version = "10.11"

  # ------------------------------------------
  # Instance / Storage
  # ------------------------------------------
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  # ------------------------------------------
  # Database Account
  # ------------------------------------------
  db_name  = "aitravel"
  username = "admin"

  # 실제 비밀번호는 terraform.tfvars에서 관리
  password = var.rds_password

  # ------------------------------------------
  # High Availability
  # ------------------------------------------
  multi_az = true

  # ------------------------------------------
  # Network
  # ------------------------------------------
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  publicly_accessible = false

  # ------------------------------------------
  # 현재 개발 단계 설정
  # 추후 Backup / PITR / KMS / Protection 강화 예정
  # ------------------------------------------
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "ai-travel-mariadb-instance"
  }
}


# ==========================================
# 4. Outputs
# 백엔드 팀 전달용
# ==========================================
output "rds_endpoint" {
  description = "MariaDB endpoint address"
  value       = aws_db_instance.mariadb.address
}

output "rds_port" {
  description = "MariaDB port"
  value       = aws_db_instance.mariadb.port
}

# ==========================================
# RDS Dedicated DB Subnet Group
# 현재 MariaDB는 아직 이 그룹으로 이동하지 않음
# ==========================================
resource "aws_db_subnet_group" "rds_dedicated_subnet_group" {
  name        = "ai-travel-rds-dedicated-subnet-group"
  description = "Dedicated private DB subnets for AI Travel MariaDB"

  subnet_ids = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]

  tags = {
    Name = "ai-travel-rds-dedicated-subnet-group"
  }
}