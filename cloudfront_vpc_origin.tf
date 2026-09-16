# ==========================================
# CloudFront VPC Origin
# Internal ALB -> EKS Backend
# ==========================================

resource "aws_cloudfront_vpc_origin" "travel_api" {
  vpc_origin_endpoint_config {
    name = "ai-travel-api-vpc-origin"

    # Kubernetes AWS Load Balancer Controller가 생성한 Internal ALB
    arn = "arn:aws:elasticloadbalancing:ap-northeast-2:782913119640:loadbalancer/app/k8s-travel-travelap-15aff15a50/8b039c4201ee8b48"

    # Internal ALB Listener
    http_port  = 80
    https_port = 443

    # 현재 Internal ALB는 HTTP 80 Listener 사용
    origin_protocol_policy = "http-only"

    # Provider schema상 필요
    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }

  tags = {
    Name = "ai-travel-api-vpc-origin"
  }
}