# Phase 1: MVP Core 계획

## 개요
- Phase ID: 1
- Phase 이름: MVP Core
- Status: [status: completed]
- 목표: 핵심 기능 구현 및 베타 테스트

---

## Features 상세

### F1: Auth & User (인증 및 유저 관리) [status: completed]

#### 설명
사용자 회원가입, 로그인, 프로필 관리 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 관련 파일
- Frontend: `hibi_front/lib/features/authentication/`
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/auth/`, `domain/member/`

---

### F2: Daily Song (오늘의 노래) [status: completed]

#### 설명
매일 추천되는 JPOP 노래를 확인하고 좋아요를 누르는 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 완료
모든 Step 완료됨

#### 관련 파일
- Frontend: `hibi_front/lib/features/daily-song/`
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/song/`

---

### F3: Artist (아티스트 관리) [status: completed]

#### 설명
아티스트 목록 조회, 상세 정보 확인, 팔로우 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 완료
모든 Step 완료됨

#### 관련 파일
- Frontend: `hibi_front/lib/features/artists/`
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/artist/`, `domain/artistfollow/`

---

### F4: Calendar (노래 기록 캘린더) [status: completed]

#### 설명
과거에 추천받은 노래들을 캘린더 형식으로 확인하는 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design (F2 재사용 - 별도 Entity 불필요)
- [x] Step 4: Spring Boot API (F2 재사용 - `/api/v1/daily-songs/by-month`)

#### 완료
모든 Step 완료됨 (Step 3, 4는 F2 Daily Song API 재사용)

#### 관련 파일
- Frontend: `hibi_front/lib/features/calendar/`
- Backend: F2 Daily Song API 재사용 (`/api/v1/daily-songs/by-month`)

---

## Phase 1 진행률

| Feature | Step 1 | Step 2 | Step 3 | Step 4 | Status |
|---------|--------|--------|--------|--------|--------|
| F1: Auth | Done | Done | Done | Done | completed |
| F2: Daily Song | Done | Done | Done | Done | completed |
| F3: Artist | Done | Done | Done | Done | completed |
| F4: Calendar | Done | Done | Done* | Done* | completed |

*F2 API 재사용

**Phase 1 진행률**: 4/4 Features (100%) - **완료!**
