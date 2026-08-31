# ==========================================
# 1. CloudFront Origin Access Control (OAC) 생성
# ==========================================
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "ai-travel-frontend-oac"
  description                       = "OAC for AI Travel Frontend S3 Bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ==========================================
# 2. CloudFront Distribution 생성
# ==========================================
resource "aws_cloudfront_distribution" "frontend_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "AI Travel Frontend CloudFront Distribution"

  # S3 오리진 설정 (OAC 적용)
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.frontend.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  # 기본 캐시 동작 (HTTPS 리디렉션)
  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.frontend.id}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    # AWS 기본 캐시 최적화 정책 (CachingOptimized)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    compress = true
  }

  # React SPA 라우팅용 에러 응답 처리 (403, 404 발생 시 index.html 반환)
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  # 엣지 로케이션 가격 등급 (한국/아시아/미국/유럽 포함 최적화)
  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # 기본 CloudFront 인증서 사용 (추후 Route 53 연동 시 ACM 인증서로 변경 가능)
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "ai-travel-frontend-cf"
  }
}

# ==========================================
# 3. S3 버킷 정책 (CloudFront OAC 접근만 허용)
# ==========================================
data "aws_iam_policy_document" "s3_oac_policy" {
  statement {
    sid       = "AllowCloudFrontServicePrincipalReadOnly"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.s3_oac_policy.json
}

# ==========================================
# 4. 프론트엔드 팀원 전달용 접속 주소 출력
# ==========================================
output "cloudfront_domain_name" {
  description = "프론트엔드 웹 서비스 접속 URL"
  value       = "https://${aws_cloudfront_distribution.frontend_distribution.domain_name}"
}