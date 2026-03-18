# hibi 프로덕션 준비 가이드

## 개요

Phase 1~4 기능 구현 100% 완료 (18/18 Features).
이 문서는 프로덕션 배포까지 필요한 모든 작업을 정리한다.

---

## 현재 상태

| 항목 | 상태 | 비고 |
|------|------|------|
| 기능 구현 | ✅ 완료 | 18개 Feature |
| 테스트 | ✅ 통과 | Backend BUILD SUCCESSFUL + Frontend 318/318 |
| Mock → Real 전환 | ❌ 미완료 | 소셜 로그인, 이메일 인증이 Mock |
| CI/CD | ✅ 완료 | GitHub Actions 설정됨 |
| Docker | ✅ 완료 | Dockerfile + docker-compose 설정됨 |
| 인프라/배포 | ❌ 미설정 | AWS 설계 필요 |
| 법무 문서 | ❌ 미작성 | 이용약관, 개인정보 처리방침 |
| 모니터링 | ❌ 미설정 | Actuator 의존성은 있음 |

---

## Stage 1: Mock 제거 & 실제 구현

### 1-1. JWT 인증 필터 수정
- **파일**: `hibi_backend/src/main/java/com/hibi/server/domain/auth/jwt/JwtAuthenticationFilter.java`
- **문제**: `//TODO : 항상 401 에러가 뜨는 것 바꾸기` (Line 50)
- **영향**: 모든 인증 필요 API가 비정상 동작
- **해결**: SecurityContext 설정 로직 점검, 토큰 파싱/검증 플로우 디버깅

### 1-2. 이메일 인증 실제 구현
- **파일**: `hibi_backend/src/main/java/com/hibi/server/domain/auth/controller/AuthController.java` (Line 112-113)
- **현재**: 인증번호 하드코딩 ("123456" 항상 성공)
- **필요 작업**:
  - [ ] `VerificationService.java` 생성 - 6자리 랜덤 인증번호 생성/저장/검증
  - [ ] `EmailService.java` 생성 - 이메일 발송 (AWS SES 또는 SendGrid)
  - [ ] Redis 의존성 추가 (`spring-boot-starter-data-redis`)
  - [ ] `application.yml`에 메일 서버 설정 추가
  - [ ] 인증번호 만료 시간 설정 (5분)

### 1-3. 소셜 로그인 실제 연동
- **파일**: `hibi_backend/src/main/java/com/hibi/server/domain/auth/service/SocialAuthService.java` (Line 115-125)
- **현재**: accessToken 해시값으로 Mock 사용자 정보 생성
- **필요 작업**:
  - [ ] 카카오 개발자 등록 + 앱 키 발급 (https://developers.kakao.com)
  - [ ] 구글 OAuth 클라이언트 등록 (https://console.cloud.google.com)
  - [ ] 네이버 개발자 등록 + 앱 키 발급 (https://developers.naver.com)
  - [ ] `KakaoAuthClient.java` 생성
  - [ ] `GoogleAuthClient.java` 생성
  - [ ] `NaverAuthClient.java` 생성
  - [ ] `application.yml`에 OAuth 키 설정 추가
  - [ ] WebClient 또는 RestTemplate으로 각 플랫폼 API 호출

### 1-4. 프론트엔드 TODO 정리 (26개)

**Real API 전환 필요 (3개)**:
- [ ] `search_repo.dart:256` - 인기 검색어 API 연동
- [ ] `push_notification_tile.dart:48,68` - 푸시 알림 설정 API 연동
- [ ] `my_comments_viewmodel.dart:50` - 내가 쓴 댓글 API 연동

**화면 이동 연결 필요 (14개)**:
- [ ] `home_view.dart:74` - 프로필 화면 이동
- [ ] `comment_section.dart:130,153` - 프로필 화면 이동
- [ ] `comment_section.dart:156` - 원 댓글 스크롤
- [ ] `user_profile_view.dart:86` - 프로필 수정 화면
- [ ] `feed_view.dart:140,215` - 노래 상세 화면
- [ ] `feed_view.dart:178` - 검색 화면 이동
- [ ] `post_detail_view.dart:159` - 노래 상세 화면
- [ ] `post_detail_view.dart:192` - 프로필 화면 이동
- [ ] `post_detail_view.dart:401` - 신고 화면 이동

**기능 구현 필요 (9개)**:
- [ ] `song_viewmodel.dart:11` - build 구현
- [ ] `song_list_viewmodel.dart:11` - build 구현
- [ ] `user_profile_view.dart:117` - 좋아요 토글
- [ ] `user_profile_view.dart:161` - 신고 기능
- [ ] `feed_view.dart:210` - 좋아요 토글
- [ ] `post_create_view.dart:197,231` - 이미지 선택
- [ ] `post_edit_view.dart:143,222` - 이미지 선택
- [ ] `post_detail_view.dart:376` - 공유 기능

---

## Stage 2: CI/CD 파이프라인 ✅

- `.github/workflows/backend-ci.yml` - Java 17 + Gradle test + build
- `.github/workflows/frontend-ci.yml` - Flutter test + analyze + format

---

## Stage 3: Docker & 로컬 개발환경 ✅

- `hibi_backend/Dockerfile` - Spring Boot 멀티스테이지 빌드
- `docker-compose.yml` - Backend + MySQL + Redis
- `.env.example` - 환경변수 템플릿

---

## Stage 4: 인프라 & 배포

### 4-1. 인프라 설계
- [ ] `docs/ops/infra-spec.md` 작성
- 옵션 A (AWS): EC2/ECS + RDS(MySQL) + ElastiCache(Redis) + S3 + CloudFront
- 옵션 B (PaaS): Railway/Render로 빠른 MVP 배포

### 4-2. 배포 가이드
- [ ] `docs/ops/deploy-guide.md` 작성
- 로컬 → 스테이징 → 프로덕션 단계별 절차
- 롤백 전략

### 4-3. 모니터링
- [ ] `docs/ops/monitoring-alerting.md` 작성
- Spring Boot Actuator (이미 의존성 있음) 활성화
- Prometheus + Grafana 또는 AWS CloudWatch
- Sentry 에러 트래킹

---

## Stage 5: 보안 & 법무

### 5-1. 보안 문서화
- [ ] `docs/tech/security-rbac.md` 작성
- Spring Security 설정 정리
- RBAC 모델 (USER, ADMIN)
- API 접근 제어 매트릭스
- 민감정보 처리 정책

### 5-2. 법무 문서
- [ ] `docs/legal/terms-of-service.md` - 이용약관
- [ ] `docs/legal/privacy-policy.md` - 개인정보 처리방침
- JPOP 음원/가사 저작권 주의사항

### 5-3. 운영 매뉴얼
- [ ] `docs/ops/runbook.md` - 장애 대응, DB 백업, 롤백

---

## Stage 6: 에뮬레이터 UI 검증 & QA

`docs/ops/emulator-test-guide.md` 참조

---

## Stage 7: Phase 6 기획

### 후보 기능 (Notion "기획 중")

| 기능 | 난이도 | 비즈니스 가치 | 추천 순서 |
|------|--------|-------------|---------|
| 즐겨찾기 (북마크) | 낮음 | 높음 | 1순위 |
| 알림 센터 | 중간 | 높음 | 2순위 |
| 음악 추천 알고리즘 | 높음 | 매우 높음 | 3순위 |
| 사용자 프로필 커스텀 | 낮음 | 중간 | 4순위 |

---

## 전체 타임라인

| Stage | 예상 기간 | 선행 조건 |
|-------|----------|----------|
| Stage 1 | 3-5일 | - |
| Stage 2 | ✅ 완료 | - |
| Stage 3 | ✅ 완료 | - |
| Stage 4 | 2-3일 | Stage 3 |
| Stage 5 | 1-2일 | Stage 4와 병렬 |
| Stage 6 | 1-2일 | Stage 1과 병렬 |
| Stage 7 | 별도 | Stage 4 이후 |
