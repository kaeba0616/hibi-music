# /implement-api - Spring Boot API Implementation (Step 4)

API를 구현하고 Flutter와 통합합니다.

## 사용법
```
/implement-api <feature-name> <feature-id>
```

## 실행 방법
`spring-api-guide` 스킬을 통해 수동 모드로 진행합니다.

## 전제조건
- Step 3 (JPA Entity Design) 완료
- Entity 및 Repository 존재
- `./gradlew build` 성공

## 입력 파일
- JPA Entity
- UX 문서 (API 요구사항)
- Flutter Mock 데이터 (응답 형식 참조)

## 생성 파일
```
hibi_backend/src/main/java/com/hibi/server/domain/<feature>/
├── dto/
│   ├── request/<Feature>CreateRequest.java
│   ├── request/<Feature>UpdateRequest.java
│   └── response/<Feature>Response.java
├── service/<Feature>Service.java
└── controller/<Feature>Controller.java

hibi_front/lib/features/<feature>/
└── repos/<feature>_repo.dart  # Real API 연동으로 업데이트
```

## 8단계 작업 프로세스
1. **Entity 확인**: Step 3에서 생성된 Entity 검토
2. **DTO 생성**: Request/Response DTO with Validation
3. **Service 구현**: 비즈니스 로직
4. **Controller 구현**: REST API Endpoint
5. **API 테스트 작성**: JUnit 5 + MockMvc
6. **Flutter Repository 업데이트**: Real API 호출 구현
7. **통합 테스트**: Flutter에서 Real API 호출 확인
8. **문서 업데이트**: `docs/tech/api-spec.md`

## Spring Boot Controller 스타일 (hibi)
```java
@RestController
@RequestMapping("/api/v1/features")
@RequiredArgsConstructor
public class FeatureController {
    private final FeatureService featureService;

    @PostMapping
    @Operation(summary = "Feature 생성")
    public ResponseEntity<SuccessResponse<?>> create(
            @RequestBody @Valid FeatureCreateRequest request) {
        featureService.create(request);
        return ResponseEntity.ok(SuccessResponse.success("Feature 생성 성공"));
    }

    @GetMapping
    @Operation(summary = "Feature 목록 조회")
    public ResponseEntity<SuccessResponse<List<FeatureResponse>>> getAll() {
        return ResponseEntity.ok(
            SuccessResponse.success("조회 성공", featureService.getAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<SuccessResponse<FeatureResponse>> getById(
            @PathVariable Long id) {
        return ResponseEntity.ok(
            SuccessResponse.success("조회 성공", featureService.getById(id)));
    }
}
```

## HTTP Status Code 규칙
| 상황 | Status |
|------|--------|
| POST 생성 성공 | 200 or 201 |
| GET 조회 성공 | 200 |
| DELETE 삭제 성공 | 200 or 204 |
| 리소스 없음 | 404 |
| 유효성 검사 실패 | 400 |

## 중요 원칙
- Mock Provider 패턴 유지 (환경변수로 Mock/Real 전환)
- SuccessResponse 래퍼 사용
- Swagger/OpenAPI 문서화

## 완료 조건
- [ ] Controller, Service, DTO 구현
- [ ] API 테스트 작성 및 통과
- [ ] Flutter Repository Real API 연동
- [ ] 브라우저/앱에서 동작 확인
- [ ] `docs/tech/api-spec.md` 업데이트

## Feature 완료
4단계가 모두 완료되면 해당 Feature는 `[status: completed]`로 표시합니다.
