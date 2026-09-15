# ==========================================
# RDS Variables
# ==========================================

variable "rds_password" {
  description = "RDS MariaDB master password"
  type        = string
  sensitive   = true
}