# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

이 리포지토리는 **spec-driven 개발 방식**으로 서비스를 만드는 프로젝트입니다.
Claude Code는 이 파일을 이 레포지토리의 **헌법(constitution)** 으로 삼고,
여기 적힌 순서를 항상 우선시해야 합니다.

---

## 0. 프로젝트 컨텍스트

- **프로젝트 이름**: hibi (日々)
- **한 줄 소개**: 매일 JPOP 한 곡을 추천받고, 팬들과 소통하는 일본 음악 공유 플랫폼
- **주요 유저/고객**: JPOP 팬, 일본 음악 애호가, 아티스트 팬덤 커뮤니티 사용자
- **기술 스택**:
  - Frontend: Flutter 3.29.2 + Riverpod + go_router + Dio
  - Backend: Spring Boot 3.4.5 + Java 17 + JPA/Hibernate + MySQL
  - CI/CD: GitHub Actions
- **상위 사업계획서 위치**: `docs/business/business-plan.md`

---

## 1. 6가지 기본 행동 패턴

1. **"항상 문서부터 읽는다"** - 코드 변경 전 관련 문서 확인
2. **"항상 Plan을 먼저 제안한다"** - 구현 전 계획 수립
3. **"항상 Red-Green-Refactor 사이클을 따른다"** - TDD 원칙 준수
4. **"항상 AC → 실패 테스트 → 최소 구현 → 리팩터링 순서"**
5. **"항상 비즈니스/제품 스펙을 우선시한다"**
6. **"큰 변경은 사용자 동의 후 진행한다"**

---

## 2. 문서 구조와 역할

이 프로젝트는 **문서 → 테스트 → 코드** 순서로 개발하는 것을 원칙으로 합니다.

### 2.1 비즈니스 / 전략 문서
| 파일 | 역할 |
|------|------|
| `docs/business/business-plan.md` | 전체 사업계획서 |
| `docs/business/positioning-bm.md` | 포지셔닝, 경쟁 서비스 비교 |

### 2.2 제품(Product) 문서
| 파일 | 역할 |
|------|------|
| `docs/product/prd-main.md` | 전체 PRD 및 Acceptance Criteria |
| `docs/product/features/` | 개별 기능 상세 스펙 |

### 2.3 UX 문서
| 파일 | 역할 |
|------|------|
| `docs/ux/ux-flow-main.md` | 전체 UX 플로우 |
| `docs/ux/ui-theme.md` | UI 테마 가이드 (Flutter Material Design 기반) |
| `docs/ux/features/` | 기능별 화면 구조 (`*-flow.md`, `*-screens.md`) |

### 2.4 기술(Tech) 문서
| 파일 | 역할 |
|------|------|
| `docs/tech/tech-spec.md` | 전체 기술 아키텍처 |
| `docs/tech/api-spec.md` | REST API 스펙 (Spring Boot) |
| `docs/tech/db-schema.md` | JPA Entity 및 ERD |
| `docs/tech/security-rbac.md` | Spring Security 인증/인가 |

### 2.5 QA / 테스트 문서
| 파일 | 역할 |
|------|------|
| `docs/qa/test-strategy.md` | 테스트 전략 |
| `docs/qa/test-cases/` | 테스트 케이스 |

### 2.6 프로젝트 관리 문서
| 파일 | 역할 |
|------|------|
| `docs/project/roadmap.md` | 전체 Phase 개요 |
| `docs/project/phases/` | Phase별 계획 |
| `docs/project/features/` | Feature별 상세 계획 |

---

## 3. 기능 단위 작업 파이프라인 (Feature Workflow)

새로운 기능은 **반드시** 아래 4단계를 순서대로 진행합니다.

### Step 1: UX Planning & Design
| 항목 | 내용 |
|------|------|
| **목표** | 사용자 여정과 화면 구조를 정의 |
| **입력** | `docs/product/prd-main.md`, AC |
| **출력** | `docs/ux/features/<feature>-flow.md`, `<feature>-screens.md` |
| **실행** | `/ux-plan <feature-name> <feature-id>` |

### Step 2: Flutter Mock UI
| 항목 | 내용 |
|------|------|
| **목표** | Mock 데이터로 완전히 동작하는 Flutter UI 구현 |
| **입력** | UX 문서 (`*-flow.md`, `*-screens.md`) |
| **출력** | `hibi_front/lib/features/<feature>/` 하위 파일들 |
| **실행** | `/mock-ui <feature-name> <feature-id>` |

**생성 파일**:
- `models/<model>.dart` - Dart 데이터 모델
- `mocks/<feature>_mock.dart` - Mock 데이터
- `repos/<feature>_repo.dart` - Repository (Mock Provider 패턴)
- `viewmodels/<feature>_viewmodel.dart` - Riverpod ViewModel
- `views/<view>.dart` - Flutter Widget

### Step 3: JPA Entity Design
| 항목 | 내용 |
|------|------|
| **목표** | Mock 데이터 구조를 분석하여 JPA Entity 생성 |
| **입력** | Flutter 모델 및 Mock 데이터 |
| **출력** | `hibi_backend/src/main/java/com/hibi/server/domain/<feature>/` |
| **실행** | `/design-db <feature-name> <feature-id>` |

**생성 파일**:
- `entity/<Entity>.java` - JPA Entity
- `repository/<Entity>Repository.java` - Spring Data JPA Repository

### Step 4: Spring Boot API Implementation
| 항목 | 내용 |
|------|------|
| **목표** | API 구현 및 Flutter와 통합 |
| **입력** | Entity, UX 문서 |
| **출력** | Controller, Service, DTO + Flutter Real API 연동 |
| **실행** | `/implement-api <feature-name> <feature-id>` |

**생성 파일**:
- `dto/request/*.java` - 요청 DTO
- `dto/response/*.java` - 응답 DTO
- `service/<Feature>Service.java` - 비즈니스 로직
- `controller/<Feature>Controller.java` - REST Controller

---

## 4. TDD 원칙 (RED-GREEN-REFACTOR)

| 단계 | 설명 | 규칙 |
|------|------|------|
| RED | 실패하는 테스트 작성 | 테스트 먼저 작성 후 실행하여 실패 확인 |
| GREEN | 테스트 통과 최소 코드 | 오직 테스트를 통과시키기 위한 최소 코드만 작성 |
| REFACTOR | 테스트 보존하며 리팩터링 | 테스트가 계속 통과하는 상태에서 코드 개선 |

---

## 5. 금지사항

- 문서 무시하고 코드 변경
- 테스트 없이 기능 추가
- 실패 테스트 무시/주석 처리
- REFACTOR 단계에서 새 기능 추가
- "나중에 테스트" 미루기
- Step 순서 건너뛰기 (예: Step 1 없이 Step 2 진행)

---

## 6. 개발 명령어

### Backend (Spring Boot)
```bash
cd hibi_backend
./gradlew build          # 빌드 + 테스트
./gradlew bootRun        # 개발 서버 실행
./gradlew test           # 테스트만 실행
```

### Frontend (Flutter)
```bash
cd hibi_front
flutter pub get                        # 의존성 설치
flutter run                            # 앱 실행
flutter test                           # 단위 테스트
flutter test integration_test/         # 통합 테스트
dart format --set-exit-if-changed .    # 코드 포맷팅 검사
```

---

## 7. 코드 패턴 (hibi 스타일)

### Backend - JPA Entity
```java
@Entity
@Table(name = "songs")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Song {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title_kor", nullable = false)
    private String titleKor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artist_id", nullable = false)
    private Artist artist;
}
```

### Backend - Controller
```java
@RestController
@RequestMapping("/api/v1/songs")
@RequiredArgsConstructor
public class SongController {
    private final SongService songService;

    @PostMapping
    public ResponseEntity<SuccessResponse<?>> create(
            @RequestBody @Valid SongCreateRequest request) {
        songService.create(request);
        return ResponseEntity.ok(SuccessResponse.success("노래 생성 성공"));
    }
}
```

### Frontend - Mock Provider 패턴
```dart
class SongRepository {
  final bool useMock;

  SongRepository({this.useMock = false});

  Future<List<Song>> getSongs() async {
    if (useMock) return mockSongs;
    // Real API 호출
  }
}

final songRepoProvider = Provider((ref) {
  final useMock = const String.fromEnvironment('USE_MOCK') == 'true';
  return SongRepository(useMock: useMock);
});
```

---

## 8. 프로젝트 상황 확인

세션 시작 시: `/next` 명령으로 현재 Phase/Feature 상태 파악 후 진행

---

**이것이 hibi 프로젝트의 개발 헌법입니다.**
