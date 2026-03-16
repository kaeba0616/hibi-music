# /next - 프로젝트 진행 상황 확인

현재 프로젝트 진행 상황을 확인하고 다음 작업을 추천받습니다.

## 실행 방법
`project-progress` 스킬을 사용하여 현재 Phase/Feature 상태를 분석합니다.

## 분석 대상
1. `docs/project/roadmap.md` - 전체 Phase 상태
2. `docs/project/phases/phase*-plan.md` - 현재 Phase의 Feature 진행률
3. `docs/project/features/*.md` - 각 Feature의 Step 완료 현황

## 출력 내용
- 현재 Phase 및 진행률
- 진행 중인 Feature와 다음 Step
- 우선순위별 다음 작업 추천

## 사용 예시
```
/next
```

## 관련 스킬
- `project-progress` - 프로젝트 상태 분석
- `next-phase-feature` - 다음 Phase/Feature 추천
