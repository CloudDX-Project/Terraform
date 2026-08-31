# ☁️ AWS EKS Cloud Infrastructure

## 1. 아키텍처 정보
- **Region**: ap-northeast-2 (Seoul)
- **Cluster**: Amazon EKS
- **Database**: Amazon RDS (MySQL)
- **Container Registry**: Amazon ECR (782913119640.dkr.ecr.ap-northeast-2.amazonaws.com)

## 2. 배포된 서비스 ALB 엔드포인트
- **Frontend ALB**: http://k8s-frontend-frontend-2b8d8dcf75-1900640687.ap-northeast-2.elb.amazonaws.com
- **Backend ALB**: http://k8s-backend-backendi-fa7f019576-179553335.ap-northeast-2.elb.amazonaws.com

## 3. 재배포 명령어 (Runbook)
### 백엔드 인프라 배포
```bash
kubectl apply -f infra/k8s/backend-config.yaml
kubectl apply -f infra/k8s/backend-deployment.yaml
kubectl apply -f infra/k8s/backend-service.yaml
kubectl apply -f infra/k8s/backend-ingress.yaml