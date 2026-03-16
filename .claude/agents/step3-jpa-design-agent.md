# Step 3 - JPA Entity Design Agent

`/design-db` 커맨드 실행 시 Dart 모델을 분석하여 JPA Entity를 자동 생성하는 Agent입니다.

## 목적
- Dart 모델 구조 자동 분석
- Dart → Java 타입 자동 변환
- 관계(Relation) 자동 추론
- JPA Entity 클래스 자동 생성
- Spring Data JPA Repository 자동 생성
- DB 스키마 문서 자동 업데이트

## 실행 조건

### 필수 사전조건
- [ ] Step 2 (Flutter Mock UI) 완료
- [ ] `hibi_front/lib/features/{feature}/models/*.dart` 존재
- [ ] `hibi_front/lib/features/{feature}/mocks/*.dart` 존재

### 입력
- Feature 이름: `$ARGUMENTS[0]` (예: daily-song)
- Feature ID: `$ARGUMENTS[1]` (예: f2)

## 6단계 자동 작업 프로세스

### Phase 1: Dart 모델 읽기
```
1. hibi_front/lib/features/{feature}/models/ 폴더 스캔
2. 모든 .dart 파일 읽기
3. 클래스 정의 파싱
4. 필드 목록 추출
```

**추출 정보**:
- 클래스 이름
- 필드 이름, 타입, nullable 여부
- 관계 힌트 (다른 모델 참조, List 타입 등)

### Phase 2: 타입 변환
```
1. Dart 타입을 Java 타입으로 매핑
2. JPA 어노테이션 결정
3. 컬럼 속성 결정 (length, nullable 등)
```

**변환 규칙**:
| Dart | Java | JPA |
|------|------|-----|
| `int` (id) | `Long` | `@Id @GeneratedValue(strategy = GenerationType.IDENTITY)` |
| `String` | `String` | `@Column(nullable = false)` |
| `String?` | `String` | `@Column` |
| `int` | `Integer` or `Long` | `@Column` |
| `double` | `Double` or `BigDecimal` | `@Column` |
| `bool` | `Boolean` | `@Column` |
| `DateTime` | `LocalDateTime` | `@Column` |
| `List<T>` | `List<T>` | `@OneToMany(mappedBy = "...")` |

### Phase 3: 관계 추론
```
1. *Id 필드 → ManyToOne 관계 추론
2. List<*> 필드 → OneToMany 관계 추론
3. 기존 Entity와의 관계 확인
```

**관계 패턴**:
```java
// artistId 필드 발견 → ManyToOne
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "artist_id", nullable = false)
private Artist artist;

// List<Comment> 필드 발견 → OneToMany
@OneToMany(mappedBy = "song", cascade = CascadeType.ALL)
private List<Comment> comments = new ArrayList<>();
```

### Phase 4: JPA Entity 생성
```
1. hibi_backend/src/main/java/com/hibi/server/domain/{feature}/entity/ 폴더 확인
2. Entity 클래스 생성 (hibi 스타일 적용)
```

**생성 파일**: `domain/{feature}/entity/{Entity}.java`

```java
package com.hibi.server.domain.{feature}.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "{table_name}")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class {Entity} {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artist_id", nullable = false)
    private Artist artist;

    @OneToMany(mappedBy = "{entity}", cascade = CascadeType.ALL)
    @Builder.Default
    private List<{Related}> {related}s = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // 비즈니스 메서드
    public void updateTitle(String title) {
        this.title = title;
    }

    public void updateDescription(String description) {
        this.description = description;
    }

    // 정적 팩토리 메서드
    public static {Entity} of(String title, String description, Artist artist) {
        return {Entity}.builder()
                .title(title)
                .description(description)
                .artist(artist)
                .build();
    }
}
```

### Phase 5: Repository 생성
```
1. hibi_backend/src/main/java/com/hibi/server/domain/{feature}/repository/ 폴더 확인
2. JpaRepository 인터페이스 생성
```

**생성 파일**: `domain/{feature}/repository/{Entity}Repository.java`

```java
package com.hibi.server.domain.{feature}.repository;

import com.hibi.server.domain.{feature}.entity.{Entity};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface {Entity}Repository extends JpaRepository<{Entity}, Long> {

    // 기본 CRUD는 JpaRepository에서 제공

    // 관계 기반 조회
    List<{Entity}> findByArtistId(Long artistId);

    // 활성 데이터만 조회
    @Query("SELECT e FROM {Entity} e WHERE e.isActive = true ORDER BY e.createdAt DESC")
    List<{Entity}> findAllActive();

    // Fetch Join (N+1 방지)
    @Query("SELECT e FROM {Entity} e JOIN FETCH e.artist WHERE e.id = :id")
    Optional<{Entity}> findByIdWithArtist(@Param("id") Long id);

    // 페이징 지원
    // Page<{Entity}> findAll(Pageable pageable);
}
```

### Phase 6: 빌드 검증 및 문서 업데이트
```
1. ./gradlew build 실행
2. 컴파일 에러 수정
3. docs/tech/db-schema.md 업데이트
```

**db-schema.md 업데이트**:
```markdown
## {Entity}

### 테이블 정보
- 테이블명: `{table_name}`
- 설명: {Entity 설명}

### 컬럼
| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| title | VARCHAR(255) | NOT NULL | 제목 |
| description | TEXT | | 설명 |
| artist_id | BIGINT | FK, NOT NULL | 아티스트 ID |
| created_at | DATETIME | NOT NULL | 생성일시 |
| updated_at | DATETIME | | 수정일시 |

### 인덱스
| 인덱스명 | 컬럼 | 타입 |
|----------|------|------|
| idx_{table}_artist | artist_id | BTREE |

### 관계
- `artist_id` → `artists.id` (N:1)
- `{table}_id` ← `{related_table}.{table}_id` (1:N)
```

## 중요 원칙

### 필수 준수
- Frontend Mock 데이터 구조 그대로 반영
- YAGNI: 미래 필요 필드 미리 추가 금지
- 기존 ERD (`hibi.erd.json`)와 일관성 유지
- hibi 프로젝트의 기존 Entity 패턴 준수

### 금지사항
- Mock 데이터에 없는 필드 추가
- 불필요한 양방향 관계 설정
- 기존 패턴과 다른 스타일 적용

## 완료 조건
- [ ] Entity 클래스 생성
- [ ] Repository 인터페이스 생성
- [ ] `./gradlew build` 성공
- [ ] `docs/tech/db-schema.md` 업데이트

## 완료 후
사용자에게 검토 요청 후 승인을 받고 Step 4 (Spring Boot API)로 진행합니다.
