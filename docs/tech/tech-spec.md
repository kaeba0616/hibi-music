# hibi 기술 스펙

## 1. 아키텍처 개요

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│  Spring Boot    │────▶│     MySQL       │
│  (Frontend)     │◀────│  (Backend)      │◀────│   (Database)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │
        │                       │
        ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│  Local Storage  │     │  AWS EC2        │
│  (Secure)       │     │  (Deployment)   │
└─────────────────┘     └─────────────────┘
```

---

## 2. Frontend (Flutter)

### 2.1 기술 스택
| 항목 | 기술 | 버전 |
|------|------|------|
| Framework | Flutter | 3.29.2 |
| Language | Dart | 3.x |
| State Management | Riverpod | 3.0.0-dev.15 |
| Routing | go_router | 15.1.1 |
| HTTP Client | Dio | 5.8.0 |
| Local Storage | SharedPreferences | 2.2.3 |
| Secure Storage | flutter_secure_storage | 9.2.4 |

### 2.2 프로젝트 구조
```
hibi_front/lib/
├── main.dart                 # 앱 진입점
├── router.dart               # go_router 설정
├── env.dart                  # 환경 변수
├── constants/                # 상수
└── features/                 # Feature 모듈
    ├── authentication/       # F1: Auth
    ├── daily-song/          # F2: Daily Song
    ├── artists/             # F3: Artist
    ├── calendar/            # F4: Calendar
    ├── posts/               # F5: Post
    ├── follow/              # F7: Follow
    └── common/              # 공통 컴포넌트
```

### 2.3 Feature 모듈 구조
```
features/{feature}/
├── models/           # 데이터 모델
├── mocks/            # Mock 데이터
├── repos/            # Repository (API 호출)
├── viewmodels/       # Riverpod ViewModel
├── views/            # Flutter Widget
└── widgets/          # 재사용 컴포넌트
```

### 2.4 상태 관리 패턴
```dart
// StateNotifier 패턴
class FeatureViewModel extends StateNotifier<FeatureState> {
  final FeatureRepository _repo;

  FeatureViewModel(this._repo) : super(FeatureState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repo.getAll();
      state = state.copyWith(items: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

---

## 3. Backend (Spring Boot)

### 3.1 기술 스택
| 항목 | 기술 | 버전 |
|------|------|------|
| Framework | Spring Boot | 3.4.5 |
| Language | Java | 17 |
| ORM | JPA/Hibernate | - |
| Database | MySQL | 8.x |
| Security | Spring Security + JWT | - |
| Documentation | Springdoc OpenAPI | 2.8.9 |
| Build | Gradle | - |

### 3.2 프로젝트 구조
```
hibi_backend/src/main/java/com/hibi/server/
├── HibiApplication.java      # 앱 진입점
├── domain/                   # 도메인 모듈
│   ├── artist/
│   ├── auth/
│   ├── comment/
│   ├── follow/
│   ├── member/
│   ├── post/
│   ├── song/
│   └── songlike/
└── global/                   # 전역 설정
    ├── config/              # Configuration
    ├── exception/           # 예외 처리
    ├── response/            # 응답 래퍼
    └── security/            # 보안 설정
```

### 3.3 도메인 모듈 구조
```
domain/{feature}/
├── entity/           # JPA Entity
├── repository/       # Spring Data JPA Repository
├── dto/
│   ├── request/     # 요청 DTO
│   └── response/    # 응답 DTO
├── service/          # 비즈니스 로직
└── controller/       # REST Controller
```

### 3.4 API 응답 형식
```java
// 성공 응답
{
  "success": true,
  "message": "조회 성공",
  "data": { ... }
}

// 에러 응답
{
  "success": false,
  "message": "에러 메시지",
  "code": "ERROR_CODE"
}
```

---

## 4. Database

### 4.1 MySQL 설정
- Character Set: utf8mb4
- Collation: utf8mb4_unicode_ci
- Time Zone: Asia/Seoul

### 4.2 주요 테이블
- `members`: 사용자
- `artists`: 아티스트
- `songs`: 노래
- `song_likes`: 노래 좋아요
- `posts`: 게시글
- `comments`: 댓글
- `follows`: 팔로우

### 4.3 ERD
별도 파일 참조: `docs/tech/db-schema.md`

---

## 5. 인증/인가

### 5.1 JWT 구조
```
Header: { "alg": "HS256", "typ": "JWT" }
Payload: { "sub": "user_id", "exp": timestamp, "roles": [...] }
```

### 5.2 토큰 만료 시간
- Access Token: 1시간 (3600000ms)
- Refresh Token: 70일 (6048000000ms)

### 5.3 인증 Flow
```
1. 로그인 → Access Token + Refresh Token 발급
2. API 요청 → Authorization: Bearer {access_token}
3. Access Token 만료 → Refresh Token으로 재발급
4. Refresh Token 만료 → 재로그인 필요
```

---

## 6. CI/CD

### 6.1 GitHub Actions

#### Backend (.github/workflows/build-deploy.yml)
```yaml
on:
  push:
    branches: [dev]
jobs:
  build-and-deploy:
    - Gradle build
    - Run tests
    - Deploy to EC2 via SSH
```

#### Frontend (.github/workflows/ci.yml)
```yaml
on:
  pull_request:
    branches: [main]
jobs:
  lint:
    - flutter pub get
    - dart format --set-exit-if-changed .
```

---

## 7. 환경 변수

### Backend (application.yml)
```yaml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
jwt:
  secret: ${JWT_SECRET}
```

### Frontend (.env)
```
BASE_URL=https://api.hibi.app
USE_MOCK=false
```
