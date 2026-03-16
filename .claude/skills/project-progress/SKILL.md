# Project Progress Skill

프로젝트 진행 상황을 분석하고 다음 작업을 추천합니다.

## 트리거
`/next` 커맨드 실행 시

## 분석 단계

### 1. Roadmap 분석
**파일**: `docs/project/roadmap.md`

```markdown
## Phase N: Phase Name [status: in-progress|completed|planned]
- Features:
  - F1: Feature Name [status: completed]
  - F2: Feature Name [status: in-progress]
  - F3: Feature Name [status: todo]
```

**추출 정보**:
- 현재 진행 중인 Phase
- 완료된 Phase 수 / 전체 Phase 수
- Phase별 Feature 목록

### 2. Phase 상세 분석
**파일**: `docs/project/phases/phase{N}-plan.md`

```markdown
### F{N}: Feature Name [status: in-progress]
- Step 완료 현황:
  - [x] Step 1: UX Planning
  - [x] Step 2: Flutter Mock UI
  - [ ] Step 3: JPA Entity Design
  - [ ] Step 4: Spring Boot API
```

**추출 정보**:
- 현재 Feature의 완료된 Step
- 다음 실행해야 할 Step

### 3. 진행률 계산
```
Phase 진행률 = (완료된 Feature 수 / 전체 Feature 수) × 100%
Feature 진행률 = (완료된 Step 수 / 4) × 100%
전체 진행률 = (완료된 Feature 수 / 전체 Feature 수) × 100%
```

## 출력 형식

```markdown
# 📊 hibi 프로젝트 현황

## 전체 진행률
- 전체: ██████████░░░░░░░░░░ 50%
- Phase 1: ████████████████░░░░ 75%

## 현재 Phase
**Phase 1: MVP Core** [in-progress]

## 진행 중인 Feature
**F2: Daily Song** [Step 3 진행 중]
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [ ] Step 3: JPA Entity Design ← 현재
- [ ] Step 4: Spring Boot API

## 다음 작업 추천
1. `/design-db daily-song f2` - JPA Entity 설계
2. 완료 후 `/implement-api daily-song f2` - API 구현
```

## 주의사항
- 문서가 없으면 초기 설정 안내 제공
- 모든 Feature가 완료되면 다음 Phase 시작 안내
