# Phase 4: Notion PRD 신규 요구사항 구현 계획

## 개요
- Phase ID: 4
- Phase 이름: Enhancement & Notion PRD Sync
- Status: [status: planned]
- 목표: Notion PRD에서 발견된 미구현 요구사항을 기존 기능에 통합 구현

---

## 배경

Phase 1~3에서 12개 Feature(F1~F12)를 모두 완료했으나,
Notion PRD(https://www.notion.so/PRD-31d89d998f5f80628074e06b986e18d5) 동기화 과정에서
기존 PRD에 반영되었지만 아직 구현되지 않은 요구사항들이 발견됨.

참고 문서: `docs/product/notion-prd-sync.md`

---

## Features 상세

### F13: 온보딩 & 소셜 로그인 [status: in-progress]

#### 설명
앱 시작 시 온보딩 화면을 제공하고, 카카오/구글/네이버 소셜 로그인을 지원한다.

#### 관련 AC
- AC-F1-5: 온보딩 페이지 (메인 이동, 로그인, 회원가입 버튼)
- AC-F1-6: 소셜 로그인 (카카오/구글/네이버)

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [ ] Step 3: JPA Entity Design
- [ ] Step 4: Spring Boot API

#### 관련 파일
- UX 문서: `docs/ux/features/onboarding-social-login-flow.md`, `onboarding-social-login-screens.md`
- Frontend: `hibi_front/lib/features/onboarding/`
  - models/social_provider.dart - SocialProvider enum (카카오/구글/네이버)
  - mocks/onboarding_mock.dart - Mock 소셜 로그인 응답
  - viewmodels/onboarding_viewmodel.dart - SocialLoginState + OnboardingViewModel
  - widgets/social_login_button.dart - SocialLoginButton, SocialLoginButtonRow, SocialDivider
  - views/onboarding_view.dart - OB-01 온보딩 화면 (재구현)
  - views/social_auth_waiting_view.dart - OB-03 소셜 인증 대기 화면
- Frontend 확장:
  - authentication/views/login_view.dart - OB-02 로그인 화면 (소셜 버튼 통합)
  - authentication/viewmodels/login_view_model.dart - 로그아웃 → 온보딩 이동
  - router.dart - 온보딩 라우트 추가, 비로그인 → 온보딩 리다이렉트

#### 구현 범위
- **온보딩 화면**: 앱 최초 진입/로그아웃 시 표시, 3개 버튼(메인 이동, 로그인, 회원가입)
- **소셜 로그인**: 카카오/구글/네이버 OAuth 연동
- **소셜 인증 대기 화면**: 소셜 로그인 진행 중 대기 화면
- **기존 코드 확장**: `hibi_front/lib/features/authentication/`, `hibi_backend/.../domain/auth/`

#### 의존성
- 없음 (독립 실행 가능)

---

### F14: 이메일 인증 & 회원가입 강화 [status: todo]

#### 설명
회원가입 시 이메일 인증 2단계 흐름을 추가하고, 비밀번호 규칙/닉네임 변경 제한을 강화한다.

#### 관련 AC
- AC-F1-7: 이메일 인증 (중복 체크 + 인증번호 발송)
- AC-F1-8: 인증번호 확인 (인증 완료 → 개인정보 등록)
- AC-F1-9: 닉네임 변경 제한 (1달 1회, 금칙어)
- AC-F1-10: 비밀번호 규칙 (8자↑, 영문+숫자+특수)
- AC-F1-11: 로그아웃 (토큰 삭제, 온보딩 이동)

#### Step 완료 현황
- [ ] Step 1: UX Planning
- [ ] Step 2: Flutter Mock UI
- [ ] Step 3: JPA Entity Design
- [ ] Step 4: Spring Boot API

#### 구현 범위
- **이메일 인증 흐름**: 이메일 입력 → 중복 체크 → 인증번호 발송 → 인증 확인 → 개인정보 등록
- **비밀번호 규칙 강화**: 프론트/백엔드 모두 validation (최소 8자, 영문+숫자+특수)
- **닉네임 변경 제한**: 1달 1회 제한 로직, 금칙어 필터링
- **로그아웃 개선**: 토큰/세션 완전 삭제, 온보딩 페이지로 이동
- **기존 코드 확장**: `hibi_front/lib/features/authentication/`, `hibi_backend/.../domain/auth/`, `domain/member/`

#### 의존성
- F13 (온보딩 화면이 먼저 있어야 로그아웃 후 이동 가능)

---

### F15: 연관곡 & 유튜브 임베드 [status: todo]

#### 설명
오늘의 곡 상세 화면에 유튜브 영상 임베드와 연관곡 목록을 추가하고, 좋아요 곡 모아보기 페이지를 구현한다.

#### 관련 AC
- AC-F2-5: 유튜브 영상 임베드
- AC-F2-6: 연관곡 표시 (제목, 아티스트, 선정 이유)
- AC-F2-7: 좋아요 곡 모아보기

#### Step 완료 현황
- [ ] Step 1: UX Planning
- [ ] Step 2: Flutter Mock UI
- [ ] Step 3: JPA Entity Design
- [ ] Step 4: Spring Boot API

#### 구현 범위
- **유튜브 임베드**: Song 엔티티에 youtubeUrl 필드 추가, Flutter에서 youtube_player 위젯
- **연관곡**: RelatedSong 엔티티 생성, 오늘의 곡 하단에 연관곡 리스트 표시
- **좋아요 곡 모아보기**: 별도 페이지, 좋아요 누른 곡 목록 (제목, 아티스트)
- **기존 코드 확장**: `hibi_front/lib/features/daily-song/`, `hibi_backend/.../domain/song/`

#### 의존성
- 없음 (독립 실행 가능)

---

### F16: 댓글 기능 강화 [status: todo]

#### 설명
댓글 추천 Top3 노출, 댓글 신고, 부적절 댓글 필터링 기능을 추가한다.

#### 관련 AC
- AC-F6-6: 댓글 추천 Top3 최상단 노출
- AC-F6-7: 댓글 신고
- AC-F6-8: 부적절 댓글 필터링

#### Step 완료 현황
- [ ] Step 1: UX Planning
- [ ] Step 2: Flutter Mock UI
- [ ] Step 3: JPA Entity Design
- [ ] Step 4: Spring Boot API

#### 구현 범위
- **추천 Top3**: 좋아요 수 기준 상위 3개 댓글을 최상단에 별도 섹션으로 표시
- **댓글 신고**: 기존 Report 기능과 연동 (댓글에 신고 버튼 추가)
- **부적절 댓글 필터링**: 금칙어 기반 필터링 로직 (백엔드 서비스)
- **기존 코드 확장**: `hibi_front/lib/features/comments/`, `hibi_backend/.../domain/comment/`

#### 의존성
- 없음 (독립 실행 가능)

---

### F17: 마이페이지 강화 [status: todo]

#### 설명
마이페이지에 내가 쓴 댓글 목록과 푸시 알림 설정 기능을 추가하고, 문의 작성 제한을 적용한다.

#### 관련 AC
- 공통 UI/UX: 내가 쓴 댓글 목록 (클릭 시 해당 곡 댓글 위치 이동)
- 공통 UI/UX: 푸시 알림 on/off 토글
- AC-F10-8: 문의 작성 제한 (최소 10자, 일일 3개)

#### Step 완료 현황
- [ ] Step 1: UX Planning
- [ ] Step 2: Flutter Mock UI
- [ ] Step 3: JPA Entity Design
- [ ] Step 4: Spring Boot API

#### 구현 범위
- **내가 쓴 댓글 목록**: 마이페이지에서 본인 댓글 조회, 클릭 시 해당 곡 페이지 댓글 위치로 이동
- **푸시 알림 설정**: FCM 연동, 알림 on/off 토글, Member 엔티티에 pushEnabled 필드 추가
- **문의 작성 제한**: 내용 최소 10자 validation, 일일 3개 제한 로직 (백엔드)
- **기존 코드 확장**: `hibi_front/lib/features/users/`, `hibi_front/lib/features/settings/`, `hibi_backend/.../domain/member/`, `domain/question/`

#### 의존성
- 없음 (독립 실행 가능)

---

### F18: 관리자 기능 강화 [status: todo]

#### 설명
오늘의 곡 등록 상세화, 예약 게시 기능, 관리자 댓글 관리를 추가한다.

#### 관련 AC
- AC-F12-12: 오늘의 곡 등록 상세 (한/영/일 제목, 아티스트 자동완성, 스토리, 가사, 연관곡)
- AC-F12-13: 예약 게시 (공개 시간 설정, 미작성 곡 예약 불가)
- AC-F12-14: 관리자 댓글 관리 (목록 조회, 삭제)

#### Step 완료 현황
- [ ] Step 1: UX Planning
- [ ] Step 2: Flutter Mock UI
- [ ] Step 3: JPA Entity Design
- [ ] Step 4: Spring Boot API

#### 구현 범위
- **곡 등록 상세**: 곡 제목 3개 언어(한/영/일), 아티스트 자동완성, 스토리/가사 입력, 연관곡 리스트 연결
- **예약 게시**: ScheduledPublish 엔티티, 공개 시간 설정 UI, 스케줄러(Spring @Scheduled)
- **댓글 관리**: 관리자 댓글 목록 화면 (작성일/내용/작성자), 삭제 기능
- **기존 코드 확장**: `hibi_front/lib/features/management/`, `hibi_backend/.../domain/admin/`, `domain/song/`

#### 의존성
- F15 (연관곡 엔티티가 먼저 생성되어야 곡 등록에서 연관곡 연결 가능)

---

## Feature 의존성 그래프

```
F13 (온보딩 & 소셜) ──→ F14 (이메일 인증 & 강화)
F15 (연관곡 & 유튜브) ──→ F18 (관리자 강화)
F16 (댓글 강화) ──→ 독립
F17 (마이페이지 강화) ──→ 독립
```

## 추천 실행 순서

의존성을 고려한 최적 순서:

| 순서 | Feature | 이유 |
|------|---------|------|
| 1 | F13: 온보딩 & 소셜 로그인 | F14의 선행 조건, 사용자 진입점 |
| 2 | F15: 연관곡 & 유튜브 | F18의 선행 조건, 핵심 콘텐츠 강화 |
| 3 | F14: 이메일 인증 & 강화 | F13 완료 후 진행, 보안 강화 |
| 4 | F16: 댓글 강화 | 독립 실행, 커뮤니티 품질 개선 |
| 5 | F17: 마이페이지 강화 | 독립 실행, UX 개선 |
| 6 | F18: 관리자 강화 | F15 완료 후 진행, 운영 도구 |

> 병렬 실행 가능: F13+F15 동시 시작, F16+F17 동시 시작

---

## Phase 4 진행률

| Feature | Step 1 | Step 2 | Step 3 | Step 4 | Status |
|---------|--------|--------|--------|--------|--------|
| F13: 온보딩 & 소셜 로그인 | Done | Done | - | - | in-progress |
| F14: 이메일 인증 & 강화 | - | - | - | - | todo |
| F15: 연관곡 & 유튜브 | - | - | - | - | todo |
| F16: 댓글 강화 | - | - | - | - | todo |
| F17: 마이페이지 강화 | - | - | - | - | todo |
| F18: 관리자 강화 | - | - | - | - | todo |

**Phase 4 진행률**: 0/6 Features (0%)
