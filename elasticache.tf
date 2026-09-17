# ==========================================
# 1. ElastiCache 서브넷 그룹 (Private Subnet A, B)
# ==========================================
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "ai-travel-redis-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "ai-travel-redis-subnet-group"
  }
}

# ==========================================
# Redis Dedicated Cache Subnet Group
# 현재 Redis는 아직 이 그룹으로 이동하지 않음
# ==========================================
resource "aws_elasticache_subnet_group" "redis_dedicated_subnet_group" {
  name = "ai-travel-redis-dedicated-subnet-group"

  subnet_ids = [
    aws_subnet.cache_a.id,
    aws_subnet.cache_b.id
  ]

  tags = {
    Name = "ai-travel-redis-dedicated-subnet-group"
  }
}

# ==========================================
# 2. Redis 전용 보안 그룹 (백엔드 SG에서만 6379 포트 허용)
# ==========================================
resource "aws_security_group" "redis_sg" {
  name        = "ai-travel-redis-sg"
  description = "Allow inbound traffic from Backend only to Redis"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis port from Backend SG"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"

    security_groups = [
      aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ai-travel-redis-sg"
  }
}
# ==========================================
# 3. Amazon ElastiCache for Redis 클러스터
# ==========================================
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "ai-travel-redis"
  engine               = "redis"
  engine_version       = "7.1"            # Redis 최신 안정 버전
  node_type            = "cache.t3.micro" # 비용 절감형 인스턴스
  num_cache_nodes      = 1                # 싱글 노드 구성
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.redis_sg.id]

  tags = {
    Name = "ai-travel-redis-cluster"
  }
}

# ==========================================
# 4. 백엔드 팀원 전달용 접속 정보 출력
# ==========================================
output "redis_endpoint" {
  description = "Redis 엔드포인트 호스트 주소"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis 포트 번호"
  value       = aws_elasticache_cluster.redis.port
}