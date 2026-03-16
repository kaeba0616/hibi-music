# Spring API Guide Skill

Step 4: Spring Boot API Implementation의 상세 가이드입니다.

## 트리거
`/implement-api <feature-name> <feature-id>` 커맨드 실행 시

## 전제조건
- Step 3 (JPA Entity Design) 완료
- Entity 및 Repository 존재
- `./gradlew build` 성공

## 체크리스트

### Phase 1: Entity 확인
- [ ] Entity 클래스 확인
- [ ] Repository 인터페이스 확인
- [ ] 관계 매핑 확인

### Phase 2: DTO 생성
- [ ] `domain/{feature}/dto/request/` 폴더 생성
- [ ] `domain/{feature}/dto/response/` 폴더 생성
- [ ] Request DTO 작성 (Validation 포함)
- [ ] Response DTO 작성

**Request DTO 템플릿**:
```java
// domain/{feature}/dto/request/{Feature}CreateRequest.java

package com.hibi.server.domain.{feature}.dto.request;

import jakarta.validation.constraints.*;

public record {Feature}CreateRequest(
    @NotBlank(message = "제목은 필수입니다")
    @Size(max = 255, message = "제목은 255자 이하여야 합니다")
    String title,

    @Size(max = 1000, message = "설명은 1000자 이하여야 합니다")
    String description,

    @NotNull(message = "아티스트 ID는 필수입니다")
    Long artistId
) {}
```

```java
// domain/{feature}/dto/request/{Feature}UpdateRequest.java

package com.hibi.server.domain.{feature}.dto.request;

import jakarta.validation.constraints.*;

public record {Feature}UpdateRequest(
    @NotBlank(message = "제목은 필수입니다")
    String title,

    String description
) {}
```

**Response DTO 템플릿**:
```java
// domain/{feature}/dto/response/{Feature}Response.java

package com.hibi.server.domain.{feature}.dto.response;

import com.hibi.server.domain.{feature}.entity.{Entity};
import java.time.LocalDateTime;

public record {Feature}Response(
    Long id,
    String title,
    String description,
    Long artistId,
    String artistName,
    LocalDateTime createdAt
) {
    public static {Feature}Response from({Entity} entity) {
        return new {Feature}Response(
            entity.getId(),
            entity.getTitle(),
            entity.getDescription(),
            entity.getArtist().getId(),
            entity.getArtist().getName(),
            entity.getCreatedAt()
        );
    }
}
```

### Phase 3: Service 구현
- [ ] `domain/{feature}/service/{Feature}Service.java` 작성
- [ ] CRUD 비즈니스 로직 구현

**Service 템플릿**:
```java
// domain/{feature}/service/{Feature}Service.java

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
        {Entity} entity = {entity}Repository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));
        return {Feature}Response.from(entity);
    }

    @Transactional
    public void create({Feature}CreateRequest request) {
        Artist artist = artistRepository.findById(request.artistId())
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        {Entity} entity = {Entity}.builder()
                .title(request.title())
                .description(request.description())
                .artist(artist)
                .build();

        {entity}Repository.save(entity);
    }

    @Transactional
    public void update(Long id, {Feature}UpdateRequest request) {
        {Entity} entity = {entity}Repository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        entity.updateTitle(request.title());
        // 추가 업데이트 로직
    }

    @Transactional
    public void delete(Long id) {
        {Entity} entity = {entity}Repository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_FOUND));

        {entity}Repository.delete(entity);
    }
}
```

### Phase 4: Controller 구현
- [ ] `domain/{feature}/controller/{Feature}Controller.java` 작성
- [ ] REST Endpoint 구현
- [ ] Swagger 어노테이션 추가

**Controller 템플릿**:
```java
// domain/{feature}/controller/{Feature}Controller.java

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
@Tag(name = "{Feature}", description = "{Feature} API")
public class {Feature}Controller {

    private final {Feature}Service {feature}Service;

    @GetMapping
    @Operation(summary = "전체 {Feature} 조회")
    public ResponseEntity<SuccessResponse<List<{Feature}Response>>> getAll() {
        return ResponseEntity.ok(
            SuccessResponse.success("조회 성공", {feature}Service.getAll())
        );
    }

    @GetMapping("/{id}")
    @Operation(summary = "{Feature} 상세 조회")
    public ResponseEntity<SuccessResponse<{Feature}Response>> getById(
            @PathVariable Long id) {
        return ResponseEntity.ok(
            SuccessResponse.success("조회 성공", {feature}Service.getById(id))
        );
    }

    @PostMapping
    @Operation(summary = "{Feature} 생성")
    public ResponseEntity<SuccessResponse<?>> create(
            @RequestBody @Valid {Feature}CreateRequest request) {
        {feature}Service.create(request);
        return ResponseEntity.ok(SuccessResponse.success("{Feature} 생성 성공"));
    }

    @PutMapping("/{id}")
    @Operation(summary = "{Feature} 수정")
    public ResponseEntity<SuccessResponse<?>> update(
            @PathVariable Long id,
            @RequestBody @Valid {Feature}UpdateRequest request) {
        {feature}Service.update(id, request);
        return ResponseEntity.ok(SuccessResponse.success("{Feature} 수정 성공"));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "{Feature} 삭제")
    public ResponseEntity<SuccessResponse<?>> delete(@PathVariable Long id) {
        {feature}Service.delete(id);
        return ResponseEntity.ok(SuccessResponse.success("{Feature} 삭제 성공"));
    }
}
```

### Phase 5: API 테스트 작성
- [ ] `src/test/java/.../domain/{feature}/` 폴더 생성
- [ ] Controller 테스트 작성

**테스트 템플릿**:
```java
// src/test/java/.../domain/{feature}/{Feature}ControllerTest.java

package com.hibi.server.domain.{feature};

import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

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
                .andExpect(jsonPath("$.message").value("조회 성공"));
    }

    @Test
    @DisplayName("{Feature} 생성 성공")
    void createSuccess() throws Exception {
        String requestBody = """
            {
                "title": "테스트 제목",
                "description": "테스트 설명",
                "artistId": 1
            }
            """;

        mockMvc.perform(post("/api/v1/{feature}s")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("{Feature} 생성 성공"));
    }
}
```

### Phase 6: Flutter Repository 업데이트
- [ ] `hibi_front/lib/features/{feature}/repos/{feature}_repo.dart` 수정
- [ ] Real API 호출 구현

**Real API 구현 예시**:
```dart
Future<List<{Model}>> getAll() async {
  if (useMock) {
    return getMock{Model}sWithDelay();
  }

  // Real API 구현
  final response = await _dio.get('/api/v1/{feature}s');
  final data = response.data['data'] as List;
  return data.map((e) => {Model}.fromJson(e)).toList();
}

Future<void> create({Model}CreateRequest request) async {
  if (useMock) {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }

  await _dio.post('/api/v1/{feature}s', data: request.toJson());
}
```

### Phase 7: 통합 테스트
- [ ] Backend 서버 실행
- [ ] Flutter 앱에서 Real API 호출 테스트
- [ ] 모든 CRUD 동작 확인

### Phase 8: 문서 업데이트
- [ ] `docs/tech/api-spec.md` 업데이트

**api-spec.md 형식**:
```markdown
## {Feature} API

### Endpoints
| Method | URL | 설명 |
|--------|-----|------|
| GET | /api/v1/{feature}s | 전체 조회 |
| GET | /api/v1/{feature}s/{id} | 상세 조회 |
| POST | /api/v1/{feature}s | 생성 |
| PUT | /api/v1/{feature}s/{id} | 수정 |
| DELETE | /api/v1/{feature}s/{id} | 삭제 |

### Request/Response 예시
{상세 예시}
```

## 완료 기준
- [ ] DTO 생성 (Request/Response)
- [ ] Service 구현
- [ ] Controller 구현
- [ ] API 테스트 작성 및 통과
- [ ] `./gradlew test` 성공
- [ ] Flutter Repository Real API 연동
- [ ] 통합 테스트 성공
- [ ] `docs/tech/api-spec.md` 업데이트

## Feature 완료
4단계가 모두 완료되면:
1. `docs/project/phases/phase{N}-plan.md`에서 해당 Feature를 `[status: completed]`로 변경
2. 다음 Feature 또는 `/next`로 다음 작업 확인
