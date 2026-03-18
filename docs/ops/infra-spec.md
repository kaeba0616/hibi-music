# hibi 인프라 설계

## 개요

hibi 서비스의 프로덕션 인프라 아키텍처를 정의한다.
MVP 단계에서는 비용 효율적인 구성을, 성장 단계에서는 확장 가능한 구성을 목표로 한다.

---

## 아키텍처 개요

```
[Client: Flutter App]
        │
        ▼
[CloudFront / CDN] ─── [S3: 정적 자산 / 이미지]
        │
        ▼
[ALB: Application Load Balancer]
        │
        ▼
[ECS Fargate / EC2: Spring Boot API]
        │
        ├── [RDS MySQL 8.0]
        ├── [ElastiCache Redis]
        └── [AWS SES: 이메일 발송]
```

---

## 환경 구성

### 개발 (Local)
| 컴포넌트 | 구성 |
|----------|------|
| Backend | `./gradlew bootRun` (포트 8080) |
| Database | Docker MySQL 8.0 (포트 3306) |
| Cache | Docker Redis 7 (포트 6379) |
| Frontend | `flutter run --dart-define=USE_MOCK=true` |

### 스테이징 (Staging)
| 컴포넌트 | 구성 |
|----------|------|
| Backend | ECS Fargate (1 task, 0.5 vCPU, 1GB) |
| Database | RDS MySQL db.t3.micro |
| Cache | ElastiCache t3.micro |
| 도메인 | staging.hibi.app |

### 프로덕션 (Production)
| 컴포넌트 | 구성 |
|----------|------|
| Backend | ECS Fargate (2+ tasks, 1 vCPU, 2GB) |
| Database | RDS MySQL db.t3.small (Multi-AZ) |
| Cache | ElastiCache t3.small |
| CDN | CloudFront |
| 스토리지 | S3 (이미지, 앨범 아트) |
| 이메일 | AWS SES |
| 도메인 | hibi.app |

---

## AWS 서비스 상세

### ECS Fargate (Backend)
- Spring Boot Docker 이미지 실행
- Auto Scaling: CPU 70% 기준
- Health check: `/actuator/health`
- 환경변수: AWS SSM Parameter Store에서 주입

### RDS MySQL 8.0
- 인스턴스: db.t3.micro (MVP) → db.t3.small (프로덕션)
- 스토리지: 20GB gp3 (자동 확장)
- 백업: 자동 백업 7일 보관
- Multi-AZ: 프로덕션만 활성화
- 파라미터 그룹: `character_set_server=utf8mb4`, `collation_server=utf8mb4_unicode_ci`

### ElastiCache Redis
- 용도: 이메일 인증번호 저장, 세션 캐시
- 인스턴스: cache.t3.micro
- 클러스터 모드: 비활성 (단일 노드)

### S3
- 버킷: `hibi-assets-{env}`
- 용도: 앨범 아트, 사용자 프로필 이미지, 게시글 이미지
- 접근: CloudFront 경유 (퍼블릭 직접 접근 차단)
- 라이프사이클: 임시 업로드 24시간 후 자동 삭제

### CloudFront
- Origin: S3 + ALB
- 캐싱: 이미지 7일, API 캐시 없음
- HTTPS 강제 (ACM 인증서)
- 커스텀 도메인: `cdn.hibi.app`

### AWS SES (이메일)
- 용도: 이메일 인증번호 발송
- 발신자: `noreply@hibi.app`
- 템플릿: 인증번호 이메일 HTML 템플릿
- 일일 발송 한도 확인 필요

---

## 네트워크 구성

### VPC
- CIDR: `10.0.0.0/16`
- 가용영역: 2개 (ap-northeast-2a, 2c)

### 서브넷
| 서브넷 | CIDR | 용도 |
|--------|------|------|
| Public-A | `10.0.1.0/24` | ALB, NAT Gateway |
| Public-C | `10.0.2.0/24` | ALB |
| Private-A | `10.0.11.0/24` | ECS, RDS |
| Private-C | `10.0.12.0/24` | ECS, RDS |

### 보안 그룹
| 이름 | 인바운드 | 아웃바운드 |
|------|---------|-----------|
| ALB-SG | 80, 443 (0.0.0.0/0) | All |
| ECS-SG | 8080 (ALB-SG) | All |
| RDS-SG | 3306 (ECS-SG) | None |
| Redis-SG | 6379 (ECS-SG) | None |

---

## 비용 예상 (월간, 서울 리전)

### MVP (최소 구성)
| 서비스 | 사양 | 예상 비용 |
|--------|------|----------|
| ECS Fargate | 0.5 vCPU, 1GB, 1 task | ~$15 |
| RDS MySQL | db.t3.micro | ~$15 |
| ElastiCache | cache.t3.micro | ~$13 |
| ALB | 1개 | ~$16 |
| S3 | 5GB | ~$1 |
| CloudFront | 10GB 전송 | ~$1 |
| **합계** | | **~$61/월** |

### PaaS 대안 (Railway)
| 항목 | 비용 |
|------|------|
| Backend (Railway) | ~$5-20/월 |
| MySQL (PlanetScale Free) | $0 |
| Redis (Upstash Free) | $0 |
| **합계** | **~$5-20/월** |

> MVP 단계에서는 Railway/Render 같은 PaaS가 비용 효율적.
> 사용자 1만명 이상 시 AWS 전환 권장.

---

## 대안: PaaS 빠른 배포 (추천 for MVP)

Railway를 사용한 빠른 배포:

```bash
# Backend 배포
railway init
railway link
railway up

# 환경변수 설정
railway variables set DB_HOST=...
railway variables set DB_PASSWORD=...
railway variables set JWT_SECRET=...
```

장점:
- 설정 최소화 (Dockerfile만 있으면 됨)
- 자동 HTTPS
- GitHub 연동 자동 배포
- 무료 티어로 시작 가능

---

## Secret 관리

### 필수 Secret 목록
| Key | 설명 | 저장소 |
|-----|------|--------|
| `DB_HOST` | MySQL 호스트 | SSM / Railway |
| `DB_PORT` | MySQL 포트 | SSM / Railway |
| `DB_NAME` | 데이터베이스 이름 | SSM / Railway |
| `DB_USERNAME` | DB 사용자명 | SSM / Railway |
| `DB_PASSWORD` | DB 비밀번호 | SSM / Railway |
| `JWT_SECRET` | JWT 서명 키 | SSM / Railway |
| `REDIS_HOST` | Redis 호스트 | SSM / Railway |
| `KAKAO_CLIENT_ID` | 카카오 앱 키 | SSM / Railway |
| `KAKAO_CLIENT_SECRET` | 카카오 시크릿 | SSM / Railway |
| `GOOGLE_CLIENT_ID` | 구글 OAuth ID | SSM / Railway |
| `GOOGLE_CLIENT_SECRET` | 구글 OAuth 시크릿 | SSM / Railway |
| `NAVER_CLIENT_ID` | 네이버 앱 키 | SSM / Railway |
| `NAVER_CLIENT_SECRET` | 네이버 시크릿 | SSM / Railway |
| `SES_ACCESS_KEY` | AWS SES 키 | SSM / Railway |
| `SES_SECRET_KEY` | AWS SES 시크릿 | SSM / Railway |

### GitHub Secrets (CI/CD용)
- `DOCKER_USERNAME` / `DOCKER_PASSWORD` - Docker Hub 인증
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` - AWS 배포용
- 또는 `RAILWAY_TOKEN` - Railway 배포용
