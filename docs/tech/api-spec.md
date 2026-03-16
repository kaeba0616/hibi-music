# hibi API 스펙

## 1. 개요

### Base URL
- Production: `https://api.hibi.app`
- Development: `http://localhost:8080`

### 공통 헤더
```
Content-Type: application/json
Authorization: Bearer {access_token}  // 인증 필요 API
```

### 응답 형식
```json
// 성공
{
  "success": true,
  "message": "조회 성공",
  "data": { ... }
}

// 에러
{
  "success": false,
  "message": "에러 메시지",
  "code": "ERROR_CODE"
}
```

---

## 2. 인증 API

### POST /api/v1/auth/signup
회원가입

**Request**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "nickname": "닉네임"
}
```

**Response**
```json
{
  "success": true,
  "message": "회원가입 성공",
  "data": {
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

---

### POST /api/v1/auth/login
로그인

**Request**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response**
```json
{
  "success": true,
  "message": "로그인 성공",
  "data": {
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

---

### POST /api/v1/auth/refresh
토큰 갱신

**Request**
```json
{
  "refreshToken": "..."
}
```

**Response**
```json
{
  "success": true,
  "message": "토큰 갱신 성공",
  "data": {
    "accessToken": "..."
  }
}
```

---

## 3. 회원 API

### GET /api/v1/members/me
내 정보 조회 (인증 필요)

**Response**
```json
{
  "success": true,
  "message": "조회 성공",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "닉네임",
    "profileImage": "https://...",
    "createdAt": "2026-02-03T10:00:00"
  }
}
```

---

### PUT /api/v1/members/me
내 정보 수정 (인증 필요)

**Request**
```json
{
  "nickname": "새 닉네임",
  "profileImage": "https://..."
}
```

---

## 4. Daily Song API (F2)

### GET /api/v1/daily-songs/today
오늘의 노래 조회 (인증 필요)

**Response**
```json
{
  "success": true,
  "message": "오늘의 노래 조회 성공",
  "data": {
    "id": 1,
    "titleKor": "밤을 달리다",
    "titleJp": "夜に駆ける",
    "artist": {
      "id": 1,
      "nameKor": "요아소비",
      "nameEng": "YOASOBI",
      "nameJp": "YOASOBI",
      "profileUrl": "https://..."
    },
    "album": {
      "id": 1,
      "name": "THE BOOK",
      "imageUrl": "https://...",
      "releaseDate": "2021-01-06"
    },
    "lyrics": {
      "japanese": "沈むように溶けてゆくように...",
      "korean": "가라앉듯이 녹아가듯이..."
    },
    "genre": "J-Pop",
    "recommendedDate": "2026-02-03",
    "externalLinks": {
      "spotify": "https://open.spotify.com/...",
      "appleMusic": "https://music.apple.com/...",
      "youtube": "https://www.youtube.com/..."
    },
    "isLiked": false,
    "likeCount": 1542
  }
}
```

**추천곡이 없는 경우**
```json
{
  "success": true,
  "message": "오늘의 추천곡이 없습니다",
  "data": null
}
```

---

### GET /api/v1/daily-songs/by-date
날짜별 노래 조회 (인증 필요)

**Query Parameters**
- `date`: 날짜 (required, 형식: yyyy-MM-dd)

**Response**: GET /api/v1/daily-songs/today와 동일

---

### GET /api/v1/daily-songs/{songId}
노래 상세 조회 (인증 필요)

**Response**: GET /api/v1/daily-songs/today와 동일

---

### GET /api/v1/daily-songs/by-month
월별 노래 목록 조회 (인증 필요)

**Query Parameters**
- `year`: 연도 (required)
- `month`: 월 (required)

**Response**
```json
{
  "success": true,
  "message": "월별 노래 조회 성공",
  "data": [
    {
      "id": 1,
      "titleKor": "밤을 달리다",
      "titleJp": "夜に駆ける",
      "artist": { ... },
      "album": { ... },
      "lyrics": { ... },
      "genre": "J-Pop",
      "recommendedDate": "2026-02-03",
      "externalLinks": { ... },
      "isLiked": false,
      "likeCount": 1542
    },
    ...
  ]
}
```

---

### POST /api/v1/daily-songs/{songId}/like
좋아요 토글 (인증 필요)

좋아요가 없으면 추가, 있으면 삭제합니다.

**Response**
```json
{
  "success": true,
  "message": "좋아요 추가",  // 또는 "좋아요 취소"
  "data": {
    "isLiked": true  // 또는 false
  }
}
```

---

## 4.1 Songs API (기존 관리용)

### GET /api/v1/songs
모든 노래 조회 (관리자용)

### POST /api/v1/songs
노래 생성 (관리자용)

### PUT /api/v1/songs/{id}
노래 수정 (관리자용)

### DELETE /api/v1/songs/{id}
노래 삭제 (관리자용)

---

## 5. 아티스트 API (F3)

### GET /api/v1/artists
아티스트 목록 조회 (AC-F3-1, AC-F3-4)

**Query Parameters**
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)
- `following`: 팔로우 필터 (true: 팔로우한 아티스트만, false/미지정: 전체)
- `search`: 검색어 (아티스트 이름 검색, 한글/영문/일본어 지원)

**Response**
```json
{
  "success": true,
  "message": "아티스트 목록 조회 성공",
  "data": {
    "content": [
      {
        "id": 1,
        "nameKor": "요아소비",
        "nameEng": "YOASOBI",
        "nameJp": "YOASOBI",
        "profileUrl": "https://...",
        "songCount": 15,
        "isFollowing": false
      }
    ],
    "totalPages": 5,
    "totalElements": 100,
    "page": 0,
    "size": 20
  }
}
```

---

### GET /api/v1/artists/{id}
아티스트 상세 조회 (AC-F3-2)

**Response**
```json
{
  "success": true,
  "message": "아티스트 조회 성공",
  "data": {
    "id": 1,
    "nameKor": "요아소비",
    "nameEng": "YOASOBI",
    "nameJp": "YOASOBI",
    "profileUrl": "https://...",
    "description": "2019년 결성된 일본 음악 유닛. Ayase(작곡)와 ikura(보컬)로 구성.",
    "followerCount": 12500,
    "songCount": 15,
    "isFollowing": false,
    "songs": [
      {
        "id": 1,
        "titleKor": "밤을 달리다",
        "titleJp": "夜に駆ける",
        "albumName": "THE BOOK",
        "albumImageUrl": "https://...",
        "releaseYear": 2021
      }
    ]
  }
}
```

---

### POST /api/v1/artists/{id}/follow
아티스트 팔로우 (AC-F3-3, 인증 필요)

이미 팔로우 중인 경우 DUPLICATE_ENTITY(409) 에러를 반환합니다.

**Response (성공)**
```json
{
  "success": true,
  "message": "팔로우 성공",
  "data": null
}
```

**Response (로그인 필요)**
```json
{
  "success": true,
  "message": "로그인이 필요합니다",
  "data": null
}
```

---

### DELETE /api/v1/artists/{id}/follow
아티스트 언팔로우 (AC-F3-3, 인증 필요)

**Response (성공)**
```json
{
  "success": true,
  "message": "언팔로우 성공",
  "data": null
}
```

---

## 5.1 아티스트 API (관리자용)

### POST /api/v1/artists
아티스트 생성 (ADMIN 권한 필요)

**Request**
```json
{
  "nameKor": "요아소비",
  "nameEng": "YOASOBI",
  "nameJp": "YOASOBI"
}
```

---

### PUT /api/v1/artists/{id}
아티스트 수정 (ADMIN 권한 필요)

**Request**
```json
{
  "nameKor": "요아소비",
  "nameEng": "YOASOBI",
  "nameJp": "YOASOBI",
  "profileUrl": "https://...",
  "description": "..."
}
```

---

### DELETE /api/v1/artists/{id}
아티스트 삭제 (ADMIN 권한 필요)

---

### GET /api/v1/artists/all
전체 아티스트 조회 (ADMIN 권한 필요, 페이지네이션 없음)

---

## 6. 피드 게시글 API (F5)

### GET /api/v1/posts
게시글 목록 조회 (인증 필요)

**Query Parameters**
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)

**Response**
```json
{
  "success": true,
  "message": "게시글 목록 조회 성공",
  "data": {
    "content": [
      {
        "id": 1,
        "author": {
          "id": 5,
          "nickname": "JPOP러버",
          "username": "jpop_lover",
          "profileImage": "https://..."
        },
        "content": "오늘 들은 곡 너무 좋아요! YOASOBI 신곡 최고 ❤️",
        "images": ["https://..."],
        "taggedSong": {
          "id": 1,
          "titleKor": "밤을 달리다",
          "titleJp": "夜に駆ける",
          "artistName": "요아소비",
          "albumImageUrl": "https://...",
          "albumName": "THE BOOK",
          "releaseYear": 2021
        },
        "likeCount": 24,
        "commentCount": 5,
        "isLiked": false,
        "createdAt": "2026-02-03T10:00:00",
        "updatedAt": null
      }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 100,
    "totalPages": 5,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

---

### GET /api/v1/posts/{postId}
게시글 상세 조회 (인증 필요)

**Response**
```json
{
  "success": true,
  "message": "게시글 조회 성공",
  "data": {
    "id": 1,
    "author": { ... },
    "content": "...",
    "images": ["https://..."],
    "taggedSong": { ... },
    "likeCount": 24,
    "commentCount": 5,
    "isLiked": false,
    "createdAt": "2026-02-03T10:00:00",
    "updatedAt": null
  }
}
```

---

### POST /api/v1/posts
게시글 작성 (인증 필요)

**Request**
```json
{
  "content": "오늘 들은 곡 너무 좋아요!",
  "images": ["https://..."],
  "taggedSongId": 1
}
```

**Validation**
- `content`: 필수, 최대 500자
- `images`: 최대 4개
- `taggedSongId`: 선택

**Response**
```json
{
  "success": true,
  "message": "게시글 작성 성공",
  "data": {
    "id": 8,
    "author": { ... },
    "content": "오늘 들은 곡 너무 좋아요!",
    "images": ["https://..."],
    "taggedSong": { ... },
    "likeCount": 0,
    "commentCount": 0,
    "isLiked": false,
    "createdAt": "2026-02-03T15:30:00",
    "updatedAt": null
  }
}
```

---

### PUT /api/v1/posts/{postId}
게시글 수정 (인증 필요, 본인만)

**Request**
```json
{
  "content": "수정된 내용",
  "images": ["https://..."],
  "taggedSongId": 2
}
```

**Response**: POST /api/v1/posts 응답과 동일

**Error Cases**
- `403 FORBIDDEN`: 본인 게시글이 아닌 경우

---

### DELETE /api/v1/posts/{postId}
게시글 삭제 (인증 필요, 본인만)

**Response**
```json
{
  "success": true,
  "message": "게시글 삭제 성공"
}
```

**Error Cases**
- `403 FORBIDDEN`: 본인 게시글이 아닌 경우
- `404 NOT_FOUND`: 게시글이 존재하지 않는 경우

---

### POST /api/v1/posts/{postId}/like
좋아요 토글 (인증 필요)

좋아요가 없으면 추가, 있으면 삭제합니다.

**Response**
```json
{
  "success": true,
  "message": "좋아요 추가 성공",  // 또는 "좋아요 취소 성공"
  "data": true  // 현재 좋아요 상태 (true: 좋아요됨, false: 좋아요 취소됨)
}
```

---

## 7. 댓글 API (F6)

### GET /api/v1/posts/{postId}/comments
댓글 목록 조회 (인증 필요)

게시글의 댓글 목록을 조회합니다. 대댓글 포함.

**Response**
```json
{
  "success": true,
  "message": "댓글 목록 조회 성공",
  "data": {
    "comments": [
      {
        "id": 1,
        "postId": 1,
        "author": {
          "id": 1,
          "nickname": "음악러버",
          "username": "music_lover",
          "profileImage": "https://..."
        },
        "content": "정말 좋은 곡이죠!",
        "parentId": null,
        "parentAuthorNickname": null,
        "likeCount": 12,
        "isLiked": true,
        "isDeleted": false,
        "createdAt": "2026-02-03T10:00:00",
        "updatedAt": null,
        "replies": [
          {
            "id": 2,
            "postId": 1,
            "author": {
              "id": 2,
              "nickname": "JPOP팬",
              "username": "jpop_fan",
              "profileImage": "https://..."
            },
            "content": "@음악러버 저도 동감이에요!",
            "parentId": 1,
            "parentAuthorNickname": "음악러버",
            "likeCount": 5,
            "isLiked": false,
            "isDeleted": false,
            "createdAt": "2026-02-03T10:30:00",
            "updatedAt": null,
            "replies": []
          }
        ]
      }
    ],
    "totalCount": 7,
    "hasMore": false
  }
}
```

**삭제된 댓글 (대댓글이 있는 경우)**
```json
{
  "id": 3,
  "postId": 1,
  "author": {
    "id": 0,
    "nickname": "",
    "username": "",
    "profileImage": null
  },
  "content": "",
  "parentId": null,
  "parentAuthorNickname": null,
  "likeCount": 0,
  "isLiked": false,
  "isDeleted": true,
  "createdAt": "2026-02-02T10:00:00",
  "updatedAt": null,
  "replies": [...]
}
```

---

### POST /api/v1/posts/{postId}/comments
댓글 작성 (인증 필요)

게시글에 댓글을 작성합니다. `parentId`를 지정하면 대댓글이 됩니다.

**Request**
```json
{
  "content": "정말 좋은 곡이에요!",
  "parentId": null
}
```

**대댓글 Request**
```json
{
  "content": "@음악러버 저도 동감이에요!",
  "parentId": 1
}
```

**Validation**
- `content`: 필수, 최대 500자
- `parentId`: 선택, 대댓글인 경우 부모 댓글 ID

**Response**
```json
{
  "success": true,
  "message": "댓글 작성 성공",
  "data": {
    "id": 8,
    "postId": 1,
    "author": { ... },
    "content": "정말 좋은 곡이에요!",
    "parentId": null,
    "parentAuthorNickname": null,
    "likeCount": 0,
    "isLiked": false,
    "isDeleted": false,
    "createdAt": "2026-02-03T15:30:00",
    "updatedAt": null,
    "replies": []
  }
}
```

**Error Cases**
- `400 INVALID_INPUT`: 대대댓글 시도 (parentId의 댓글이 이미 대댓글인 경우)
- `404 NOT_FOUND`: 게시글 또는 부모 댓글이 존재하지 않는 경우

---

### DELETE /api/v1/posts/{postId}/comments/{commentId}
댓글 삭제 (인증 필요, 본인만)

댓글을 삭제합니다. 대댓글이 있으면 soft delete (isDeleted=true).

**Response**
```json
{
  "success": true,
  "message": "댓글 삭제 성공"
}
```

**삭제 정책**
- 대댓글이 없으면: 완전 삭제 (hard delete)
- 대댓글이 있으면: soft delete (isDeleted=true, content="")

**Error Cases**
- `403 FORBIDDEN`: 본인 댓글이 아닌 경우
- `404 NOT_FOUND`: 댓글이 존재하지 않는 경우

---

### POST /api/v1/posts/{postId}/comments/{commentId}/like
댓글 좋아요 토글 (인증 필요)

댓글 좋아요를 토글합니다. 이미 좋아요했으면 취소, 아니면 좋아요 추가.

**Response**
```json
{
  "success": true,
  "message": "좋아요 추가 성공",  // 또는 "좋아요 취소 성공"
  "data": true  // 현재 좋아요 상태 (true: 좋아요됨, false: 좋아요 취소됨)
}
```

**Error Cases**
- `400 INVALID_INPUT`: 삭제된 댓글에 좋아요 시도
- `404 NOT_FOUND`: 댓글이 존재하지 않는 경우

---

## 8. 팔로우 API (F7)

### GET /api/v1/users/{userId}
사용자 프로필 조회 (인증 선택)

**Response**
```json
{
  "success": true,
  "message": "프로필 조회 성공",
  "data": {
    "id": 1,
    "nickname": "음악러버",
    "username": "music_lover",
    "profileImage": "https://...",
    "postCount": 25,
    "followerCount": 150,
    "followingCount": 80,
    "isFollowing": false
  }
}
```

---

### GET /api/v1/users/{userId}/followers
팔로워 목록 조회 (인증 선택)

**Query Parameters**
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)

**Response**
```json
{
  "success": true,
  "message": "팔로워 목록 조회 성공",
  "data": {
    "content": [
      {
        "id": 2,
        "nickname": "JPOP팬",
        "username": "jpop_fan",
        "profileImage": "https://...",
        "isFollowing": true
      }
    ],
    "totalCount": 150,
    "hasMore": true
  }
}
```

---

### GET /api/v1/users/{userId}/followings
팔로잉 목록 조회 (인증 선택)

**Query Parameters**
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)

**Response**
```json
{
  "success": true,
  "message": "팔로잉 목록 조회 성공",
  "data": {
    "content": [
      {
        "id": 3,
        "nickname": "음악덕후",
        "username": "music_mania",
        "profileImage": "https://...",
        "isFollowing": true
      }
    ],
    "totalCount": 80,
    "hasMore": false
  }
}
```

---

### POST /api/v1/users/{userId}/follow
사용자 팔로우 (인증 필요)

**Response**
```json
{
  "success": true,
  "message": "팔로우 성공"
}
```

**Error Cases**
- `400 INVALID_INPUT`: 자기 자신 팔로우 시도
- `409 CONFLICT`: 이미 팔로우 중인 경우

---

### DELETE /api/v1/users/{userId}/follow
사용자 언팔로우 (인증 필요)

**Response**
```json
{
  "success": true,
  "message": "언팔로우 성공"
}
```

**Error Cases**
- `404 NOT_FOUND`: 팔로우 관계가 없는 경우

---

### GET /api/v1/users/{userId}/posts
사용자 게시글 목록 조회 (인증 선택)

**Query Parameters**
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)

**Response**: GET /api/v1/posts 응답과 동일

---

### GET /api/v1/posts/following
팔로잉 피드 조회 (인증 필요)

팔로우하는 사용자들의 게시글 목록을 조회합니다.

**Query Parameters**
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)

**Response**: GET /api/v1/posts 응답과 동일

팔로우하는 사용자가 없는 경우 빈 목록을 반환합니다.

---

## 9. 검색 API (F8)

### GET /api/v1/search
통합 검색 (인증 선택)

노래, 아티스트, 게시글, 사용자를 한 번에 검색합니다.

**Query Parameters**
- `q`: 검색어 (required, 최소 1자)
- `category`: 검색 카테고리 (optional)
  - `all`: 전체 검색 (default)
  - `songs`: 노래만
  - `artists`: 아티스트만
  - `posts`: 게시글만
  - `users`: 사용자만
- `limit`: 각 카테고리별 최대 결과 수 (default: 10, max: 50)

**Response (category=all)**
```json
{
  "success": true,
  "message": "검색 성공",
  "data": {
    "keyword": "요아소비",
    "songs": [
      {
        "id": 1,
        "titleKor": "밤을 달리다",
        "titleJp": "夜に駆ける",
        "artistName": "요아소비",
        "albumName": "THE BOOK",
        "albumImageUrl": "https://..."
      }
    ],
    "artists": [
      {
        "id": 1,
        "nameKor": "요아소비",
        "nameEng": "YOASOBI",
        "nameJp": "YOASOBI",
        "profileUrl": "https://...",
        "followerCount": 12500
      }
    ],
    "posts": [
      {
        "id": 5,
        "content": "요아소비 신곡 너무 좋아요!",
        "author": {
          "id": 2,
          "nickname": "JPOP팬",
          "profileImage": "https://..."
        },
        "likeCount": 24,
        "commentCount": 5,
        "createdAt": "2026-02-03T10:00:00"
      }
    ],
    "users": [
      {
        "id": 10,
        "nickname": "요아소비덕후",
        "username": "yoasobi_fan",
        "profileImage": "https://...",
        "followerCount": 50
      }
    ],
    "totalCount": {
      "songs": 15,
      "artists": 1,
      "posts": 23,
      "users": 3
    }
  }
}
```

**Response (category=songs)**
```json
{
  "success": true,
  "message": "검색 성공",
  "data": {
    "keyword": "요아소비",
    "songs": [...],
    "artists": [],
    "posts": [],
    "users": [],
    "totalCount": {
      "songs": 15,
      "artists": 0,
      "posts": 0,
      "users": 0
    }
  }
}
```

**검색 결과 없음**
```json
{
  "success": true,
  "message": "검색 결과가 없습니다",
  "data": {
    "keyword": "없는검색어",
    "songs": [],
    "artists": [],
    "posts": [],
    "users": [],
    "totalCount": {
      "songs": 0,
      "artists": 0,
      "posts": 0,
      "users": 0
    }
  }
}
```

**Error Cases**
- `400 INVALID_INPUT`: 검색어가 없거나 빈 문자열인 경우

---

### 검색 로직 설명

**노래 검색 (songs)**
- 검색 대상: titleKor, titleJp, artist.nameKor, artist.nameEng, artist.nameJp
- 대소문자 무시 (case-insensitive)
- LIKE 패턴 매칭

**아티스트 검색 (artists)**
- 검색 대상: nameKor, nameEng, nameJp
- 대소문자 무시

**게시글 검색 (posts)**
- 검색 대상: content
- 대소문자 무시
- 최신순 정렬

**사용자 검색 (users)**
- 검색 대상: nickname, email (username 부분)
- 탈퇴하지 않은 회원만
- 대소문자 무시

---

### 최근 검색어

최근 검색어는 **클라이언트 로컬 저장소**에서 관리합니다.
서버 API를 제공하지 않습니다.

**클라이언트 구현 가이드**
- 저장소: SharedPreferences (Flutter)
- 최대 10개 저장
- 중복 검색어는 최신으로 이동
- 사용자별 로컬 관리

---

## 10. FAQ API (F9)

### GET /api/v1/faqs
FAQ 목록 조회 (인증 불필요)

카테고리 필터 및 키워드 검색을 지원합니다.

**Query Parameters**
- `category`: 카테고리 필터 (optional)
  - `all`: 전체 (default)
  - `account`: 계정
  - `service`: 서비스 이용
  - `community`: 커뮤니티
  - `other`: 기타
- `keyword`: 검색 키워드 (optional, 질문/답변에서 검색)

**Response**
```json
{
  "success": true,
  "message": "FAQ 조회 성공",
  "data": {
    "faqs": [
      {
        "id": 1,
        "question": "계정은 어떻게 생성하나요?",
        "answer": "앱 설치 후 '회원가입' 버튼을 눌러 이메일과 비밀번호를 입력하세요.",
        "category": "account",
        "categoryLabel": "계정",
        "order": 1,
        "createdAt": "2026-02-01T10:00:00",
        "updatedAt": null
      }
    ],
    "totalCount": 14
  }
}
```

**FAQ가 없는 경우**
```json
{
  "success": true,
  "message": "등록된 FAQ가 없습니다",
  "data": {
    "faqs": [],
    "totalCount": 0
  }
}
```

---

### GET /api/v1/faqs/{id}
FAQ 상세 조회 (인증 불필요)

**Response**
```json
{
  "success": true,
  "message": "FAQ 조회 성공",
  "data": {
    "id": 1,
    "question": "계정은 어떻게 생성하나요?",
    "answer": "앱 설치 후 '회원가입' 버튼을 눌러 이메일과 비밀번호를 입력하세요.",
    "category": "account",
    "categoryLabel": "계정",
    "order": 1,
    "createdAt": "2026-02-01T10:00:00",
    "updatedAt": null
  }
}
```

**Error Cases**
- `404 NOT_FOUND`: FAQ가 존재하지 않거나 비공개 상태인 경우

---

## 11. Question API (F10)

### GET /api/v1/questions
문의 목록 조회 (인증 필요)

로그인한 사용자의 문의 목록을 조회합니다.

**Response**
```json
{
  "success": true,
  "message": "문의 목록 조회 성공",
  "data": {
    "questions": [
      {
        "id": 1,
        "memberId": 1,
        "type": "account",
        "typeLabel": "계정",
        "title": "로그인이 계속 안 돼요",
        "content": "앱을 다시 설치해도 로그인이 안 됩니다...",
        "status": "answered",
        "statusLabel": "답변완료",
        "answer": "안녕하세요, hibi 운영팀입니다...",
        "answeredAt": "2026-02-02T10:00:00",
        "questionNumber": "QT-20260201-0001",
        "createdAt": "2026-02-01T15:30:00",
        "updatedAt": "2026-02-02T10:00:00"
      }
    ],
    "totalCount": 5
  }
}
```

**문의 내역이 없는 경우**
```json
{
  "success": true,
  "message": "문의 내역이 없습니다",
  "data": {
    "questions": [],
    "totalCount": 0
  }
}
```

**Error Cases**
- `401 UNAUTHORIZED`: 로그인하지 않은 경우

---

### GET /api/v1/questions/{id}
문의 상세 조회 (인증 필요)

특정 문의의 상세 정보를 조회합니다. 본인 문의만 조회 가능합니다.

**Response**
```json
{
  "success": true,
  "message": "문의 조회 성공",
  "data": {
    "id": 1,
    "memberId": 1,
    "type": "account",
    "typeLabel": "계정",
    "title": "로그인이 계속 안 돼요",
    "content": "앱을 다시 설치해도 로그인이 안 됩니다. 이메일은 user@example.com이고 비밀번호도 맞게 입력하고 있습니다. 확인 부탁드립니다.",
    "status": "answered",
    "statusLabel": "답변완료",
    "answer": "안녕하세요, hibi 운영팀입니다.\n\n확인 결과, 해당 이메일로 가입된 계정이 없습니다. 다른 이메일로 가입하셨는지 확인 부탁드립니다.\n\n감사합니다.",
    "answeredAt": "2026-02-02T10:00:00",
    "questionNumber": "QT-20260201-0001",
    "createdAt": "2026-02-01T15:30:00",
    "updatedAt": "2026-02-02T10:00:00"
  }
}
```

**Error Cases**
- `401 UNAUTHORIZED`: 로그인하지 않은 경우
- `404 NOT_FOUND`: 문의가 존재하지 않거나 본인 문의가 아닌 경우

---

### POST /api/v1/questions
문의 작성 (인증 필요)

새로운 문의를 작성합니다.

**Request**
```json
{
  "type": "account",
  "title": "로그인이 계속 안 돼요",
  "content": "앱을 다시 설치해도 로그인이 안 됩니다. 이메일은 user@example.com이고 비밀번호도 맞게 입력하고 있습니다. 확인 부탁드립니다."
}
```

**Validation**
- `type`: 필수 (account, service, bug, feature, other)
- `title`: 필수, 최대 100자
- `content`: 필수, 최소 10자, 최대 1000자

**Response**
```json
{
  "success": true,
  "message": "문의가 접수되었습니다",
  "data": {
    "id": 6,
    "memberId": 1,
    "type": "account",
    "typeLabel": "계정",
    "title": "로그인이 계속 안 돼요",
    "content": "앱을 다시 설치해도 로그인이 안 됩니다...",
    "status": "received",
    "statusLabel": "접수됨",
    "answer": null,
    "answeredAt": null,
    "questionNumber": "QT-20260203-0006",
    "createdAt": "2026-02-03T15:30:00",
    "updatedAt": "2026-02-03T15:30:00"
  }
}
```

**문의 유형**
| 값 | 설명 |
|----|------|
| account | 계정 |
| service | 서비스 이용 |
| bug | 버그 신고 |
| feature | 기능 제안 |
| other | 기타 |

**문의 상태**
| 값 | 설명 |
|----|------|
| received | 접수됨 |
| processing | 처리중 |
| answered | 답변완료 |

**Error Cases**
- `400 INVALID_INPUT`: 유효성 검사 실패
- `401 UNAUTHORIZED`: 로그인하지 않은 경우

---

## 12. 신고 API (F11)

### POST /api/v1/reports
신고 생성

**Headers**
```
Authorization: Bearer {access_token}
```

**Request**
```json
{
  "targetType": "POST",
  "targetId": 42,
  "reason": "SPAM",
  "description": null
}
```

**신고 대상 유형 (targetType)**
| 값 | 설명 |
|----|------|
| POST | 게시글 |
| COMMENT | 댓글 |
| MEMBER | 사용자 |

**신고 사유 (reason)**
| 값 | 설명 |
|----|------|
| SPAM | 스팸/광고 |
| ABUSE | 욕설/비방 |
| INAPPROPRIATE | 불쾌한 내용 |
| COPYRIGHT | 저작권 침해 |
| OTHER | 기타 |

**Response (성공)**
```json
{
  "success": true,
  "message": "신고가 접수되었습니다",
  "data": {
    "id": 1,
    "reporterId": 10,
    "targetType": "POST",
    "targetId": 42,
    "reason": "SPAM",
    "description": null,
    "status": "PENDING",
    "createdAt": "2026-02-03T15:30:00"
  }
}
```

**Response (중복 신고 - AC-F11-7)**
```json
{
  "success": false,
  "message": "이미 신고한 항목입니다.",
  "code": "CONFLICT"
}
```

**Response (본인 콘텐츠 신고 - AC-F11-8)**
```json
{
  "success": false,
  "message": "본인의 게시글은 신고할 수 없습니다.",
  "code": "INVALID_INPUT"
}
```

**신고 상태 (status)**
| 값 | 설명 |
|----|------|
| PENDING | 대기중 |
| REVIEWED | 검토됨 |
| RESOLVED | 처리완료 |
| DISMISSED | 기각 |

---

### GET /api/v1/reports/check
중복 신고 여부 확인

**Headers**
```
Authorization: Bearer {access_token}
```

**Query Parameters**
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| targetType | string | Y | 신고 대상 유형 (POST, COMMENT, MEMBER) |
| targetId | number | Y | 신고 대상 ID |

**Request**
```
GET /api/v1/reports/check?targetType=POST&targetId=42
```

**Response**
```json
{
  "success": true,
  "message": "조회 성공",
  "data": {
    "alreadyReported": true
  }
}
```

**Error Cases**
- `400 INVALID_INPUT`: 유효하지 않은 대상 유형/사유
- `401 UNAUTHORIZED`: 로그인하지 않은 경우
- `404 NOT_FOUND`: 신고 대상이 존재하지 않음

---

## 13. 관리자 API (F12)

> 모든 관리자 API는 `ADMIN` 권한이 필요합니다.

### GET /api/v1/admin/stats
대시보드 통계 조회

**Response**
```json
{
  "success": true,
  "message": "통계 조회 성공",
  "data": {
    "totalMembers": 1234,
    "todayNewMembers": 15,
    "pendingReports": 7,
    "todayReports": 3,
    "unansweredQuestions": 5
  }
}
```

---

### GET /api/v1/admin/members
회원 목록 조회

**Query Parameters**
- `status`: 회원 상태 필터 (ACTIVE, SUSPENDED, BANNED)
- `search`: 닉네임/이메일 검색
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)

**Response**
```json
{
  "success": true,
  "message": "회원 목록 조회 성공",
  "data": {
    "members": [
      {
        "id": 1,
        "email": "user@example.com",
        "nickname": "음악러버",
        "profileImage": "https://...",
        "status": "ACTIVE",
        "postCount": 25,
        "receivedReportCount": 0,
        "createdAt": "2026-01-15T10:00:00"
      }
    ],
    "totalCount": 1234,
    "page": 0,
    "pageSize": 20
  }
}
```

---

### GET /api/v1/admin/members/{memberId}
회원 상세 조회

**Response**
```json
{
  "success": true,
  "message": "회원 상세 조회 성공",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "음악러버",
    "profileImage": "https://...",
    "status": "ACTIVE",
    "postCount": 25,
    "commentCount": 48,
    "followerCount": 150,
    "followingCount": 80,
    "receivedReportCount": 0,
    "sentReportCount": 2,
    "suspendedUntil": null,
    "suspendedReason": null,
    "createdAt": "2026-01-15T10:00:00"
  }
}
```

---

### POST /api/v1/admin/members/sanction
회원 제재 (정지/강제탈퇴)

**Request**
```json
{
  "memberId": 5,
  "actionType": "SUSPEND",
  "reason": "커뮤니티 가이드라인 위반",
  "suspendDays": 7
}
```

**actionType**
| 값 | 설명 |
|----|------|
| SUSPEND | 일시 정지 |
| BAN | 영구 정지 (강제탈퇴) |

**Response**
```json
{
  "success": true,
  "message": "회원 제재 완료"
}
```

---

### POST /api/v1/admin/members/{memberId}/unban
회원 정지 해제

**Response**
```json
{
  "success": true,
  "message": "정지 해제 완료"
}
```

---

### GET /api/v1/admin/reports
신고 목록 조회

**Query Parameters**
- `status`: 신고 상태 필터 (PENDING, REVIEWED, RESOLVED, DISMISSED)
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)

**Response**
```json
{
  "success": true,
  "message": "신고 목록 조회 성공",
  "data": {
    "reports": [
      {
        "id": 1,
        "reporter": {
          "id": 10,
          "nickname": "신고자닉네임"
        },
        "targetType": "POST",
        "targetId": 42,
        "reason": "SPAM",
        "description": null,
        "status": "PENDING",
        "createdAt": "2026-02-03T15:30:00"
      }
    ],
    "totalCount": 7,
    "page": 0,
    "pageSize": 20
  }
}
```

---

### GET /api/v1/admin/reports/{reportId}
신고 상세 조회

**Response**
```json
{
  "success": true,
  "message": "신고 상세 조회 성공",
  "data": {
    "id": 1,
    "reporter": {
      "id": 10,
      "nickname": "신고자닉네임"
    },
    "reportedUser": {
      "id": 5,
      "nickname": "피신고자닉네임"
    },
    "targetType": "POST",
    "targetId": 42,
    "targetContent": {
      "type": "POST",
      "content": "신고된 게시글 내용...",
      "imageUrl": "https://...",
      "createdAt": "2026-02-01T10:00:00"
    },
    "reason": "SPAM",
    "reasonLabel": "스팸/광고",
    "description": null,
    "status": "PENDING",
    "statusLabel": "대기중",
    "adminNote": null,
    "resolvedAt": null,
    "resolvedBy": null,
    "createdAt": "2026-02-03T15:30:00"
  }
}
```

---

### POST /api/v1/admin/reports/process
신고 처리

**Request**
```json
{
  "reportId": 1,
  "action": "RESOLVE",
  "adminNote": "확인 결과 스팸 게시글로 판단되어 삭제 조치함",
  "sanctionMember": true,
  "sanctionType": "SUSPEND",
  "suspendDays": 3
}
```

**action**
| 값 | 설명 |
|----|------|
| RESOLVE | 처리 완료 |
| DISMISS | 기각 |

**Response**
```json
{
  "success": true,
  "message": "신고 처리 완료"
}
```

---

### GET /api/v1/admin/questions
문의 목록 조회

**Query Parameters**
- `status`: 문의 상태 필터 (RECEIVED, PROCESSING, ANSWERED)
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)

**Response**
```json
{
  "success": true,
  "message": "문의 목록 조회 성공",
  "data": {
    "questions": [
      {
        "id": 1,
        "member": {
          "id": 5,
          "nickname": "문의자닉네임"
        },
        "type": "account",
        "typeLabel": "계정",
        "title": "로그인이 안 돼요",
        "status": "RECEIVED",
        "statusLabel": "접수됨",
        "createdAt": "2026-02-03T10:00:00"
      }
    ],
    "totalCount": 5,
    "page": 0,
    "pageSize": 20
  }
}
```

---

### GET /api/v1/admin/questions/{questionId}
문의 상세 조회

**Response**
```json
{
  "success": true,
  "message": "문의 상세 조회 성공",
  "data": {
    "id": 1,
    "member": {
      "id": 5,
      "nickname": "문의자닉네임",
      "email": "user@example.com"
    },
    "type": "account",
    "typeLabel": "계정",
    "title": "로그인이 안 돼요",
    "content": "앱을 다시 설치해도 로그인이 안 됩니다...",
    "status": "RECEIVED",
    "statusLabel": "접수됨",
    "answer": null,
    "answeredAt": null,
    "questionNumber": "QT-20260203-0001",
    "createdAt": "2026-02-03T10:00:00"
  }
}
```

---

### POST /api/v1/admin/questions/answer
문의 답변

**Request**
```json
{
  "questionId": 1,
  "answer": "안녕하세요, hibi 운영팀입니다.\n\n확인 결과..."
}
```

**Response**
```json
{
  "success": true,
  "message": "답변 등록 완료"
}
```

---

### GET /api/v1/admin/faqs
FAQ 목록 조회 (관리자용 - 비공개 포함)

**Query Parameters**
- `category`: 카테고리 필터 (ACCOUNT, SERVICE, COMMUNITY, OTHER)

**Response**
```json
{
  "success": true,
  "message": "FAQ 목록 조회 성공",
  "data": {
    "faqs": [
      {
        "id": 1,
        "category": "ACCOUNT",
        "categoryLabel": "계정",
        "question": "계정은 어떻게 생성하나요?",
        "answer": "앱 설치 후 '회원가입' 버튼을 눌러...",
        "displayOrder": 1,
        "isPublished": true,
        "createdAt": "2026-02-01T10:00:00",
        "updatedAt": null
      }
    ],
    "totalCount": 14
  }
}
```

---

### POST /api/v1/admin/faqs
FAQ 생성/수정

**Request (생성)**
```json
{
  "id": null,
  "category": "ACCOUNT",
  "question": "비밀번호를 잊어버렸어요",
  "answer": "로그인 화면에서 '비밀번호 찾기'를 눌러주세요.",
  "displayOrder": 2,
  "isPublished": true
}
```

**Request (수정)**
```json
{
  "id": 1,
  "category": "ACCOUNT",
  "question": "비밀번호를 잊어버렸어요 (수정됨)",
  "answer": "수정된 답변...",
  "displayOrder": 2,
  "isPublished": true
}
```

**Response**
```json
{
  "success": true,
  "message": "FAQ 생성 완료",
  "data": {
    "id": 15,
    "category": "ACCOUNT",
    "categoryLabel": "계정",
    "question": "비밀번호를 잊어버렸어요",
    "answer": "로그인 화면에서 '비밀번호 찾기'를 눌러주세요.",
    "displayOrder": 2,
    "isPublished": true,
    "createdAt": "2026-02-03T15:30:00",
    "updatedAt": null
  }
}
```

---

### DELETE /api/v1/admin/faqs/{faqId}
FAQ 삭제

**Response**
```json
{
  "success": true,
  "message": "FAQ 삭제 완료"
}
```

---

## 14. 에러 코드

| Code | HTTP Status | 설명 |
|------|-------------|------|
| INVALID_INPUT | 400 | 잘못된 입력 |
| UNAUTHORIZED | 401 | 인증 필요 |
| FORBIDDEN | 403 | 권한 없음 |
| NOT_FOUND | 404 | 리소스 없음 |
| CONFLICT | 409 | 중복 데이터 |
| INTERNAL_ERROR | 500 | 서버 오류 |
