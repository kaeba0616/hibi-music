# hibi QA 실행 계획서

## 개요

이 문서는 hibi 프로젝트의 테스트 및 QA 작업을 위한 상세 실행 계획입니다.

**예상 기간**: 4주
**목표 커버리지**: Backend 70%, Frontend 60%

---

## Phase 1: 테스트 인프라 구축 (Day 1-2)

### 1.1 Backend 테스트 환경 설정

#### Task 1.1.1: application-test.yml 생성
```yaml
# src/main/resources/application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    username: sa
    password:
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
    properties:
      hibernate:
        format_sql: true
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: test-client-id
            client-secret: test-client-secret

jwt:
  secret: test-jwt-secret-key-for-testing-purposes-only-32chars
  access-expiration: 3600000
  refresh-expiration: 86400000
```

#### Task 1.1.2: 테스트 의존성 확인 (build.gradle)
```groovy
dependencies {
    // 테스트
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
    testImplementation 'com.h2database:h2'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}
```

#### Task 1.1.3: 테스트 베이스 클래스 생성
```java
// src/test/java/com/hibi/server/support/IntegrationTestSupport.java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
public abstract class IntegrationTestSupport {
    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected ObjectMapper objectMapper;
}
```

### 1.2 Frontend 테스트 환경 설정

#### Task 1.2.1: 테스트 의존성 추가 (pubspec.yaml)
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  integration_test:
    sdk: flutter
```

#### Task 1.2.2: Mock Generator 설정
```dart
// test/mocks/mocks.dart
import 'package:mockito/annotations.dart';
import 'package:hidi/features/management/repos/admin_repo.dart';
// ... 다른 repos

@GenerateMocks([
  AdminRepository,
  PostRepository,
  AuthRepository,
  // ...
])
void main() {}
```

#### Task 1.2.3: 테스트 유틸리티 생성
```dart
// test/utils/test_app.dart
Widget createTestApp(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
      localizationsDelegates: [...],
    ),
  );
}
```

---

## Phase 2: 핵심 기능 테스트 (Week 1)

### 2.1 Backend - 인증 테스트 (Day 3-4)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `AuthServiceTest.java` | 8개 | 2시간 |
| `AuthControllerIntegrationTest.java` | 4개 | 2시간 |
| `JwtTokenProviderTest.java` | 4개 | 1시간 |
| `MemberRepositoryTest.java` | 3개 | 1시간 |

#### 체크리스트
- [ ] 회원가입 성공/실패 테스트
- [ ] 로그인 성공/실패 테스트
- [ ] 토큰 갱신 테스트
- [ ] JWT 유효성 검증 테스트

### 2.2 Backend - 회원 테스트 (Day 4)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `MemberServiceTest.java` | 4개 | 1.5시간 |
| `MemberControllerIntegrationTest.java` | 3개 | 1.5시간 |

### 2.3 Frontend - 인증 UI 테스트 (Day 5)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `login_view_test.dart` | 5개 | 1.5시간 |
| `signup_view_test.dart` | 5개 | 1.5시간 |
| `auth_viewmodel_test.dart` | 4개 | 1시간 |

---

## Phase 3: 피드/소셜 기능 테스트 (Week 2)

### 3.1 Backend - 게시글 테스트 (Day 6-7)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `PostServiceTest.java` | 8개 | 3시간 |
| `PostControllerIntegrationTest.java` | 6개 | 2시간 |
| `PostRepositoryTest.java` | 2개 | 1시간 |

### 3.2 Backend - 댓글 테스트 (Day 7-8)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `CommentServiceTest.java` | 7개 | 2.5시간 |
| `CommentControllerIntegrationTest.java` | 4개 | 1.5시간 |

### 3.3 Backend - 팔로우 테스트 (Day 8)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `FollowServiceTest.java` | 7개 | 2시간 |
| `FollowControllerIntegrationTest.java` | 4개 | 1.5시간 |

### 3.4 Frontend - 피드 UI 테스트 (Day 9-10)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `post_card_test.dart` | 6개 | 1.5시간 |
| `comment_tile_test.dart` | 5개 | 1시간 |
| `feed_viewmodel_test.dart` | 4개 | 1.5시간 |
| `follow_button_test.dart` | 3개 | 1시간 |

---

## Phase 4: 관리자/신고 기능 테스트 (Week 3)

### 4.1 Backend - 관리자 테스트 (Day 11-13)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `AdminServiceTest.java` | 14개 | 4시간 |
| `AdminControllerIntegrationTest.java` | 10개 | 3시간 |
| `AdminAuthorizationTest.java` | 5개 | 1.5시간 |

### 4.2 Backend - 신고/문의 테스트 (Day 13-14)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `ReportServiceTest.java` | 5개 | 2시간 |
| `QuestionServiceTest.java` | 4개 | 1.5시간 |
| `FAQServiceTest.java` | 4개 | 1.5시간 |

### 4.3 Frontend - 관리자 UI 테스트 (Day 15)

#### 파일 생성 목록
| 파일 | 테스트 수 | 예상 시간 |
|------|----------|-----------|
| `admin_stat_card_test.dart` | 3개 | 0.5시간 |
| `admin_dashboard_test.dart` | 4개 | 1시간 |
| `admin_report_viewmodel_test.dart` | 4개 | 1.5시간 |
| `admin_member_viewmodel_test.dart` | 3개 | 1시간 |

---

## Phase 5: E2E 및 마무리 (Week 4)

### 5.1 E2E 테스트 작성 (Day 16-18)

#### 파일 생성 목록
| 파일 | 시나리오 | 예상 시간 |
|------|----------|-----------|
| `auth_flow_test.dart` | 회원가입/로그인 | 2시간 |
| `post_flow_test.dart` | 게시글 CRUD | 2시간 |
| `follow_flow_test.dart` | 팔로우/피드 | 2시간 |
| `report_flow_test.dart` | 신고/관리자 처리 | 2시간 |

### 5.2 CI/CD 설정 (Day 18)

#### GitHub Actions Workflow
```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  backend-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Cache Gradle packages
        uses: actions/cache@v3
        with:
          path: ~/.gradle/caches
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*') }}

      - name: Run tests
        run: cd hibi_backend && ./gradlew test

      - name: Generate coverage report
        run: cd hibi_backend && ./gradlew jacocoTestReport

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: hibi_backend/build/reports/jacoco/test/jacocoTestReport.xml

  frontend-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.2'
          channel: 'stable'

      - name: Get dependencies
        run: cd hibi_front && flutter pub get

      - name: Run tests
        run: cd hibi_front && flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: hibi_front/coverage/lcov.info
```

### 5.3 수동 QA 체크리스트 (Day 19-20)

#### 기능별 수동 테스트
| 기능 | 테스트 항목 | 담당 | 상태 |
|------|-------------|------|------|
| 인증 | 회원가입, 로그인, 로그아웃 | - | ☐ |
| Daily Song | 오늘의 노래 표시, 좋아요 | - | ☐ |
| 아티스트 | 목록, 상세, 팔로우 | - | ☐ |
| 게시글 | 작성, 수정, 삭제, 좋아요 | - | ☐ |
| 댓글 | 작성, 삭제, 대댓글 | - | ☐ |
| 팔로우 | 팔로우/언팔, 목록 | - | ☐ |
| 검색 | 통합 검색, 카테고리 | - | ☐ |
| FAQ | 목록, 검색, 카테고리 | - | ☐ |
| 문의 | 작성, 내역 확인 | - | ☐ |
| 신고 | 신고 접수, 중복 방지 | - | ☐ |
| 관리자 | 대시보드, 각 관리 기능 | - | ☐ |

#### 크로스 플랫폼 테스트
| 플랫폼 | 디바이스 | 테스트 항목 | 상태 |
|--------|----------|-------------|------|
| Android | Pixel 6 (에뮬레이터) | 전체 기능 | ☐ |
| iOS | iPhone 14 (시뮬레이터) | 전체 기능 | ☐ |
| Web | Chrome | 전체 기능 | ☐ |

---

## 일정 요약

```
Week 1 (Day 1-5)
├── Day 1-2: 테스트 인프라 구축
├── Day 3-4: Backend 인증 테스트
└── Day 5: Frontend 인증 테스트

Week 2 (Day 6-10)
├── Day 6-7: Backend 게시글 테스트
├── Day 7-8: Backend 댓글 테스트
├── Day 8: Backend 팔로우 테스트
└── Day 9-10: Frontend 피드 테스트

Week 3 (Day 11-15)
├── Day 11-13: Backend 관리자 테스트
├── Day 13-14: Backend 신고/문의 테스트
└── Day 15: Frontend 관리자 테스트

Week 4 (Day 16-20)
├── Day 16-18: E2E 테스트 작성
├── Day 18: CI/CD 설정
└── Day 19-20: 수동 QA 및 버그 수정
```

---

## 성공 기준

### 정량적 기준
- [ ] Backend 코드 커버리지 70% 이상
- [ ] Frontend 코드 커버리지 60% 이상
- [ ] 모든 테스트 통과 (0 failures)
- [ ] CI/CD 파이프라인 정상 동작

### 정성적 기준
- [ ] 핵심 유저 플로우 3개 E2E 테스트 완료
- [ ] 수동 QA 체크리스트 100% 완료
- [ ] 발견된 버그 모두 수정

---

## 실행 명령어

### Backend 테스트 실행
```bash
cd hibi_backend

# 전체 테스트
./gradlew test

# 특정 테스트 클래스
./gradlew test --tests "AdminServiceTest"

# 커버리지 리포트 생성
./gradlew jacocoTestReport
# 리포트 위치: build/reports/jacoco/test/html/index.html
```

### Frontend 테스트 실행
```bash
cd hibi_front

# 전체 테스트
flutter test

# 특정 테스트 파일
flutter test test/widgets/admin_stat_card_test.dart

# 커버리지 포함
flutter test --coverage

# Integration 테스트
flutter test integration_test/
```

---

## 다음 단계

QA 완료 후:
1. 배포 환경 설정 (Production)
2. 모니터링 설정 (로그, 에러 추적)
3. 성능 테스트 (부하 테스트)
4. 보안 감사
