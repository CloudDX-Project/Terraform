# ==========================================
# 1. RDS 서브넷 그룹 (Private Subnet A, B)
# ==========================================
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "ai-travel-rds-subnet-group"
  description = "RDS DB subnet group in private subnets"
  subnet_ids  = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "ai-travel-rds-subnet-group"
  }
}

# ==========================================
# 2. RDS 전용 보안 그룹 (백엔드 SG에서만 3306 허용)
# ==========================================
resource "aws_security_group" "rds_sg" {
  name        = "ai-travel-rds-sg"
  description = "Allow inbound traffic from Backend only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MariaDB port from Backend SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

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
# 3. Amazon RDS for MariaDB (Multi-AZ)
# ==========================================
resource "aws_db_instance" "mariadb" {
  identifier             = "ai-travel-mariadb"
  engine                 = "mariadb"
  engine_version         = "10.11"        # 10.11 최신 안정화 버전
  instance_class         = "db.t3.micro"  # 프리티어 / 비용 절감형 인스턴스
  allocated_storage      = 20             # 기본 용량 (20GB)
  max_allocated_storage  = 100            # 스토리지 자동 확장
  storage_type           = "gp3"

  db_name                = "aitravel"
  username               = "admin"
  password               = "samadal1!"    # RDS 허용 특수문자(!)로 변경

  multi_az               = true           # Multi-AZ 활성화
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible    = false          # Private Subnet 격리 유지
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "ai-travel-mariadb-instance"
  }
}

# ==========================================
# 4. 백엔드 팀원 전달용 접속 정보 출력
# ==========================================
output "rds_endpoint" {
  description = "MariaDB 엔드포인트 주소"
  value       = aws_db_instance.mariadb.address
}

output "rds_port" {
  description = "MariaDB 포트 번호"
  value       = aws_db_instance.mariadb.port
}