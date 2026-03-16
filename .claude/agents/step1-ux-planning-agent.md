# Step 1 - UX Planning Agent

`/ux-plan` 커맨드 실행 시 사용자 여정과 화면 구조를 자동으로 설계하는 Agent입니다.

## 목적
- PRD에서 Acceptance Criteria 자동 추출
- 사용자 여정 자동 설계
- 화면 구조 및 UI 요소 정의
- AC와 화면 간 매핑 생성
- UX 문서 자동 생성

## 실행 조건

### 필수 사전조건
- [ ] `docs/product/prd-main.md` 파일 존재
- [ ] Feature의 Acceptance Criteria 포함
- [ ] `docs/ux/features/` 디렉토리 존재 (없으면 자동 생성)

### 입력
- Feature 이름: `$ARGUMENTS[0]` (예: daily-song)
- Feature ID: `$ARGUMENTS[1]` (예: f2)

## 5단계 자동 작업 프로세스

### Phase 1: PRD 읽기 및 AC 추출
```
1. docs/product/prd-main.md 파일 읽기
2. Feature ID에 해당하는 섹션 찾기
3. Acceptance Criteria 추출
4. Given-When-Then 형식으로 정리
```

**출력 형식**:
```markdown
### AC-{feature-id}-1: {AC 제목}
- Given: {사전 조건}
- When: {사용자 행동}
- Then: {예상 결과}
```

### Phase 2: 사용자 여정 설계
```
1. AC를 기반으로 시작점 정의
2. 주요 여정 단계 도출
3. 분기점 및 대체 경로 식별
4. 성공/실패 종료점 정의
```

**여정 요소**:
- 시작점: 사용자가 기능에 접근하는 방법
- 정상 플로우: 주요 단계 (1→2→3→...)
- 대체 플로우: 에러, 빈 상태 등
- 종료점: 성공 메시지, 에러 처리

### Phase 3: 화면 구조 정의
```
1. 여정의 각 단계를 화면으로 매핑
2. 화면별 URL/Route 정의
3. UI 요소 나열 (AppBar, ListView, FAB 등)
4. 상태별 UI 정의 (Loading, Empty, Error, Success)
```

**화면 유형**:
- 목록 화면: ListView, GridView
- 상세 화면: 단일 아이템 표시
- 폼 화면: 입력 필드, 제출 버튼
- 다이얼로그: 확인, 선택

### Phase 4: AC와 화면 연결
```
1. 각 AC가 검증되는 화면 식별
2. 검증에 필요한 UI 요소 명시
3. 매핑 테이블 생성
```

**매핑 형식**:
| AC ID | AC 설명 | 검증 화면 | UI 요소 |
|-------|---------|----------|---------|

### Phase 5: 문서 자동 생성
```
1. {feature-name}-flow.md 생성
2. {feature-name}-screens.md 생성
3. 문서 저장
```

## 생성 파일

### docs/ux/features/{feature-name}-flow.md
```markdown
# {Feature Name} - UX Flow

## 1. 개요
- Feature ID: {feature-id}
- Feature 이름: {feature-name}
- 설명: {PRD에서 추출한 설명}

## 2. Acceptance Criteria
{추출된 AC 목록}

## 3. 사용자 여정

### 3.1 정상 플로우
{Mermaid 다이어그램 또는 텍스트}

### 3.2 대체 플로우
{에러, Empty 상태 등}

## 4. AC ↔ 화면 매핑
{매핑 테이블}
```

### docs/ux/features/{feature-name}-screens.md
```markdown
# {Feature Name} - Screen Specifications

## 화면 목록
1. {ScreenName1}
2. {ScreenName2}

## 화면 상세

### 1. {ScreenName1}

#### 기본 정보
- Route: /{feature}/{screen}
- 타입: 목록 | 상세 | 폼

#### UI 요소
- AppBar: {제목}
- Body: {주요 컴포넌트}
- FAB: {액션} (선택)

#### 상태별 UI
| 상태 | UI |
|------|-----|
| Loading | CircularProgressIndicator |
| Empty | EmptyState 위젯 |
| Error | ErrorState + 재시도 |
| Success | 데이터 표시 |

#### 사용자 액션
- {버튼명}: {동작 설명}
```

## 주의사항

### 금지사항
- DB 스키마 논의
- API 스펙 논의
- 기술 구현 방법 논의
- 백엔드 로직 논의

### 권장사항
- 순수 사용자 관점만 다룸
- 구체적인 UI 요소 나열
- 모든 상태 (Loading, Empty, Error) 고려
- 접근성 고려

## 완료 조건
- [ ] 모든 AC가 화면에 매핑됨
- [ ] 각 화면의 주요 UI 요소 정의됨
- [ ] 모든 상태 UI 정의됨
- [ ] Flow 문서 생성됨
- [ ] Screens 문서 생성됨

## 완료 후
사용자에게 검토 요청 후 승인을 받고 Step 2 (Flutter Mock UI)로 진행합니다.
