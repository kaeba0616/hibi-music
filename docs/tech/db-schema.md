# hibi Database Schema

## 1. 개요

hibi 프로젝트의 데이터베이스 스키마 문서입니다.
JPA Entity 기반으로 자동 생성된 테이블 구조를 문서화합니다.

---

## 2. ERD 개요

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│ members  │────▶│  posts   │────▶│ comments │
└──────────┘     └──────────┘     └──────────┘
     │                │
     │                │
     ▼                ▼
┌──────────────┐ ┌──────────┐
│artist_follows│ │song_likes│
└──────────────┘ └──────────┘
     │                │
     │                ▼
     │           ┌──────────┐     ┌──────────┐
     └──────────▶│ artists  │────▶│  albums  │
                 └──────────┘     └──────────┘
                      │                │
                      │                ▼
                      └───────────▶┌──────────┐
                                   │  songs   │
                                   └──────────┘
                                        │
                                        ▼
┌──────────┐     ┌────────────┐  ┌─────────────────┐
│ members  │────▶│ feed_posts │──│feed_post_images │
└──────────┘     └────────────┘  └─────────────────┘
     │                │                    │
     │                │                    ▼
     │                │            ┌──────────────┐
     │                └───────────▶│   comments   │◀──┐
     │                             └──────────────┘   │ (self-ref)
     │                                    │           │
     │                                    └───────────┘
     │                                    │
     ├───────────▶┌─────────────────┐     │
     │            │ feed_post_likes │     ▼
     │            └─────────────────┘  ┌───────────────┐
     │                                 │ comment_likes │
     │                                 └───────────────┘
     │
     │  F7: 회원 팔로우
     │
     └───────────▶┌────────────────┐
                  │ member_follows │◀──┐ (follower)
                  │                │───┘ (following)
                  └────────────────┘
```

**F3 Artist 관계**:
- Member (N) ↔ Artist (M) via artist_follows
- Artist (1) → Albums (N)
- Artist (1) → Songs (N)

**F5 Feed Post 관계**:
- Member (1) → FeedPosts (N)
- FeedPost (1) → FeedPostImages (N, max 4)
- FeedPost (1) → FeedPostLikes (N)
- Member (1) → FeedPostLikes (N)
- Song (1) → FeedPosts (N, optional tag)

---

## 3. 테이블 상세

### 3.1 members (회원)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| email | VARCHAR(255) | NOT NULL, UNIQUE | 이메일 |
| password | VARCHAR(255) | NOT NULL | 비밀번호 (암호화) |
| nickname | VARCHAR(50) | NOT NULL | 닉네임 |
| profile_image | VARCHAR(500) | | 프로필 이미지 URL |
| role | VARCHAR(20) | NOT NULL | 권한 (USER, ADMIN) |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'ACTIVE' | 상태 (ACTIVE, SUSPENDED, BANNED) - F12 |
| suspended_until | DATETIME | | 정지 해제일 - F12 |
| suspended_reason | VARCHAR(300) | | 정지 사유 - F12 |
| created_at | DATETIME | NOT NULL | 가입일 |
| updated_at | DATETIME | | 수정일 |

**회원 상태 ENUM 값** (F12):
| 값 | 설명 |
|----|------|
| ACTIVE | 활성 (정상 상태) |
| SUSPENDED | 정지 (일시 정지) |
| BANNED | 강제 탈퇴 (영구 정지) |

---

### 3.2 artists (아티스트) - F3에서 확장

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| name_kor | VARCHAR(100) | NOT NULL | 한국어 이름 |
| name_eng | VARCHAR(100) | | 영어 이름 |
| name_jp | VARCHAR(100) | | 일본어 이름 |
| profile_url | VARCHAR(512) | | 프로필 이미지 URL |
| description | TEXT | | 아티스트 소개 |

---

### 3.3 artist_follows (아티스트 팔로우) - F3에서 추가

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| member_id | BIGINT | FK, NOT NULL | 회원 ID |
| artist_id | BIGINT | FK, NOT NULL | 아티스트 ID |
| created_at | DATETIME | NOT NULL | 팔로우 시각 |

**제약조건**:
- UNIQUE(member_id, artist_id) - 중복 팔로우 방지

**인덱스**:
- `idx_artist_follows_member`: member_id
- `idx_artist_follows_artist`: artist_id

**관계**:
- `member_id` → `members.id` (N:1)
- `artist_id` → `artists.id` (N:1)

---

### 3.4 albums (앨범) - F2에서 추가

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| name | VARCHAR(255) | NOT NULL | 앨범명 |
| image_url | VARCHAR(512) | | 앨범 이미지 URL |
| release_date | DATE | | 발매일 |
| artist_id | BIGINT | FK, NOT NULL | 아티스트 ID |

**관계**:
- `artist_id` → `artists.id` (N:1)

---

### 3.5 songs (노래) - F2에서 확장

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| title_kor | VARCHAR(255) | NOT NULL | 한국어 제목 |
| title_eng | VARCHAR(255) | | 영어 제목 |
| title_jp | VARCHAR(255) | NOT NULL | 일본어 제목 |
| artist_id | BIGINT | FK, NOT NULL | 아티스트 ID |
| album_id | BIGINT | FK | 앨범 ID |
| genre | VARCHAR(100) | | 장르 |
| lyrics_jp | TEXT | | 일본어 가사 |
| lyrics_kr | TEXT | | 한국어 번역 가사 |
| link_spotify | VARCHAR(512) | | Spotify 링크 |
| link_apple_music | VARCHAR(512) | | Apple Music 링크 |
| link_youtube | VARCHAR(512) | | YouTube 링크 |
| recommend_date | DATE | UNIQUE | 추천 날짜 (Daily Song) |

**인덱스**:
- `idx_songs_artist`: artist_id
- `idx_songs_recommend_date`: recommend_date

**관계**:
- `artist_id` → `artists.id` (N:1)
- `album_id` → `albums.id` (N:1)

---

### 3.6 song_likes (노래 좋아요) - F2에서 구현

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| member_id | BIGINT | FK, NOT NULL | 회원 ID |
| song_id | BIGINT | FK, NOT NULL | 노래 ID |
| created_at | DATETIME | NOT NULL | 좋아요 시각 |

**제약조건**:
- UNIQUE(member_id, song_id) - 중복 좋아요 방지

**인덱스**:
- `idx_song_likes_member`: member_id
- `idx_song_likes_song`: song_id

**관계**:
- `member_id` → `members.id` (N:1)
- `song_id` → `songs.id` (N:1)

---

### 3.7 follows (회원 팔로우) - Phase 2용

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| follower_id | BIGINT | FK, NOT NULL | 팔로워 회원 ID |
| following_id | BIGINT | FK, NOT NULL | 팔로잉 대상 ID |
| following_type | VARCHAR(20) | NOT NULL | 타입 (MEMBER) |
| created_at | DATETIME | NOT NULL | 팔로우 시각 |

**제약조건**:
- UNIQUE(follower_id, following_id, following_type)

---

### 3.8 posts (게시글)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| member_id | BIGINT | FK, NOT NULL | 작성자 ID |
| title | VARCHAR(255) | NOT NULL | 제목 |
| content | TEXT | NOT NULL | 내용 |
| view_count | INT | NOT NULL, DEFAULT 0 | 조회수 |
| created_at | DATETIME | NOT NULL | 작성일 |
| updated_at | DATETIME | | 수정일 |

**인덱스**:
- `idx_posts_member`: member_id
- `idx_posts_created_at`: created_at

**관계**:
- `member_id` → `members.id` (N:1)

---

### 3.9 comments (댓글)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| post_id | BIGINT | FK, NOT NULL | 게시글 ID |
| member_id | BIGINT | FK, NOT NULL | 작성자 ID |
| content | TEXT | NOT NULL | 내용 |
| parent_id | BIGINT | FK | 부모 댓글 ID (대댓글) |
| created_at | DATETIME | NOT NULL | 작성일 |
| updated_at | DATETIME | | 수정일 |

**관계**:
- `post_id` → `posts.id` (N:1)
- `member_id` → `members.id` (N:1)
- `parent_id` → `comments.id` (Self-Reference, N:1)

---

## 4. 관계 요약

| 관계 | 타입 | 설명 |
|------|------|------|
| members → posts | 1:N | 회원이 여러 게시글 작성 |
| members → comments | 1:N | 회원이 여러 댓글 작성 |
| members → song_likes | 1:N | 회원이 여러 노래 좋아요 |
| members → artist_follows | 1:N | 회원이 여러 아티스트 팔로우 |
| artists → artist_follows | 1:N | 아티스트의 팔로워들 |
| artists → albums | 1:N | 아티스트의 여러 앨범 |
| artists → songs | 1:N | 아티스트의 여러 노래 |
| albums → songs | 1:N | 앨범에 포함된 여러 노래 |
| posts → comments | 1:N | 게시글의 여러 댓글 |
| songs → song_likes | 1:N | 노래의 여러 좋아요 |

---

## 5. F3 Artist 파생 필드 (계산)

다음 필드들은 DB에 저장하지 않고 쿼리로 계산합니다:

| 필드명 | 계산 방법 |
|--------|-----------|
| followerCount | `SELECT COUNT(*) FROM artist_follows WHERE artist_id = ?` |
| songCount | `SELECT COUNT(*) FROM songs WHERE artist_id = ?` |
| isFollowing | `SELECT EXISTS(SELECT 1 FROM artist_follows WHERE member_id = ? AND artist_id = ?)` |

---

## 6. F5 피드 게시글 테이블 (Phase 2)

### 6.1 feed_posts (피드 게시글)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| member_id | BIGINT | FK, NOT NULL | 작성자 ID |
| content | VARCHAR(500) | NOT NULL | 본문 내용 |
| song_id | BIGINT | FK | 태그된 노래 ID (nullable) |
| like_count | INT | NOT NULL, DEFAULT 0 | 좋아요 수 |
| comment_count | INT | NOT NULL, DEFAULT 0 | 댓글 수 |
| created_at | DATETIME | NOT NULL | 작성일 |
| updated_at | DATETIME | | 수정일 |

**인덱스**:
- `idx_feed_posts_member`: member_id
- `idx_feed_posts_created_at`: created_at DESC

**관계**:
- `member_id` → `members.id` (N:1)
- `song_id` → `songs.id` (N:1, optional)

---

### 6.2 feed_post_images (피드 게시글 이미지)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| feed_post_id | BIGINT | FK, NOT NULL | 게시글 ID |
| image_url | VARCHAR(512) | NOT NULL | 이미지 URL |
| order_index | INT | NOT NULL | 표시 순서 (0-3) |

**인덱스**:
- `idx_feed_post_images_post`: feed_post_id

**관계**:
- `feed_post_id` → `feed_posts.id` (N:1, CASCADE DELETE)

---

### 6.3 feed_post_likes (피드 게시글 좋아요)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| member_id | BIGINT | FK, NOT NULL | 회원 ID |
| feed_post_id | BIGINT | FK, NOT NULL | 게시글 ID |
| created_at | DATETIME | NOT NULL | 좋아요 시각 |

**제약조건**:
- UNIQUE(member_id, feed_post_id) - 중복 좋아요 방지

**인덱스**:
- `idx_feed_post_likes_member`: member_id
- `idx_feed_post_likes_post`: feed_post_id

**관계**:
- `member_id` → `members.id` (N:1)
- `feed_post_id` → `feed_posts.id` (N:1)

---

## 7. F5 관계 요약

| 관계 | 타입 | 설명 |
|------|------|------|
| members → feed_posts | 1:N | 회원이 여러 피드 게시글 작성 |
| feed_posts → feed_post_images | 1:N | 게시글에 최대 4개 이미지 |
| feed_posts → feed_post_likes | 1:N | 게시글의 여러 좋아요 |
| members → feed_post_likes | 1:N | 회원이 여러 게시글에 좋아요 |
| songs → feed_posts | 1:N | 노래가 여러 게시글에 태그됨 |

---

## 8. F6 댓글 테이블 (Phase 2)

### 8.1 comments (댓글)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| feed_post_id | BIGINT | FK, NOT NULL | 게시글 ID |
| member_id | BIGINT | FK, NOT NULL | 작성자 ID |
| content | VARCHAR(500) | NOT NULL | 댓글 내용 |
| parent_id | BIGINT | FK | 부모 댓글 ID (대댓글) |
| like_count | INT | NOT NULL, DEFAULT 0 | 좋아요 수 |
| is_deleted | BOOLEAN | NOT NULL, DEFAULT false | 삭제 여부 (soft delete) |
| created_at | DATETIME | NOT NULL | 작성일 |
| updated_at | DATETIME | | 수정일 |

**인덱스**:
- `idx_comments_feed_post`: feed_post_id
- `idx_comments_member`: member_id
- `idx_comments_parent`: parent_id
- `idx_comments_created_at`: created_at ASC

**관계**:
- `feed_post_id` → `feed_posts.id` (N:1)
- `member_id` → `members.id` (N:1)
- `parent_id` → `comments.id` (Self-Reference, N:1)

**비고**:
- 대댓글은 1단계만 지원 (대대댓글 불가)
- 대댓글이 있는 댓글 삭제 시 soft delete (is_deleted=true)
- 대댓글이 없는 댓글 삭제 시 hard delete

---

### 8.2 comment_likes (댓글 좋아요)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| member_id | BIGINT | FK, NOT NULL | 회원 ID |
| comment_id | BIGINT | FK, NOT NULL | 댓글 ID |
| created_at | DATETIME | NOT NULL | 좋아요 시각 |

**제약조건**:
- UNIQUE(member_id, comment_id) - 중복 좋아요 방지

**인덱스**:
- `idx_comment_likes_member`: member_id
- `idx_comment_likes_comment`: comment_id

**관계**:
- `member_id` → `members.id` (N:1)
- `comment_id` → `comments.id` (N:1)

---

## 9. F6 관계 요약

| 관계 | 타입 | 설명 |
|------|------|------|
| feed_posts → comments | 1:N | 게시글의 여러 댓글 |
| members → comments | 1:N | 회원이 여러 댓글 작성 |
| comments → comments | 1:N | 원 댓글의 대댓글들 (Self-Reference) |
| comments → comment_likes | 1:N | 댓글의 여러 좋아요 |
| members → comment_likes | 1:N | 회원이 여러 댓글에 좋아요 |

---

## 10. F7 회원 팔로우 테이블 (Phase 2)

### 10.1 member_follows (회원 팔로우)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| follower_id | BIGINT | FK, NOT NULL | 팔로우 하는 회원 ID |
| following_id | BIGINT | FK, NOT NULL | 팔로우 받는 회원 ID |
| created_at | DATETIME | NOT NULL | 팔로우 시각 |

**제약조건**:
- UNIQUE(follower_id, following_id) - 중복 팔로우 방지

**인덱스**:
- `idx_member_follows_follower`: follower_id
- `idx_member_follows_following`: following_id

**관계**:
- `follower_id` → `members.id` (N:1)
- `following_id` → `members.id` (N:1)

**비고**:
- follower: 팔로우를 하는 사용자 (A가 B를 팔로우하면 A가 follower)
- following: 팔로우를 받는 사용자 (A가 B를 팔로우하면 B가 following)
- 자기 자신을 팔로우할 수 없음 (애플리케이션 레벨 검증)

---

## 11. F7 파생 필드 (계산)

다음 필드들은 DB에 저장하지 않고 쿼리로 계산합니다:

| 필드명 | 계산 방법 |
|--------|-----------|
| followerCount | `SELECT COUNT(*) FROM member_follows WHERE following_id = ?` |
| followingCount | `SELECT COUNT(*) FROM member_follows WHERE follower_id = ?` |
| isFollowing | `SELECT EXISTS(SELECT 1 FROM member_follows WHERE follower_id = ? AND following_id = ?)` |
| postCount | `SELECT COUNT(*) FROM feed_posts WHERE member_id = ?` |

---

## 12. F7 관계 요약

| 관계 | 타입 | 설명 |
|------|------|------|
| members → member_follows (as follower) | 1:N | 회원이 팔로우하는 관계들 |
| members → member_follows (as following) | 1:N | 회원을 팔로우하는 관계들 |

---

## 13. F8 검색 기능 (Phase 2)

### 13.1 검색 전략

F8 Search는 **새로운 테이블을 생성하지 않습니다**. 기존 Entity들을 활용한 검색 쿼리로 구현합니다.

**검색 대상 Entity 및 필드**:

| Entity | 검색 필드 | Repository 메서드 |
|--------|-----------|-------------------|
| Song | titleKor, titleJp, artist.nameKor/Eng/Jp | `SongRepository.searchByKeyword()` |
| Artist | nameKor, nameEng, nameJp | `ArtistRepository.searchByKeyword()` |
| FeedPost | content | `FeedPostRepository.searchByKeyword()` |
| Member | nickname, email | `MemberRepository.searchByKeyword()` |

### 13.2 검색 쿼리 예시

**노래 검색** (JOIN FETCH로 N+1 방지):
```sql
SELECT s FROM Song s
JOIN FETCH s.artist a
LEFT JOIN FETCH s.album
WHERE LOWER(s.titleKor) LIKE LOWER(CONCAT('%', :keyword, '%'))
   OR LOWER(s.titleJp) LIKE LOWER(CONCAT('%', :keyword, '%'))
   OR LOWER(a.nameKor) LIKE LOWER(CONCAT('%', :keyword, '%'))
   OR LOWER(a.nameEng) LIKE LOWER(CONCAT('%', :keyword, '%'))
   OR LOWER(a.nameJp) LIKE LOWER(CONCAT('%', :keyword, '%'))
```

**아티스트 검색**:
```sql
SELECT a FROM Artist a
WHERE LOWER(a.nameKor) LIKE LOWER(CONCAT('%', :keyword, '%'))
   OR LOWER(a.nameEng) LIKE LOWER(CONCAT('%', :keyword, '%'))
   OR LOWER(a.nameJp) LIKE LOWER(CONCAT('%', :keyword, '%'))
```

**게시글 검색** (EntityGraph로 member 함께 조회):
```sql
SELECT fp FROM FeedPost fp
WHERE LOWER(fp.content) LIKE LOWER(CONCAT('%', :keyword, '%'))
ORDER BY fp.createdAt DESC
```

**사용자 검색** (탈퇴하지 않은 회원만):
```sql
SELECT m FROM Member m
WHERE m.deletedAt IS NULL
  AND (LOWER(m.nickname) LIKE LOWER(CONCAT('%', :keyword, '%'))
       OR LOWER(m.email) LIKE LOWER(CONCAT('%', :keyword, '%')))
```

### 13.3 최근 검색어

최근 검색어는 **클라이언트(Flutter)에서 로컬 저장소(SharedPreferences)에 관리**합니다.
서버에 저장하지 않아 개인정보 보호 및 불필요한 DB 부하를 방지합니다.

**클라이언트 저장 구조**:
```dart
// SharedPreferences에 JSON 문자열로 저장
// key: 'recent_searches'
// value: '[{"keyword":"아이묭","searchedAt":"2024-01-15T10:30:00"},...]'
```

### 13.4 검색 성능 최적화 (향후)

현재는 LIKE 쿼리로 구현하되, 데이터 증가 시 다음 최적화 고려:

1. **Full-Text Index**: MySQL FULLTEXT 인덱스 적용
2. **Elasticsearch**: 별도 검색 엔진 도입
3. **캐싱**: 인기 검색어 결과 캐싱

---

## 14. F9 FAQ 테이블 (Phase 3)

### 14.1 faqs (자주 묻는 질문)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| question | VARCHAR(500) | NOT NULL | 질문 |
| answer | TEXT | NOT NULL | 답변 |
| category | VARCHAR(20) | NOT NULL | 카테고리 (ACCOUNT, SERVICE, COMMUNITY, OTHER) |
| display_order | INT | NOT NULL, DEFAULT 0 | 표시 순서 |
| is_published | BOOLEAN | NOT NULL, DEFAULT true | 공개 여부 |
| created_at | DATETIME | NOT NULL | 생성일 |
| updated_at | DATETIME | | 수정일 |

**인덱스**:
- `idx_faqs_category`: category
- `idx_faqs_is_published`: is_published
- `idx_faqs_display_order`: display_order

**카테고리 ENUM 값**:
| 값 | 설명 |
|----|------|
| ACCOUNT | 계정 관련 (가입, 로그인, 탈퇴) |
| SERVICE | 서비스 이용 (기능 사용법) |
| COMMUNITY | 커뮤니티 (게시글, 댓글, 팔로우) |
| OTHER | 기타 |

**비고**:
- 관리자가 관리하는 정적 콘텐츠
- 사용자는 조회만 가능
- 검색은 question, answer 필드 대상 LIKE 쿼리

---

## 15. F10 문의 테이블 (Phase 3)

### 15.1 questions (문의)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| member_id | BIGINT | FK, NOT NULL | 작성자 ID |
| type | VARCHAR(20) | NOT NULL | 문의 유형 (ACCOUNT, SERVICE, BUG, FEATURE, OTHER) |
| title | VARCHAR(100) | NOT NULL | 제목 |
| content | TEXT | NOT NULL | 내용 |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'RECEIVED' | 상태 (RECEIVED, PROCESSING, ANSWERED) |
| answer | TEXT | | 답변 (nullable) |
| answered_at | DATETIME | | 답변 일시 |
| created_at | DATETIME | NOT NULL | 작성일 |
| updated_at | DATETIME | | 수정일 |

**인덱스**:
- `idx_questions_member_id`: member_id
- `idx_questions_type`: type
- `idx_questions_status`: status
- `idx_questions_created_at`: created_at

**관계**:
- `member_id` → `members.id` (N:1)

**문의 유형 ENUM 값**:
| 값 | 설명 |
|----|------|
| ACCOUNT | 계정 관련 |
| SERVICE | 서비스 이용 |
| BUG | 버그 신고 |
| FEATURE | 기능 제안 |
| OTHER | 기타 |

**문의 상태 ENUM 값**:
| 값 | 설명 |
|----|------|
| RECEIVED | 접수됨 |
| PROCESSING | 처리중 |
| ANSWERED | 답변완료 |

**비고**:
- 로그인한 사용자만 문의 작성 가능
- 본인 문의만 조회 가능
- 관리자만 답변 등록 및 상태 변경 가능
- 문의 번호는 `QT-YYYYMMDD-{id:04d}` 형식으로 생성

---

## 16. F10 관계 요약

| 관계 | 타입 | 설명 |
|------|------|------|
| members → questions | 1:N | 회원이 여러 문의 작성 |

---

## 17. F11 신고 테이블 (Phase 3)

### 17.1 reports (신고)

| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 고유 식별자 |
| reporter_id | BIGINT | FK, NOT NULL | 신고자 ID |
| target_type | VARCHAR(20) | NOT NULL | 대상 유형 (POST, COMMENT, MEMBER) |
| target_id | BIGINT | NOT NULL | 대상 ID |
| reason | VARCHAR(20) | NOT NULL | 신고 사유 (SPAM, ABUSE, INAPPROPRIATE, COPYRIGHT, OTHER) |
| description | VARCHAR(300) | | 상세 내용 (기타 선택 시) |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'PENDING' | 상태 (PENDING, REVIEWED, RESOLVED, DISMISSED) |
| admin_note | VARCHAR(500) | | 관리자 처리 메모 - F12 |
| resolved_at | DATETIME | | 처리 완료일 - F12 |
| resolved_by | BIGINT | FK | 처리한 관리자 ID - F12 |
| created_at | DATETIME | NOT NULL | 신고일 |
| updated_at | DATETIME | | 수정일 |

**제약조건**:
- UNIQUE(reporter_id, target_type, target_id) - 중복 신고 방지 (AC-F11-7)

**인덱스**:
- `idx_reports_reporter_id`: reporter_id
- `idx_reports_target`: (target_type, target_id)
- `idx_reports_status`: status
- `idx_reports_created_at`: created_at

**관계**:
- `reporter_id` → `members.id` (N:1)

**대상 유형 ENUM 값**:
| 값 | 설명 |
|----|------|
| POST | 게시글 (feed_posts.id) |
| COMMENT | 댓글 (comments.id) |
| MEMBER | 사용자 (members.id) |

**신고 사유 ENUM 값**:
| 값 | 설명 |
|----|------|
| SPAM | 스팸/광고 |
| ABUSE | 욕설/비방 |
| INAPPROPRIATE | 불쾌한 내용 |
| COPYRIGHT | 저작권 침해 |
| OTHER | 기타 |

**신고 상태 ENUM 값**:
| 값 | 설명 |
|----|------|
| PENDING | 대기중 |
| REVIEWED | 검토됨 |
| RESOLVED | 처리완료 |
| DISMISSED | 기각 |

**비고**:
- 로그인한 사용자만 신고 가능
- 본인 콘텐츠/프로필은 신고 불가 (AC-F11-8, 애플리케이션 레벨 검증)
- 동일 대상에 대해 동일 사용자는 1회만 신고 가능 (AC-F11-7)
- 신고 대상은 다형성(Polymorphic) 패턴으로 target_type + target_id 조합으로 참조

---

## 18. F11 관계 요약

| 관계 | 타입 | 설명 |
|------|------|------|
| members → reports | 1:N | 회원이 여러 콘텐츠 신고 |

---

## 19. F12 관리자 기능 (Phase 3)

F12 관리자 기능은 **새로운 테이블을 생성하지 않습니다**.
기존 Entity들을 활용하여 관리 기능을 구현합니다.

### 19.1 Entity 확장 사항

**members 테이블 확장**:
- `status` 컬럼 추가: 회원 상태 관리 (ACTIVE, SUSPENDED, BANNED)
- `suspended_until` 컬럼 추가: 정지 해제일
- `suspended_reason` 컬럼 추가: 정지 사유

**reports 테이블 확장**:
- `admin_note` 컬럼 추가: 관리자 처리 메모
- `resolved_at` 컬럼 추가: 처리 완료일
- `resolved_by` 컬럼 추가: 처리한 관리자 ID

### 19.2 관리 대상 Entity

| Entity | 관리 기능 |
|--------|----------|
| Member | 목록 조회, 상세 조회, 정지(SUSPEND), 강제 탈퇴(BAN) |
| Report | 목록 조회, 상세 조회, 처리(기각/경고/콘텐츠 삭제) |
| Question | 목록 조회, 상세 조회, 답변 등록 |
| FAQ | 목록 조회, 생성, 수정, 삭제, 공개/비공개 설정 |

### 19.3 대시보드 통계 쿼리

| 통계 항목 | 쿼리 |
|----------|------|
| 전체 회원 수 | `SELECT COUNT(*) FROM members WHERE deleted_at IS NULL` |
| 오늘 가입 회원 | `SELECT COUNT(*) FROM members WHERE DATE(created_at) = CURRENT_DATE` |
| 미처리 신고 수 | `SELECT COUNT(*) FROM reports WHERE status = 'PENDING'` |
| 오늘 접수 신고 | `SELECT COUNT(*) FROM reports WHERE DATE(created_at) = CURRENT_DATE` |
| 미답변 문의 수 | `SELECT COUNT(*) FROM questions WHERE status <> 'ANSWERED'` |
| 전체 FAQ 수 | `SELECT COUNT(*) FROM faqs` |

### 19.4 관리자 권한 검증

관리자 기능은 `UserRoleType.ADMIN` 권한을 가진 회원만 접근할 수 있습니다.
Spring Security의 `@PreAuthorize("hasRole('ADMIN')")` 어노테이션으로 보호합니다.

---

## 20. 추가 예정 테이블

Phase 4 이후 추가 예정:
- 알림 테이블 (notifications)
- 차단 테이블 (blocks)
- 북마크 테이블 (bookmarks)
