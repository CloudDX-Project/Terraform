# ==========================================
# 1. Bedrock VPC 엔드포인트 전용 보안 그룹
# ==========================================
resource "aws_security_group" "bedrock_vpce_sg" {
  name        = "ai-travel-bedrock-vpce-sg"
  description = "Allow HTTPS inbound traffic from Backend to Bedrock endpoint"
  vpc_id      = aws_vpc.main.id

  # 백엔드 보안 그룹(backend_sg)에서의 443(HTTPS) 요청 허용
  ingress {
    description     = "HTTPS from Backend SG"
    from_port       = 443
    to_port         = 443
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
    Name = "ai-travel-bedrock-vpce-sg"
  }
}

# ==========================================
# 2. Bedrock Runtime VPC Interface Endpoint (PrivateLink)
# ==========================================
resource "aws_vpc_endpoint" "bedrock_runtime" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-2.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.bedrock_vpce_sg.id]
  private_dns_enabled = true # private DNS를 켜두면 기존 SDK 코드 수정 없이 자동으로 사설망 경유

  tags = {
    Name = "ai-travel-bedrock-runtime-vpce"
  }
}