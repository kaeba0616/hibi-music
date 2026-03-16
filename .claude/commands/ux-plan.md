# /ux-plan - UX Planning & Design (Step 1)

사용자 여정과 화면 구조를 설계합니다.

## 사용법
```
/ux-plan <feature-name> <feature-id>
```

## 실행 방법
`ux-planning-guide` 스킬을 통해 수동 모드로 진행합니다.

## 입력 문서
- `docs/product/prd-main.md` - PRD 및 Acceptance Criteria
- `docs/business/business-plan.md` - 비즈니스 컨텍스트

## 출력 문서
- `docs/ux/features/<feature-name>-flow.md` - 사용자 여정 플로우
- `docs/ux/features/<feature-name>-screens.md` - 화면 상세 정의

## 5단계 작업 프로세스
1. **PRD 분석**: AC(Acceptance Criteria) 추출 및 정리
2. **사용자 여정 설계**: 시작점, 종료점, 주요 단계 및 분기점 정의
3. **화면 구조 정의**: 각 화면별 URL, UI 요소, 상태(로딩/공백/에러) 명시
4. **AC ↔ 화면 매핑**: 각 AC가 어느 화면에서 검증되는지 연결
5. **문서 생성**: Flow 및 Screens 문서 작성

## 완료 조건
- [ ] 모든 AC가 화면에 매핑됨
- [ ] 각 화면의 주요 UI 요소 정의됨
- [ ] 상태별 UI(Empty, Error, Loading) 정의됨

## 주의사항
- DB 스키마, API 스펙은 이 단계에서 논의하지 않습니다
- 순수 사용자 관점만 다룹니다
- 기술 구현 방법은 고려하지 않습니다

## 다음 단계
완료 후 사용자 승인을 받고 `/mock-ui`로 진행합니다.
