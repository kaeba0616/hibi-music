# /design-db - JPA Entity Design (Step 3)

Mock 데이터 구조를 분석하여 JPA Entity를 자동 생성합니다.

## 사용법
```
/design-db <feature-name> <feature-id>
```

## 실행 방법
`jpa-design-guide` 스킬을 통해 수동 모드로 진행합니다.

## 전제조건
- Step 2 (Flutter Mock UI) 완료
- `hibi_front/lib/features/<feature>/models/*.dart` 존재
- `hibi_front/lib/features/<feature>/mocks/*.dart` 존재

## 입력 파일
- Dart 모델 클래스
- Mock 데이터 파일

## 생성 파일
```
hibi_backend/src/main/java/com/hibi/server/domain/<feature>/
├── entity/<Entity>.java              # JPA Entity
└── repository/<Entity>Repository.java # Spring Data JPA Repository
```

## 6단계 작업 프로세스
1. **Dart 모델 분석**: 필드, 타입, 관계 파악
2. **타입 변환**: Dart → Java 타입 매핑
3. **관계 추론**: ManyToOne, OneToMany, ManyToMany 패턴 탐지
4. **JPA Entity 생성**: hibi 스타일 적용
5. **Repository 생성**: Spring Data JPA 인터페이스
6. **db-schema.md 업데이트**: ERD 문서화

## Dart → Java 타입 변환 규칙
| Dart | Java |
|------|------|
| `String` (id, *Id) | `Long` (PK) or `String` (UUID) |
| `String` (짧은 텍스트) | `String` + `@Column(length=N)` |
| `String` (긴 텍스트) | `String` + `@Lob` |
| `int` | `Integer` or `Long` |
| `double` | `Double` or `BigDecimal` |
| `bool` | `Boolean` |
| `DateTime` | `LocalDateTime` |
| `List<T>` | `List<T>` + `@OneToMany` |

## JPA Entity 스타일 (hibi)
```java
@Entity
@Table(name = "features")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Feature {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private Parent parent;
}
```

## 중요 원칙
- Frontend Mock 데이터 구조를 그대로 반영
- YAGNI: "나중에 필요할 것 같은 필드" 미리 추가 금지
- 기존 ERD (`hibi.erd.json`)와 일관성 유지

## 완료 조건
- [ ] Entity 클래스 생성
- [ ] Repository 인터페이스 생성
- [ ] `./gradlew build` 성공
- [ ] `docs/tech/db-schema.md` 업데이트

## 다음 단계
완료 후 사용자 승인을 받고 `/implement-api`로 진행합니다.
