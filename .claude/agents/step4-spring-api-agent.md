# Step 4 - Spring Boot API Implementation Agent

`/implement-api` 커맨드 실행 시 Spring Boot API를 자동 구현하고 Flutter와 통합하는 Agent입니다.

## 목적
- Request/Response DTO 자동 생성
- Service 비즈니스 로직 구현
- REST Controller 구현
- API 테스트 자동 생성
- Flutter Repository Real API 연동
- API 문서 자동 업데이트

## 실행 조건

### 필수 사전조건
- [ ] Step 3 (JPA Entity Design) 완료
- [ ] Entity 및 Repository 존재
- [ ] `./gradlew build` 성공

### 입력
- Feature 이름: `$ARGUMENTS[0]` (예: daily-song)
- Feature ID: `$ARGUMENTS[1]` (예: f2)

## 8단계 자동 작업 프로세스

### Phase 1: Entity 확인
```
1. domain/{feature}/entity/*.java 파일 읽기
2. 필드 및 관계 파악
3. Repository 메서드 확인
```

### Phase 2: DTO 생성
```
1. domain/{feature}/dto/request/ 폴더 생성
2. domain/{feature}/dto/response/ 폴더 생성
3. Create/Update Request DTO 생성
4. Response DTO 생성
```

**생성 파일**: `dto/request/{Feature}CreateRequest.java`
```java
package com.hibi.server.domain.{feature}.dto.request;

import jakarta.validation.constraints.*;

public record {Feature}CreateRequest(
    @NotBlank(message = "제목은 필수입니다")
    @Size(max = 255, message = "제목은 255자 이하여야 합니다")
    String title,

    @Size(max = 1000, message = "설명은 1000자 이하여야 합니다")
    String description,

    @NotNull(message = "아티스트 ID는 필수입니다")
    @Positive(message = "아티스트 ID는 양수여야 합니다")
    Long artistId
) {}
```

**생성 파일**: `dto/request/{Feature}UpdateRequest.java`
```java
package com.hibi.server.domain.{feature}.dto.request;

import jakarta.validation.constraints.*;

public record {Feature}UpdateRequest(
    @NotBlank(message = "제목은 필수입니다")
    @Size(max = 255)
    String title,

    @Size(max = 1000)
    String description
) {}
```

**생성 파일**: `dto/response/{Feature}Response.java`
```java
package com.hibi.server.domain.{feature}.dto.response;

import com.hibi.server.domain.{feature}.entity.{Entity};
import java.time.LocalDateTime;

public record {Feature}Response(
    Long id,
    String title,
    String description,
    Long artistId,
    String artistName,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
    public static {Feature}Response from({Entity} entity) {
        return new {Feature}Response(
            entity.getId(),
            entity.getTitle(),
            entity.getDescription(),
            entity.getArtist().getId(),
            entity.getArtist().getName(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
}
```

### Phase 3: Service 구현
```
1. domain/{feature}/service/{Feature}Service.java 생성
2. CRUD 메서드 구현
3. 트랜잭션 관리
```

**생성 파일**: `service/{Feature}Service.java`
```java
package com.hibi.server.domain.{feature}.service;

import com.hibi.server.domain.{feature}.dto.request.*;
import com.hibi.server.domain.{feature}.dto.response.*;
import com.hibi.server.domain.{feature}.entity.{Entity};
import com.hibi.server.domain.{feature}.repository.{Entity}Repository;
import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class {Feature}Service {

    private final {Entity}Repository {entity}Repository;
    private final ArtistRepository artistRepository;

    public List<{Feature}Response> getAll() {
        return {entity}Repository.findAll().stream()
                .map({Feature}Response::from)
                .toList();
    }

    public {Feature}Response getById(Long id) {
        {Entity} entity = find{Entity}ById(id);
        return {Feature}Response.from(entity);
    }

    @Transactional
    public Long create({Feature}CreateRequest request) {
        Artist artist = findArtistById(request.artistId());

        {Entity} entity = {Entity}.of(
            request.title(),
            request.description(),
            artist
        );

        return {entity}Repository.save(entity).getId();
    }

    @Transactional
    public void update(Long id, {Feature}UpdateRequest request) {
        {Entity} entity = find{Entity}ById(id);
        entity.updateTitle(request.title());
        entity.updateDescription(request.description());
    }

    @Transactional
    public void delete(Long id) {
        {Entity} entity = find{Entity}ById(id);
        {entity}Repository.delete(entity);
    }

    private {Entity} find{Entity}ById(Long id) {
        return {entity}Repository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));
    }

    private Artist findArtistById(Long id) {
        return artistRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));
    }
}
```

### Phase 4: Controller 구현
```
1. domain/{feature}/controller/{Feature}Controller.java 생성
2. REST Endpoint 구현
3. Swagger 어노테이션 추가
```

**생성 파일**: `controller/{Feature}Controller.java`
```java
package com.hibi.server.domain.{feature}.controller;

import com.hibi.server.domain.{feature}.dto.request.*;
import com.hibi.server.domain.{feature}.dto.response.*;
import com.hibi.server.domain.{feature}.service.{Feature}Service;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/{feature}s")
@RequiredArgsConstructor
@Tag(name = "{Feature}", description = "{Feature} 관련 API")
public class {Feature}Controller {

    private final {Feature}Service {feature}Service;

    @GetMapping
    @Operation(summary = "전체 {Feature} 조회", description = "모든 {Feature}를 조회합니다.")
    public ResponseEntity<SuccessResponse<List<{Feature}Response>>> getAll() {
        return ResponseEntity.ok(
            SuccessResponse.success("전체 {Feature} 조회 성공", {feature}Service.getAll())
        );
    }

    @GetMapping("/{id}")
    @Operation(summary = "{Feature} 상세 조회", description = "ID로 {Feature}를 조회합니다.")
    public ResponseEntity<SuccessResponse<{Feature}Response>> getById(
            @PathVariable Long id) {
        return ResponseEntity.ok(
            SuccessResponse.success("{Feature} 조회 성공", {feature}Service.getById(id))
        );
    }

    @PostMapping
    @Operation(summary = "{Feature} 생성", description = "새로운 {Feature}를 생성합니다.")
    public ResponseEntity<SuccessResponse<Long>> create(
            @RequestBody @Valid {Feature}CreateRequest request) {
        Long id = {feature}Service.create(request);
        return ResponseEntity.ok(SuccessResponse.success("{Feature} 생성 성공", id));
    }

    @PutMapping("/{id}")
    @Operation(summary = "{Feature} 수정", description = "{Feature}를 수정합니다.")
    public ResponseEntity<SuccessResponse<?>> update(
            @PathVariable Long id,
            @RequestBody @Valid {Feature}UpdateRequest request) {
        {feature}Service.update(id, request);
        return ResponseEntity.ok(SuccessResponse.success("{Feature} 수정 성공"));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "{Feature} 삭제", description = "{Feature}를 삭제합니다.")
    public ResponseEntity<SuccessResponse<?>> delete(@PathVariable Long id) {
        {feature}Service.delete(id);
        return ResponseEntity.ok(SuccessResponse.success("{Feature} 삭제 성공"));
    }
}
```

### Phase 5: API 테스트 작성
```
1. src/test/java/.../domain/{feature}/ 폴더 생성
2. Controller 테스트 작성
3. Service 테스트 작성 (선택)
```

**생성 파일**: `{Feature}ControllerTest.java`
```java
@SpringBootTest
@AutoConfigureMockMvc
class {Feature}ControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("전체 {Feature} 조회 성공")
    void getAllSuccess() throws Exception {
        mockMvc.perform(get("/api/v1/{feature}s"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("전체 {Feature} 조회 성공"));
    }

    @Test
    @DisplayName("{Feature} 생성 - 유효성 검사 실패")
    void createValidationFail() throws Exception {
        String invalidRequest = "{}";

        mockMvc.perform(post("/api/v1/{feature}s")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidRequest))
                .andExpect(status().isBadRequest());
    }
}
```

### Phase 6: Flutter Repository 업데이트
```
1. hibi_front/lib/features/{feature}/repos/{feature}_repo.dart 수정
2. Real API 호출 구현
```

**업데이트**: `repos/{feature}_repo.dart`
```dart
Future<List<{Model}>> getAll() async {
  if (useMock) {
    return getMock{Model}sWithDelay();
  }

  final response = await _dio.get('/api/v1/{feature}s');
  final List<dynamic> data = response.data['data'];
  return data.map((e) => {Model}.fromJson(e)).toList();
}

Future<{Model}> getById(int id) async {
  if (useMock) {
    await Future.delayed(const Duration(milliseconds: 300));
    return mock{Model}s.firstWhere((e) => e.id == id);
  }

  final response = await _dio.get('/api/v1/{feature}s/$id');
  return {Model}.fromJson(response.data['data']);
}

Future<int> create({Model}CreateRequest request) async {
  if (useMock) {
    await Future.delayed(const Duration(milliseconds: 500));
    return 1; // Mock ID
  }

  final response = await _dio.post(
    '/api/v1/{feature}s',
    data: request.toJson(),
  );
  return response.data['data'] as int;
}

Future<void> update(int id, {Model}UpdateRequest request) async {
  if (useMock) {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }

  await _dio.put('/api/v1/{feature}s/$id', data: request.toJson());
}

Future<void> delete(int id) async {
  if (useMock) {
    await Future.delayed(const Duration(milliseconds: 300));
    return;
  }

  await _dio.delete('/api/v1/{feature}s/$id');
}
```

### Phase 7: 통합 테스트
```
1. Backend 서버 실행 (./gradlew bootRun)
2. Flutter 앱에서 USE_MOCK=false로 실행
3. 모든 CRUD 동작 확인
```

### Phase 8: 문서 업데이트
```
1. docs/tech/api-spec.md 업데이트
2. Feature 상태를 completed로 변경
```

**api-spec.md 업데이트**:
```markdown
## {Feature} API

### Base URL
`/api/v1/{feature}s`

### Endpoints

| Method | URL | 설명 | Request | Response |
|--------|-----|------|---------|----------|
| GET | / | 전체 조회 | - | List<{Feature}Response> |
| GET | /{id} | 상세 조회 | - | {Feature}Response |
| POST | / | 생성 | {Feature}CreateRequest | Long |
| PUT | /{id} | 수정 | {Feature}UpdateRequest | - |
| DELETE | /{id} | 삭제 | - | - |

### Request DTO

#### {Feature}CreateRequest
| Field | Type | Required | Validation |
|-------|------|----------|------------|
| title | String | Yes | @NotBlank, @Size(max=255) |
| description | String | No | @Size(max=1000) |
| artistId | Long | Yes | @NotNull, @Positive |

### Response DTO

#### {Feature}Response
| Field | Type | Description |
|-------|------|-------------|
| id | Long | 고유 식별자 |
| title | String | 제목 |
| description | String | 설명 |
| artistId | Long | 아티스트 ID |
| artistName | String | 아티스트 이름 |
| createdAt | LocalDateTime | 생성일시 |
```

## 완료 조건
- [ ] DTO 생성 (Request/Response)
- [ ] Service 구현
- [ ] Controller 구현
- [ ] API 테스트 작성
- [ ] `./gradlew test` 성공
- [ ] Flutter Repository Real API 연동
- [ ] 통합 테스트 성공 (USE_MOCK=false)
- [ ] `docs/tech/api-spec.md` 업데이트

## Feature 완료
모든 단계 완료 후:
1. `docs/project/phases/phase{N}-plan.md`에서 Feature를 `[status: completed]`로 변경
2. `/next` 명령으로 다음 작업 확인
