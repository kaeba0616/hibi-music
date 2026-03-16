# Backend 테스트 케이스 상세

## 1. 인증 관련 (F1: Auth)

### 1.1 AuthService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| AUTH-U-01 | 회원가입 성공 | 유효한 이메일, 비밀번호, 닉네임 | Member 생성, 토큰 반환 | P0 |
| AUTH-U-02 | 회원가입 실패 - 중복 이메일 | 기존 이메일 | EMAIL_ALREADY_EXISTS 예외 | P0 |
| AUTH-U-03 | 회원가입 실패 - 중복 닉네임 | 기존 닉네임 | NICKNAME_ALREADY_EXISTS 예외 | P0 |
| AUTH-U-04 | 로그인 성공 | 올바른 이메일/비밀번호 | 토큰 반환 | P0 |
| AUTH-U-05 | 로그인 실패 - 잘못된 비밀번호 | 틀린 비밀번호 | BAD_CREDENTIALS 예외 | P0 |
| AUTH-U-06 | 로그인 실패 - 존재하지 않는 이메일 | 미등록 이메일 | BAD_CREDENTIALS 예외 | P0 |
| AUTH-U-07 | 토큰 갱신 성공 | 유효한 refreshToken | 새 accessToken 반환 | P0 |
| AUTH-U-08 | 토큰 갱신 실패 - 만료된 토큰 | 만료된 refreshToken | INVALID_REFRESH_TOKEN 예외 | P0 |

### 1.2 AuthController 통합 테스트

| TC-ID | 테스트 케이스 | HTTP 요청 | 예상 응답 | 우선순위 |
|-------|--------------|-----------|-----------|----------|
| AUTH-I-01 | POST /auth/signup 성공 | 유효한 요청 바디 | 201, 토큰 반환 | P0 |
| AUTH-I-02 | POST /auth/signup 유효성 검사 실패 | 빈 이메일 | 400, 에러 메시지 | P0 |
| AUTH-I-03 | POST /auth/login 성공 | 올바른 자격증명 | 200, 토큰 반환 | P0 |
| AUTH-I-04 | POST /auth/refresh 성공 | 유효한 refreshToken | 200, 새 토큰 | P0 |

---

## 2. 회원 관련 (F1: Member)

### 2.1 MemberService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| MEM-U-01 | 내 정보 조회 | 유효한 memberId | Member 정보 반환 | P0 |
| MEM-U-02 | 내 정보 수정 - 닉네임 | 새 닉네임 | 닉네임 업데이트 | P1 |
| MEM-U-03 | 내 정보 수정 - 중복 닉네임 | 기존 닉네임 | 예외 발생 | P1 |
| MEM-U-04 | 프로필 이미지 수정 | 새 이미지 URL | 이미지 업데이트 | P1 |

### 2.2 MemberRepository 테스트

| TC-ID | 테스트 케이스 | 메서드 | 예상 결과 | 우선순위 |
|-------|--------------|--------|-----------|----------|
| MEM-R-01 | 이메일로 회원 조회 | findByEmail() | Optional<Member> | P0 |
| MEM-R-02 | 닉네임 중복 확인 | existsByNickname() | boolean | P0 |
| MEM-R-03 | 삭제되지 않은 회원 수 | countByDeletedAtIsNull() | long | P1 |

---

## 3. Daily Song 관련 (F2)

### 3.1 DailySongService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| DS-U-01 | 오늘의 노래 조회 | 오늘 날짜 | Song 반환 | P0 |
| DS-U-02 | 오늘의 노래 없음 | 추천곡 없는 날짜 | null 반환 | P0 |
| DS-U-03 | 날짜별 노래 조회 | 특정 날짜 | Song 반환 | P1 |
| DS-U-04 | 월별 노래 목록 | 연/월 | List<Song> | P1 |
| DS-U-05 | 좋아요 토글 - 추가 | songId, memberId | isLiked=true | P0 |
| DS-U-06 | 좋아요 토글 - 취소 | 이미 좋아요한 곡 | isLiked=false | P0 |

---

## 4. 아티스트 관련 (F3)

### 4.1 ArtistService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| ART-U-01 | 아티스트 목록 조회 | page, size | Page<Artist> | P0 |
| ART-U-02 | 아티스트 상세 조회 | artistId | Artist + songs | P0 |
| ART-U-03 | 아티스트 검색 | 검색어 | 매칭 아티스트 목록 | P1 |
| ART-U-04 | 팔로우 추가 | artistId, memberId | 팔로우 관계 생성 | P0 |
| ART-U-05 | 팔로우 취소 | artistId, memberId | 팔로우 관계 삭제 | P0 |
| ART-U-06 | 팔로우한 아티스트 목록 | memberId | List<Artist> | P1 |

---

## 5. 게시글 관련 (F5: Post)

### 5.1 PostService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| POST-U-01 | 게시글 목록 조회 | page, size | Page<Post> | P0 |
| POST-U-02 | 게시글 상세 조회 | postId | Post + author | P0 |
| POST-U-03 | 게시글 작성 | content, images, taggedSongId | Post 생성 | P0 |
| POST-U-04 | 게시글 수정 - 본인 | postId, 새 내용 | Post 업데이트 | P0 |
| POST-U-05 | 게시글 수정 - 타인 | 다른 사용자 게시글 | FORBIDDEN 예외 | P0 |
| POST-U-06 | 게시글 삭제 - 본인 | postId | 삭제 성공 | P0 |
| POST-U-07 | 게시글 삭제 - 타인 | 다른 사용자 게시글 | FORBIDDEN 예외 | P0 |
| POST-U-08 | 게시글 좋아요 토글 | postId, memberId | 좋아요 상태 변경 | P0 |

### 5.2 PostRepository 테스트

| TC-ID | 테스트 케이스 | 메서드 | 예상 결과 | 우선순위 |
|-------|--------------|--------|-----------|----------|
| POST-R-01 | 사용자별 게시글 조회 | findByMemberId() | List<Post> | P0 |
| POST-R-02 | 팔로잉 피드 조회 | findByMemberIdIn() | Page<Post> | P1 |

---

## 6. 댓글 관련 (F6: Comment)

### 6.1 CommentService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| CMT-U-01 | 댓글 목록 조회 | postId | 계층형 댓글 목록 | P0 |
| CMT-U-02 | 댓글 작성 | content, postId | Comment 생성 | P0 |
| CMT-U-03 | 대댓글 작성 | content, parentId | 대댓글 생성 | P0 |
| CMT-U-04 | 대대댓글 시도 | 대댓글에 답글 | 예외 발생 | P0 |
| CMT-U-05 | 댓글 삭제 - 대댓글 없음 | commentId | Hard Delete | P0 |
| CMT-U-06 | 댓글 삭제 - 대댓글 있음 | commentId | Soft Delete | P0 |
| CMT-U-07 | 댓글 좋아요 토글 | commentId | 좋아요 상태 변경 | P1 |

---

## 7. 팔로우 관련 (F7: Follow)

### 7.1 FollowService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| FLW-U-01 | 사용자 팔로우 | targetUserId | 팔로우 관계 생성 | P0 |
| FLW-U-02 | 자기 자신 팔로우 | 본인 ID | 예외 발생 | P0 |
| FLW-U-03 | 중복 팔로우 | 이미 팔로우 중 | CONFLICT 예외 | P0 |
| FLW-U-04 | 언팔로우 | targetUserId | 팔로우 관계 삭제 | P0 |
| FLW-U-05 | 팔로워 목록 조회 | userId, page | Page<Member> | P0 |
| FLW-U-06 | 팔로잉 목록 조회 | userId, page | Page<Member> | P0 |
| FLW-U-07 | 팔로잉 피드 조회 | memberId | 팔로잉 게시글 목록 | P1 |

---

## 8. 검색 관련 (F8: Search)

### 8.1 SearchService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| SRC-U-01 | 통합 검색 | keyword | songs, artists, posts, users | P0 |
| SRC-U-02 | 카테고리별 검색 - 노래 | keyword, category=songs | songs만 반환 | P1 |
| SRC-U-03 | 검색 결과 없음 | 매칭 없는 키워드 | 빈 결과 | P0 |
| SRC-U-04 | 빈 검색어 | "" | 예외 발생 | P0 |

---

## 9. FAQ 관련 (F9)

### 9.1 FAQService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| FAQ-U-01 | FAQ 목록 조회 | category (optional) | List<FAQ> | P0 |
| FAQ-U-02 | FAQ 키워드 검색 | keyword | 매칭 FAQ 목록 | P1 |
| FAQ-U-03 | FAQ 상세 조회 | faqId | FAQ 반환 | P1 |
| FAQ-U-04 | 비공개 FAQ 조회 시도 | 비공개 faqId | NOT_FOUND | P1 |

---

## 10. 문의 관련 (F10: Question)

### 10.1 QuestionService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| QST-U-01 | 문의 작성 | type, title, content | Question 생성 | P0 |
| QST-U-02 | 내 문의 목록 조회 | memberId | List<Question> | P0 |
| QST-U-03 | 문의 상세 조회 - 본인 | questionId | Question 반환 | P0 |
| QST-U-04 | 문의 상세 조회 - 타인 | 다른 사용자 문의 | NOT_FOUND | P0 |

---

## 11. 신고 관련 (F11: Report)

### 11.1 ReportService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| RPT-U-01 | 신고 생성 | targetType, targetId, reason | Report 생성 | P0 |
| RPT-U-02 | 본인 콘텐츠 신고 | 본인 게시글 ID | SELF_REPORT 예외 | P0 |
| RPT-U-03 | 중복 신고 | 이미 신고한 대상 | DUPLICATE_REPORT 예외 | P0 |
| RPT-U-04 | 신고 여부 확인 | targetType, targetId | boolean | P0 |
| RPT-U-05 | 존재하지 않는 대상 신고 | 없는 postId | TARGET_NOT_FOUND 예외 | P0 |

---

## 12. 관리자 관련 (F12: Admin)

### 12.1 AdminService 단위 테스트

| TC-ID | 테스트 케이스 | 입력 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| ADM-U-01 | 대시보드 통계 조회 | - | AdminStats | P0 |
| ADM-U-02 | 회원 목록 조회 | status, search, page | AdminMemberListResponse | P0 |
| ADM-U-03 | 회원 상세 조회 | memberId | AdminMemberResponse | P0 |
| ADM-U-04 | 회원 정지 | memberId, 정지 기간 | status=SUSPENDED | P0 |
| ADM-U-05 | 회원 강제탈퇴 | memberId | status=BANNED | P0 |
| ADM-U-06 | 회원 정지 해제 | memberId | status=ACTIVE | P0 |
| ADM-U-07 | 신고 목록 조회 | status, page | AdminReportListResponse | P0 |
| ADM-U-08 | 신고 상세 조회 | reportId | AdminReportResponse | P0 |
| ADM-U-09 | 신고 처리 - 해결 | reportId, RESOLVE | status=RESOLVED | P0 |
| ADM-U-10 | 신고 처리 - 기각 | reportId, DISMISS | status=DISMISSED | P0 |
| ADM-U-11 | 문의 답변 작성 | questionId, answer | status=ANSWERED | P0 |
| ADM-U-12 | FAQ 생성 | FAQSaveRequest | FAQ 생성 | P0 |
| ADM-U-13 | FAQ 수정 | id, FAQSaveRequest | FAQ 업데이트 | P0 |
| ADM-U-14 | FAQ 삭제 | faqId | FAQ 삭제 | P0 |

### 12.2 AdminController 통합 테스트 (권한 검증)

| TC-ID | 테스트 케이스 | 조건 | 예상 응답 | 우선순위 |
|-------|--------------|------|-----------|----------|
| ADM-I-01 | GET /admin/stats - 관리자 | ROLE_ADMIN | 200 OK | P0 |
| ADM-I-02 | GET /admin/stats - 일반 사용자 | ROLE_USER | 403 Forbidden | P0 |
| ADM-I-03 | GET /admin/stats - 미인증 | 토큰 없음 | 401 Unauthorized | P0 |
| ADM-I-04 | POST /admin/members/sanction | ROLE_ADMIN | 200 OK | P0 |
| ADM-I-05 | POST /admin/reports/process | ROLE_ADMIN | 200 OK | P0 |

---

## 13. 보안 테스트

### 13.1 JWT 토큰 검증

| TC-ID | 테스트 케이스 | 조건 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| SEC-01 | 유효한 토큰 | 정상 JWT | 인증 성공 | P0 |
| SEC-02 | 만료된 토큰 | 만료 시간 지난 JWT | 401 Unauthorized | P0 |
| SEC-03 | 변조된 토큰 | 서명 불일치 | 401 Unauthorized | P0 |
| SEC-04 | 토큰 없음 | Authorization 헤더 없음 | 401 Unauthorized | P0 |

### 13.2 권한 검증

| TC-ID | 테스트 케이스 | 조건 | 예상 결과 | 우선순위 |
|-------|--------------|------|-----------|----------|
| SEC-05 | 본인 리소스 접근 | 본인 게시글 수정 | 성공 | P0 |
| SEC-06 | 타인 리소스 접근 | 타인 게시글 수정 | 403 Forbidden | P0 |
| SEC-07 | 관리자 API 접근 | 일반 사용자 | 403 Forbidden | P0 |
