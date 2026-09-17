# ==========================================
# RDS Variables
# ==========================================

variable "rds_password" {
  description = "RDS MariaDB master password"
  type        = string
  sensitive   = true
}
# ==========================================
# Bedrock VPC Endpoint Enable / Disable
# 개발 환경에서는 비용 절감을 위해 비활성화
# ==========================================
variable "enable_bedrock_vpce" {
  description = "Whether to create the Bedrock Runtime VPC Interface Endpoint"
  type        = bool
  default     = false
}