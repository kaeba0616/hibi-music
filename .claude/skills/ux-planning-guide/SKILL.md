# UX Planning Guide Skill

Step 1: UX Planning & Design의 상세 가이드입니다.

## 트리거
`/ux-plan <feature-name> <feature-id>` 커맨드 실행 시

## 체크리스트

### Phase 1: PRD 분석
- [ ] `docs/product/prd-main.md` 읽기
- [ ] 해당 Feature의 Acceptance Criteria(AC) 추출
- [ ] AC를 검증 가능한 형태로 정리

**AC 형식**:
```markdown
### AC-{feature-id}-{N}: {AC 제목}
- Given: {사전 조건}
- When: {사용자 행동}
- Then: {예상 결과}
```

### Phase 2: 사용자 여정 설계
- [ ] 시작점 정의 (사용자가 이 기능에 어떻게 접근하는지)
- [ ] 주요 여정 단계 나열
- [ ] 분기점 및 대체 경로 정의
- [ ] 종료점 정의 (성공/실패 시나리오)

**여정 형식**:
```markdown
## 사용자 여정

### 정상 플로우
1. 메인 화면 → 기능 버튼 탭
2. 기능 화면 → 데이터 입력
3. 확인 버튼 탭 → 성공 메시지

### 대체 플로우
- 데이터 없음: Empty State 표시
- 에러 발생: Error State 표시
```

### Phase 3: 화면 구조 정의
- [ ] 각 화면의 URL/Route 정의
- [ ] 화면별 UI 요소 나열
- [ ] 상태별 UI 정의 (Loading, Empty, Error, Success)

**화면 형식**:
```markdown
## 화면: {화면명}

### 기본 정보
- Route: `/feature/screen`
- 타입: 목록 | 상세 | 폼 | 다이얼로그

### UI 요소
- [ ] AppBar: {제목}
- [ ] ListView: {아이템 구성}
- [ ] FAB: {액션}
- [ ] BottomSheet: {내용}

### 상태별 UI
| 상태 | UI |
|------|-----|
| Loading | CircularProgressIndicator |
| Empty | EmptyState 위젯 + CTA |
| Error | ErrorState 위젯 + 재시도 버튼 |
| Success | 데이터 표시 |
```

### Phase 4: AC ↔ 화면 매핑
- [ ] 각 AC가 어느 화면에서 검증되는지 연결
- [ ] 누락된 AC 없는지 확인

**매핑 테이블**:
```markdown
| AC ID | AC 설명 | 검증 화면 | UI 요소 |
|-------|---------|----------|---------|
| AC-f2-1 | 오늘의 노래 표시 | DailySongScreen | SongCard |
| AC-f2-2 | 좋아요 기능 | DailySongScreen | LikeButton |
```

### Phase 5: 문서 생성
- [ ] `docs/ux/features/{feature-name}-flow.md` 생성
- [ ] `docs/ux/features/{feature-name}-screens.md` 생성

## 문서 템플릿

### {feature-name}-flow.md
```markdown
# {Feature Name} - UX Flow

## 1. 개요
- Feature ID: F{N}
- 설명: {기능 설명}

## 2. Acceptance Criteria
{AC 목록}

## 3. 사용자 여정
{여정 다이어그램/설명}

## 4. AC ↔ 화면 매핑
{매핑 테이블}
```

### {feature-name}-screens.md
```markdown
# {Feature Name} - Screen Specifications

## 화면 목록
1. {ScreenName1}
2. {ScreenName2}

## 화면 상세

### 1. {ScreenName1}
{화면 상세 정보}
```

## 완료 기준
- [ ] 모든 AC가 화면에 매핑됨
- [ ] 각 화면의 UI 요소 정의됨
- [ ] 모든 상태(Loading, Empty, Error) 정의됨
- [ ] Flow 문서 생성됨
- [ ] Screens 문서 생성됨

## 다음 단계
사용자 승인 후 `/mock-ui {feature-name} {feature-id}`로 진행
