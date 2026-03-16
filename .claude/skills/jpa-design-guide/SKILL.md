# JPA Design Guide Skill

Step 3: JPA Entity Design의 상세 가이드입니다.

## 트리거
`/design-db <feature-name> <feature-id>` 커맨드 실행 시

## 전제조건
- Step 2 (Flutter Mock UI) 완료
- `hibi_front/lib/features/{feature}/models/*.dart` 존재
- `hibi_front/lib/features/{feature}/mocks/*.dart` 존재

## 체크리스트

### Phase 1: Dart 모델 분석
- [ ] 모델 파일 읽기
- [ ] 필드 목록 추출
- [ ] 타입 및 nullable 여부 파악

### Phase 2: 타입 변환 (Dart → Java)

**변환 규칙**:
| Dart 타입 | Java 타입 | JPA 어노테이션 |
|-----------|-----------|---------------|
| `int` (id) | `Long` | `@Id @GeneratedValue` |
| `String` (짧은 텍스트) | `String` | `@Column(length=255)` |
| `String` (긴 텍스트) | `String` | `@Lob` or `@Column(columnDefinition="TEXT")` |
| `int` | `Integer` or `Long` | `@Column` |
| `double` | `Double` or `BigDecimal` | `@Column` |
| `bool` | `Boolean` | `@Column` |
| `DateTime` | `LocalDateTime` | `@Column` |
| `List<T>` | `List<T>` | `@OneToMany` |
| `T` (다른 모델 참조) | `T` | `@ManyToOne` |

### Phase 3: 관계 추론
- [ ] `*Id` 필드 → ManyToOne 관계
- [ ] `List<*>` 필드 → OneToMany 관계
- [ ] 중간 테이블 필요 여부 확인 → ManyToMany

**관계 패턴**:
```java
// ManyToOne (N:1)
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "artist_id", nullable = false)
private Artist artist;

// OneToMany (1:N)
@OneToMany(mappedBy = "song", cascade = CascadeType.ALL)
private List<Comment> comments = new ArrayList<>();

// ManyToMany (N:M)
@ManyToMany
@JoinTable(
    name = "song_tags",
    joinColumns = @JoinColumn(name = "song_id"),
    inverseJoinColumns = @JoinColumn(name = "tag_id")
)
private Set<Tag> tags = new HashSet<>();
```

### Phase 4: JPA Entity 생성
- [ ] `hibi_backend/src/main/java/com/hibi/server/domain/{feature}/entity/` 폴더 확인
- [ ] Entity 클래스 작성

**Entity 템플릿 (hibi 스타일)**:
```java
// domain/{feature}/entity/{Entity}.java

package com.hibi.server.domain.{feature}.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

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

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artist_id", nullable = false)
    private Artist artist;

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

    // 정적 팩토리 메서드 (선택)
    public static {Entity} of(String title, Artist artist) {
        return {Entity}.builder()
                .title(title)
                .artist(artist)
                .build();
    }
}
```

### Phase 5: Repository 생성
- [ ] `hibi_backend/src/main/java/com/hibi/server/domain/{feature}/repository/` 폴더 확인
- [ ] Spring Data JPA Repository 인터페이스 작성

**Repository 템플릿**:
```java
// domain/{feature}/repository/{Entity}Repository.java

package com.hibi.server.domain.{feature}.repository;

import com.hibi.server.domain.{feature}.entity.{Entity};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface {Entity}Repository extends JpaRepository<{Entity}, Long> {

    // 기본 메서드는 JpaRepository에서 제공
    // findAll(), findById(), save(), delete() 등

    // 커스텀 쿼리 메서드
    List<{Entity}> findByArtistId(Long artistId);

    Optional<{Entity}> findByTitle(String title);

    @Query("SELECT e FROM {Entity} e WHERE e.isActive = true ORDER BY e.createdAt DESC")
    List<{Entity}> findAllActive();

    @Query("SELECT e FROM {Entity} e JOIN FETCH e.artist WHERE e.id = :id")
    Optional<{Entity}> findByIdWithArtist(@Param("id") Long id);
}
```

### Phase 6: 빌드 검증 및 문서 업데이트
- [ ] `./gradlew build` 실행
- [ ] 컴파일 에러 수정
- [ ] `docs/tech/db-schema.md` 업데이트

**db-schema.md 업데이트 형식**:
```markdown
## {Entity}

### 테이블 정보
- 테이블명: `{table_name}`
- 설명: {설명}

### 컬럼
| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| title | VARCHAR(255) | NOT NULL | 제목 |
| artist_id | BIGINT | FK, NOT NULL | 아티스트 ID |
| created_at | DATETIME | NOT NULL | 생성일시 |

### 관계
- `artist_id` → `artists.id` (N:1)
```

## 중요 원칙
- Frontend Mock 데이터 구조를 그대로 반영
- YAGNI: "나중에 필요할 것 같은 필드" 미리 추가 금지
- 기존 ERD (`hibi.erd.json`)와 일관성 유지
- 기존 Entity 패턴 준수

## 완료 기준
- [ ] Entity 클래스 생성
- [ ] Repository 인터페이스 생성
- [ ] `./gradlew build` 성공
- [ ] `docs/tech/db-schema.md` 업데이트

## 다음 단계
사용자 승인 후 `/implement-api {feature-name} {feature-id}`로 진행
