# hibi 테스트 전략

## 1. 개요

### 1.1 목표
- 전체 기능의 안정성 보장
- 회귀 버그 방지
- 배포 전 품질 검증 자동화
- 코드 커버리지 70% 이상 유지

### 1.2 테스트 범위
- 12개 Feature (F1~F12) 전체
- Backend: Spring Boot API
- Frontend: Flutter UI

---

## 2. 테스트 피라미드

```
        /\
       /  \      E2E Tests (5%)
      /----\     - 핵심 유저 시나리오
     /      \
    /--------\   Integration Tests (25%)
   /          \  - API 통합, DB 연동
  /------------\
 /              \ Unit Tests (70%)
/________________\ - Service, Repository, ViewModel
```

---

## 3. Backend 테스트 전략 (Spring Boot)

### 3.1 단위 테스트 (Unit Tests)
- **대상**: Service, Repository, Utility 클래스
- **프레임워크**: JUnit 5 + Mockito
- **목표 커버리지**: 80%

```java
// 예시: AdminServiceTest.java
@ExtendWith(MockitoExtension.class)
class AdminServiceTest {
    @Mock private MemberRepository memberRepository;
    @InjectMocks private AdminService adminService;

    @Test
    void getStats_성공() { ... }
}
```

### 3.2 통합 테스트 (Integration Tests)
- **대상**: Controller + Service + Repository
- **프레임워크**: @SpringBootTest + @AutoConfigureMockMvc
- **DB**: H2 In-Memory Database
- **목표**: 주요 API 엔드포인트 100% 커버

```java
// 예시: AdminControllerIntegrationTest.java
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AdminControllerIntegrationTest {
    @Autowired private MockMvc mockMvc;

    @Test
    @WithMockUser(roles = "ADMIN")
    void getStats_관리자권한_성공() { ... }
}
```

### 3.3 Repository 테스트
- **대상**: JPA Repository 쿼리 메서드
- **프레임워크**: @DataJpaTest
- **목표**: 커스텀 쿼리 100% 커버

---

## 4. Frontend 테스트 전략 (Flutter)

### 4.1 Widget 테스트
- **대상**: 개별 Widget 컴포넌트
- **프레임워크**: flutter_test
- **목표 커버리지**: 70%

```dart
// 예시: admin_stat_card_test.dart
testWidgets('AdminStatCard displays correct values', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: AdminStatCard(title: '총 회원', value: '1,234')),
  );
  expect(find.text('총 회원'), findsOneWidget);
  expect(find.text('1,234'), findsOneWidget);
});
```

### 4.2 ViewModel 테스트
- **대상**: Riverpod StateNotifier/AsyncNotifier
- **프레임워크**: flutter_test + mockito
- **목표**: 모든 ViewModel 상태 변화 테스트

### 4.3 Integration 테스트
- **대상**: 화면 간 네비게이션, 데이터 플로우
- **프레임워크**: integration_test
- **목표**: 핵심 유저 플로우 커버

---

## 5. E2E 테스트

### 5.1 테스트 시나리오
| ID | 시나리오 | 우선순위 |
|----|----------|----------|
| E2E-01 | 회원가입 → 로그인 → 프로필 확인 | P0 |
| E2E-02 | 오늘의 노래 조회 → 좋아요 | P0 |
| E2E-03 | 게시글 작성 → 댓글 작성 → 삭제 | P0 |
| E2E-04 | 아티스트 검색 → 팔로우 | P1 |
| E2E-05 | 문의 작성 → 내역 확인 | P1 |
| E2E-06 | 신고 → (관리자) 처리 | P1 |
| E2E-07 | FAQ 조회 → 검색 | P2 |

### 5.2 실행 환경
- 로컬: Flutter Integration Test
- CI: GitHub Actions + Emulator

---

## 6. 테스트 우선순위

### Phase 1: 핵심 기능 (Week 1)
| 영역 | 테스트 대상 | 예상 공수 |
|------|-------------|-----------|
| Backend | AuthService, MemberService 단위 테스트 | 1일 |
| Backend | 인증 API 통합 테스트 | 0.5일 |
| Frontend | 로그인/회원가입 Widget 테스트 | 0.5일 |

### Phase 2: 피드/소셜 (Week 2)
| 영역 | 테스트 대상 | 예상 공수 |
|------|-------------|-----------|
| Backend | PostService, CommentService 단위 테스트 | 1일 |
| Backend | 피드 API 통합 테스트 | 1일 |
| Backend | FollowService 테스트 | 0.5일 |
| Frontend | 게시글/댓글 Widget 테스트 | 0.5일 |

### Phase 3: 관리자/신고 (Week 3)
| 영역 | 테스트 대상 | 예상 공수 |
|------|-------------|-----------|
| Backend | AdminService 단위 테스트 | 1일 |
| Backend | ReportService, QuestionService 테스트 | 1일 |
| Backend | 관리자 API 통합 테스트 (@PreAuthorize) | 0.5일 |
| Frontend | 관리자 화면 Widget 테스트 | 0.5일 |

### Phase 4: E2E 및 마무리 (Week 4)
| 영역 | 테스트 대상 | 예상 공수 |
|------|-------------|-----------|
| E2E | 핵심 시나리오 3개 (P0) | 1일 |
| E2E | 보조 시나리오 4개 (P1, P2) | 1일 |
| QA | 수동 테스트 및 버그 수정 | 1일 |

---

## 7. 테스트 환경 설정

### 7.1 Backend (application-test.yml)
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: test-client-id
            client-secret: test-client-secret
```

### 7.2 Frontend (테스트 Mock 설정)
```dart
// test/mocks/mock_providers.dart
final mockAdminRepo = MockAdminRepository();
final testProviderOverrides = [
  adminRepoProvider.overrideWithValue(mockAdminRepo),
];
```

---

## 8. CI/CD 통합

### 8.1 GitHub Actions Workflow
```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  backend-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
      - run: cd hibi_backend && ./gradlew test

  frontend-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: cd hibi_front && flutter test
```

### 8.2 테스트 리포트
- Backend: JaCoCo 커버리지 리포트
- Frontend: lcov 커버리지 리포트
- PR 코멘트로 커버리지 변화 표시

---

## 9. 품질 기준

### 9.1 테스트 통과 기준
- 모든 테스트 통과 (0 failures)
- 코드 커버리지: Backend 70%+, Frontend 60%+
- 정적 분석 경고 0개

### 9.2 배포 게이트
- `main` 브랜치 머지 조건:
  - 모든 CI 테스트 통과
  - 최소 1명 코드 리뷰 승인
  - 커버리지 감소 없음

---

## 10. 테스트 명명 규칙

### Backend (Java)
```
{메서드명}_{시나리오}_{예상결과}

예시:
- getStats_정상호출_통계반환()
- sanctionMember_관리자아닌경우_AccessDenied()
- processReport_이미처리된신고_예외발생()
```

### Frontend (Dart)
```
'{Widget/Class} {동작} {조건}'

예시:
- 'AdminStatCard displays correct values'
- 'ReportFormViewModel submits report successfully'
- 'LoginView shows error on invalid credentials'
```
