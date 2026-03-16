# Phase 2: Social Features 계획

## 개요
- Phase ID: 2
- Phase 이름: Social Features
- Status: [status: completed]
- 목표: 커뮤니티 및 소셜 기능 추가

---

## Features 상세

### F5: Post (게시글) [status: completed]

#### 설명
JPOP 관련 게시글을 작성하고 노래를 태그하여 팬들과 소통하는 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 관련 파일
- Frontend: `hibi_front/lib/features/posts/`
  - models/post_models.dart - Post, PostAuthor, TaggedSong 모델
  - mocks/post_mock.dart - Mock 데이터
  - repos/post_repo.dart - Repository (Mock Provider 패턴 + Real API)
  - viewmodels/post_list_viewmodel.dart - 피드 목록 ViewModel
  - viewmodels/post_viewmodel.dart - 상세/작성/수정/검색 ViewModel
  - widgets/ - PostCard, SongTagCard, PostEmptyView 등
  - views/ - FeedView, PostCreateView, PostDetailView, PostEditView
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/feedpost/`
  - entity/FeedPost.java - 피드 게시글 Entity
  - entity/FeedPostImage.java - 게시글 이미지 Entity
  - entity/FeedPostLike.java - 게시글 좋아요 Entity
  - repository/FeedPostRepository.java
  - repository/FeedPostImageRepository.java
  - repository/FeedPostLikeRepository.java
  - dto/request/FeedPostCreateRequest.java
  - dto/request/FeedPostUpdateRequest.java
  - dto/response/FeedPostResponse.java
  - dto/response/FeedPostListResponse.java
  - dto/response/FeedPostAuthorResponse.java
  - dto/response/TaggedSongResponse.java
  - service/FeedPostService.java
  - controller/FeedPostController.java

---

### F6: Comment & Reaction (댓글/리액션) [status: completed]

#### 설명
게시글에 댓글을 작성하고 리액션을 남기는 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 관련 파일
- UX 문서: `docs/ux/features/comment-flow.md`, `comment-screens.md`
- Frontend: `hibi_front/lib/features/comments/`
  - models/comment_models.dart - Comment, CommentAuthor 모델
  - mocks/comment_mock.dart - Mock 데이터 (댓글, 대댓글, 삭제된 댓글)
  - repos/comment_repo.dart - Repository (Mock Provider 패턴 + Real API)
  - viewmodels/comment_viewmodel.dart - CommentSectionViewModel
  - widgets/comment_card.dart - 댓글/대댓글 카드 위젯
  - widgets/comment_input.dart - 댓글 입력창 위젯
  - widgets/comment_section.dart - 댓글 섹션 위젯
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/comment/`
  - entity/Comment.java - 댓글 Entity (대댓글 self-reference)
  - entity/CommentLike.java - 댓글 좋아요 Entity
  - repository/CommentRepository.java
  - repository/CommentLikeRepository.java
  - dto/request/CommentCreateRequest.java
  - dto/response/CommentResponse.java
  - dto/response/CommentAuthorResponse.java
  - dto/response/CommentListResponse.java
  - service/CommentService.java
  - controller/CommentController.java

---

### F7: Follow (팔로우) [status: completed]

#### 설명
사용자 간 팔로우 기능 및 팔로우 피드

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 관련 파일
- UX 문서: `docs/ux/features/follow-flow.md`, `follow-screens.md`
- Frontend: `hibi_front/lib/features/follow/`
  - models/follow_models.dart - UserProfile, FollowUser, FollowListResponse, FeedFilterType 모델
  - mocks/follow_mock.dart - Mock 데이터 (사용자 프로필, 팔로워/팔로잉 목록, 사용자 게시글)
  - repos/follow_repo.dart - Repository (Mock Provider 패턴 + Real API)
  - viewmodels/user_profile_viewmodel.dart - UserProfileViewModel (프로필 + 게시글)
  - viewmodels/follow_list_viewmodel.dart - FollowListViewModel (팔로워/팔로잉 목록)
  - viewmodels/following_feed_viewmodel.dart - FollowingFeedViewModel (팔로잉 피드)
  - widgets/follow_button.dart - FollowButton, EditProfileButton 위젯
  - widgets/user_profile_header.dart - UserProfileHeader 위젯
  - widgets/follow_user_tile.dart - FollowUserTile 위젯
  - widgets/follow_empty_view.dart - Empty/Error View 위젯
  - widgets/unfollow_dialog.dart - 언팔로우 확인 다이얼로그
  - views/user_profile_view.dart - 사용자 프로필 화면 (FO-01)
  - views/follow_list_view.dart - 팔로워/팔로잉 목록 화면 (FO-02)
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/follow/`
  - entity/MemberFollow.java - 회원 팔로우 Entity
  - repository/MemberFollowRepository.java - Spring Data JPA Repository
  - dto/response/UserProfileResponse.java - 사용자 프로필 응답 DTO
  - dto/response/FollowUserResponse.java - 팔로워/팔로잉 아이템 응답 DTO
  - dto/response/FollowListResponse.java - 팔로워/팔로잉 목록 응답 DTO
  - service/FollowService.java - 팔로우 비즈니스 로직
  - controller/FollowController.java - REST Controller
- FeedPost 확장:
  - repository/FeedPostRepository.java - 팔로잉 피드 쿼리 추가
  - service/FeedPostService.java - getUserPosts, getFollowingFeed 메서드 추가
  - controller/FeedPostController.java - GET /api/v1/posts/following 엔드포인트 추가
  - dto/response/FeedPostListResponse.java - empty() 메서드 추가

---

### F8: Search (검색) [status: completed]

#### 설명
통합 검색 기능 (노래, 아티스트, 게시글, 사용자)

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 관련 파일
- UX 문서: `docs/ux/features/search-flow.md`, `search-screens.md`
- Frontend: `hibi_front/lib/features/search/`
  - models/search_models.dart - SearchSong, SearchArtist, SearchPost, SearchUser, SearchResult, RecentSearch 모델
  - mocks/search_mock.dart - Mock 검색 데이터 및 함수
  - repos/search_repo.dart - Repository (Mock Provider 패턴 + Real API + SharedPreferences)
  - viewmodels/search_viewmodel.dart - SearchViewModel (디바운스, 카테고리 필터)
  - widgets/search_bar_widget.dart - 검색창 위젯
  - widgets/recent_search_item.dart - 최근 검색어 아이템
  - widgets/search_section_header.dart - 검색 결과 섹션 헤더
  - widgets/song_search_tile.dart - 노래 검색 결과 타일
  - widgets/artist_search_tile.dart - 아티스트 검색 결과 타일
  - widgets/post_search_tile.dart - 게시글 검색 결과 타일
  - widgets/user_search_tile.dart - 사용자 검색 결과 타일
  - widgets/search_category_tabs.dart - 카테고리 탭
  - widgets/search_empty_view.dart - Empty/Error View
  - views/search_view.dart - 검색 메인 화면
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/search/`
  - dto/response/SearchResponse.java - 통합 검색 응답 DTO
  - dto/response/SearchSongResponse.java - 노래 검색 응답 DTO
  - dto/response/SearchArtistResponse.java - 아티스트 검색 응답 DTO
  - dto/response/SearchPostResponse.java - 게시글 검색 응답 DTO
  - dto/response/SearchUserResponse.java - 사용자 검색 응답 DTO
  - dto/response/SearchTotalCountResponse.java - 검색 결과 카운트 응답 DTO
  - service/SearchService.java - 통합 검색 비즈니스 로직
  - controller/SearchController.java - REST Controller (GET /api/v1/search)
- 기존 Repository 검색 메서드:
  - domain/song/repository/SongRepository.java - searchByKeyword()
  - domain/artist/repository/ArtistRepository.java - searchByKeyword()
  - domain/member/repository/MemberRepository.java - searchByKeyword()
  - domain/feedpost/repository/FeedPostRepository.java - searchByKeyword()
- 기술 문서: `docs/tech/api-spec.md` 섹션 9, `docs/tech/db-schema.md` 섹션 13

---

## Phase 2 진행률

| Feature | Step 1 | Step 2 | Step 3 | Step 4 | Status |
|---------|--------|--------|--------|--------|--------|
| F5: Post | Done | Done | Done | Done | **completed** |
| F6: Comment | Done | Done | Done | Done | **completed** |
| F7: Follow | Done | Done | Done | Done | **completed** |
| F8: Search | Done | Done | Done | Done | **completed** |

**Phase 2 진행률**: 4/4 Features (100%) - Phase 2 완료!
