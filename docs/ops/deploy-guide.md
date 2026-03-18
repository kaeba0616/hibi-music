# hibi 배포 가이드

## 개요

hibi 서비스의 배포 절차를 단계별로 정리한다.
로컬 → 스테이징 → 프로덕션 순서로 진행한다.

---

## 1. 로컬 개발 환경

### Docker Compose로 전체 스택 실행

```bash
# 프로젝트 루트에서
cp .env.example .env
# .env 파일에 필요한 값 설정

# 전체 스택 실행 (Backend + MySQL + Redis)
docker-compose up -d

# 로그 확인
docker-compose logs -f backend

# 중지
docker-compose down
```

### Backend만 실행 (MySQL은 Docker)

```bash
# MySQL + Redis만 실행
docker-compose up -d mysql redis

# Backend 직접 실행
cd hibi_backend
./gradlew bootRun
```

### Frontend 실행

```bash
cd hibi_front

# Mock 모드
flutter run --dart-define=USE_MOCK=true

# Real API 연동 (로컬 Backend)
flutter run --dart-define=USE_MOCK=false --dart-define=API_URL=http://localhost:8080
```

---

## 2. Docker 이미지 빌드

### Backend

```bash
cd hibi_backend

# 빌드
docker build -t hibi-backend:latest .

# 로컬 테스트
docker run -p 8080:8080 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=3306 \
  -e DB_NAME=hibi \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=password \
  -e JWT_SECRET=your-secret-key \
  hibi-backend:latest
```

### Frontend (Web 빌드)

```bash
cd hibi_front

# Web 빌드
flutter build web --dart-define=USE_MOCK=false --dart-define=API_URL=https://api.hibi.app

# APK 빌드
flutter build apk --dart-define=USE_MOCK=false --dart-define=API_URL=https://api.hibi.app
```

---

## 3. 스테이징 배포

### 옵션 A: Railway (추천 for MVP)

```bash
# Railway CLI 설치
npm install -g @railway/cli

# 로그인
railway login

# 프로젝트 초기화
cd hibi_backend
railway init

# 환경변수 설정
railway variables set DB_HOST=<mysql-host>
railway variables set DB_PORT=3306
railway variables set DB_NAME=hibi
railway variables set DB_USERNAME=<username>
railway variables set DB_PASSWORD=<password>
railway variables set JWT_SECRET=<secret>
railway variables set SPRING_PROFILES_ACTIVE=prod

# 배포
railway up
```

### 옵션 B: AWS ECS

```bash
# ECR에 이미지 푸시
aws ecr get-login-password --region ap-northeast-2 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com

docker tag hibi-backend:latest <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com/hibi-backend:latest
docker push <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com/hibi-backend:latest

# ECS 서비스 업데이트
aws ecs update-service \
  --cluster hibi-staging \
  --service hibi-backend \
  --force-new-deployment
```

---

## 4. 프로덕션 배포

### 배포 전 체크리스트

- [ ] 모든 테스트 통과 (`./gradlew test` + `flutter test`)
- [ ] CI/CD 파이프라인 Green
- [ ] 스테이징 환경에서 수동 검증 완료
- [ ] DB 마이그레이션 스크립트 확인
- [ ] 환경변수/Secret 모두 설정
- [ ] 롤백 계획 준비

### 배포 절차

1. **Git 태그 생성**
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

2. **Docker 이미지 빌드 & 푸시** (CI/CD가 자동 수행)
   ```bash
   docker build -t hibi-backend:v1.0.0 .
   docker push <registry>/hibi-backend:v1.0.0
   ```

3. **DB 마이그레이션** (필요 시)
   ```bash
   # JPA ddl-auto=validate로 설정 (프로덕션)
   # 마이그레이션은 Flyway 또는 수동 SQL로 실행
   ```

4. **배포 실행**
   ```bash
   # Railway
   railway up

   # 또는 AWS ECS
   aws ecs update-service --cluster hibi-prod --service hibi-backend --force-new-deployment
   ```

5. **배포 확인**
   ```bash
   # Health check
   curl https://api.hibi.app/actuator/health

   # 주요 API 확인
   curl https://api.hibi.app/api/v1/songs/today
   ```

---

## 5. 롤백 전략

### 즉시 롤백 (1분 이내)

```bash
# Railway: 이전 배포로 롤백
railway rollback

# AWS ECS: 이전 태스크 정의로 롤백
aws ecs update-service \
  --cluster hibi-prod \
  --service hibi-backend \
  --task-definition hibi-backend:<previous-revision>
```

### DB 롤백이 필요한 경우

1. 서비스 중지 또는 점검 모드 전환
2. RDS 스냅샷에서 복원
3. 이전 버전 이미지로 서비스 재시작

---

## 6. Flutter 앱 배포

### Android (Google Play)

```bash
cd hibi_front

# Release 빌드
flutter build appbundle \
  --dart-define=USE_MOCK=false \
  --dart-define=API_URL=https://api.hibi.app

# 출력: build/app/outputs/bundle/release/app-release.aab
```

Google Play Console에서 내부 테스트 → 비공개 테스트 → 프로덕션 순서로 출시.

### iOS (App Store)

```bash
cd hibi_front

# Release 빌드
flutter build ipa \
  --dart-define=USE_MOCK=false \
  --dart-define=API_URL=https://api.hibi.app

# Xcode에서 Archive → App Store Connect 업로드
```

---

## 7. 환경별 설정

### Backend (`application.yml`)

| 설정 | 개발 | 스테이징 | 프로덕션 |
|------|------|---------|---------|
| `spring.profiles.active` | dev | staging | prod |
| `spring.jpa.ddl-auto` | update | validate | validate |
| `spring.jpa.show-sql` | true | false | false |
| `logging.level.root` | DEBUG | INFO | WARN |
| `server.port` | 8080 | 8080 | 8080 |

### Frontend (dart-define)

| 변수 | 개발 | 스테이징 | 프로덕션 |
|------|------|---------|---------|
| `USE_MOCK` | true | false | false |
| `API_URL` | http://localhost:8080 | https://staging-api.hibi.app | https://api.hibi.app |
