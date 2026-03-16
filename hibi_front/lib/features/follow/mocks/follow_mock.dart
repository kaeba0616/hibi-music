import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/posts/models/post_models.dart';

/// Mock 현재 사용자 ID
const int mockCurrentUserId = 1;

/// Mock 사용자 프로필 데이터
final List<UserProfile> mockUserProfiles = [
  UserProfile(
    id: 1,
    nickname: '요아소비덕후',
    username: 'yoasobi_fan',
    profileImage: 'https://picsum.photos/200?random=1',
    postCount: 24,
    followerCount: 156,
    followingCount: 89,
    isFollowing: false, // 본인
  ),
  UserProfile(
    id: 2,
    nickname: '음악러버',
    username: 'music_lover',
    profileImage: 'https://picsum.photos/200?random=2',
    postCount: 12,
    followerCount: 234,
    followingCount: 45,
    isFollowing: true,
  ),
  UserProfile(
    id: 3,
    nickname: 'JPOP팬',
    username: 'jpop_fan',
    profileImage: 'https://picsum.photos/200?random=3',
    postCount: 8,
    followerCount: 89,
    followingCount: 120,
    isFollowing: false,
  ),
  UserProfile(
    id: 4,
    nickname: '아이묭좋아',
    username: 'aimyon_love',
    profileImage: 'https://picsum.photos/200?random=4',
    postCount: 45,
    followerCount: 567,
    followingCount: 234,
    isFollowing: true,
  ),
  UserProfile(
    id: 5,
    nickname: '시티팝매니아',
    username: 'citypop_mania',
    profileImage: null, // 프로필 이미지 없음
    postCount: 0,
    followerCount: 12,
    followingCount: 78,
    isFollowing: false,
  ),
];

/// Mock 팔로워 목록 (사용자 1번의 팔로워)
final Map<int, List<FollowUser>> mockFollowers = {
  1: [
    FollowUser(
      id: 2,
      nickname: '음악러버',
      username: 'music_lover',
      profileImage: 'https://picsum.photos/200?random=2',
      isFollowing: true,
    ),
    FollowUser(
      id: 3,
      nickname: 'JPOP팬',
      username: 'jpop_fan',
      profileImage: 'https://picsum.photos/200?random=3',
      isFollowing: false,
    ),
    FollowUser(
      id: 4,
      nickname: '아이묭좋아',
      username: 'aimyon_love',
      profileImage: 'https://picsum.photos/200?random=4',
      isFollowing: true,
    ),
  ],
  2: [
    FollowUser(
      id: 1,
      nickname: '요아소비덕후',
      username: 'yoasobi_fan',
      profileImage: 'https://picsum.photos/200?random=1',
      isFollowing: false, // 본인
    ),
    FollowUser(
      id: 4,
      nickname: '아이묭좋아',
      username: 'aimyon_love',
      profileImage: 'https://picsum.photos/200?random=4',
      isFollowing: true,
    ),
  ],
  5: [], // 팔로워 없음
};

/// Mock 팔로잉 목록 (사용자가 팔로우하는 사람들)
final Map<int, List<FollowUser>> mockFollowing = {
  1: [
    FollowUser(
      id: 2,
      nickname: '음악러버',
      username: 'music_lover',
      profileImage: 'https://picsum.photos/200?random=2',
      isFollowing: true,
    ),
    FollowUser(
      id: 4,
      nickname: '아이묭좋아',
      username: 'aimyon_love',
      profileImage: 'https://picsum.photos/200?random=4',
      isFollowing: true,
    ),
  ],
  2: [
    FollowUser(
      id: 3,
      nickname: 'JPOP팬',
      username: 'jpop_fan',
      profileImage: 'https://picsum.photos/200?random=3',
      isFollowing: false,
    ),
  ],
  5: [], // 팔로잉 없음
};

/// Mock 사용자 게시글 데이터
final Map<int, List<Post>> mockUserPosts = {
  1: [
    Post(
      id: 101,
      author: PostAuthor(
        id: 1,
        nickname: '요아소비덕후',
        username: 'yoasobi_fan',
        profileImage: 'https://picsum.photos/200?random=1',
      ),
      content: '오늘의 요아소비 노래는 정말 최고였어요! 아이돌이 신나게 들려서 기분이 좋아지네요.',
      images: ['https://picsum.photos/400/300?random=101'],
      likeCount: 24,
      commentCount: 5,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Post(
      id: 102,
      author: PostAuthor(
        id: 1,
        nickname: '요아소비덕후',
        username: 'yoasobi_fan',
        profileImage: 'https://picsum.photos/200?random=1',
      ),
      content: '밤을 달리다를 들으면서 야경 보는 중... 너무 좋다',
      images: [],
      likeCount: 18,
      commentCount: 3,
      isLiked: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ],
  2: [
    Post(
      id: 201,
      author: PostAuthor(
        id: 2,
        nickname: '음악러버',
        username: 'music_lover',
        profileImage: 'https://picsum.photos/200?random=2',
      ),
      content: '오늘 추천곡 너무 좋아요! 아침부터 기분이 좋네요.',
      images: [],
      likeCount: 15,
      commentCount: 2,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ],
  4: [
    Post(
      id: 401,
      author: PostAuthor(
        id: 4,
        nickname: '아이묭좋아',
        username: 'aimyon_love',
        profileImage: 'https://picsum.photos/200?random=4',
      ),
      content: '아이묭 콘서트 다녀왔어요! 정말 감동이었습니다.',
      images: [
        'https://picsum.photos/400/300?random=401',
        'https://picsum.photos/400/300?random=402',
      ],
      likeCount: 89,
      commentCount: 15,
      isLiked: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ],
  5: [], // 게시글 없음
};

/// Mock 팔로잉 피드 (팔로우한 사용자들의 게시글)
List<Post> getMockFollowingFeed() {
  final followingIds = mockFollowing[mockCurrentUserId]?.map((u) => u.id).toSet() ?? {};
  final posts = <Post>[];

  for (final userId in followingIds) {
    final userPosts = mockUserPosts[userId] ?? [];
    posts.addAll(userPosts);
  }

  // 최신순 정렬
  posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return posts;
}

/// 사용자 프로필 조회
UserProfile? getMockUserProfile(int userId) {
  try {
    return mockUserProfiles.firstWhere((p) => p.id == userId);
  } catch (_) {
    return null;
  }
}

/// 팔로워 목록 조회
FollowListResponse getMockFollowers(int userId) {
  final followers = mockFollowers[userId] ?? [];
  return FollowListResponse(
    users: followers,
    totalCount: followers.length,
    hasMore: false,
  );
}

/// 팔로잉 목록 조회
FollowListResponse getMockFollowing(int userId) {
  final following = mockFollowing[userId] ?? [];
  return FollowListResponse(
    users: following,
    totalCount: following.length,
    hasMore: false,
  );
}

/// 사용자 게시글 조회
List<Post> getMockUserPosts(int userId, {int page = 0, int size = 20}) {
  final posts = mockUserPosts[userId] ?? [];
  final start = page * size;
  if (start >= posts.length) return [];
  final end = (start + size).clamp(0, posts.length);
  return posts.sublist(start, end);
}

/// 팔로우 상태 변경 (Mock)
void toggleMockFollow(int userId) {
  final index = mockUserProfiles.indexWhere((p) => p.id == userId);
  if (index != -1) {
    final profile = mockUserProfiles[index];
    mockUserProfiles[index] = profile.copyWith(
      isFollowing: !profile.isFollowing,
      followerCount: profile.isFollowing
          ? profile.followerCount - 1
          : profile.followerCount + 1,
    );
  }
}
