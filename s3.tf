resource "aws_s3_bucket" "frontend" {
  bucket        = "ai-travel-planner-frontend-2026-bucket" # 전 세계 유일한 이름으로 변경 필요
  force_destroy = true

  tags = {
    Name = "ai-travel-frontend-bucket"
  }
}

# 프라이빗 유지 (퍼블릭 접근 차단)
resource "aws_s3_bucket_public_access_block" "frontend_block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}