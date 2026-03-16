/// 사용자 프로필 정보 (팔로우 기능용)
class UserProfile {
  final int id;
  final String nickname;
  final String username;
  final String? profileImage;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isFollowing;

  UserProfile({
    required this.id,
    required this.nickname,
    required this.username,
    this.profileImage,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  UserProfile.empty()
      : id = 0,
        nickname = '',
        username = '',
        profileImage = null,
        postCount = 0,
        followerCount = 0,
        followingCount = 0,
        isFollowing = false;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      nickname: json['nickname'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['profileImage'],
      postCount: json['postCount'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'username': username,
      'profileImage': profileImage,
      'postCount': postCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'isFollowing': isFollowing,
    };
  }

  UserProfile copyWith({
    int? id,
    String? nickname,
    String? username,
    String? profileImage,
    int? postCount,
    int? followerCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

/// 팔로워/팔로잉 목록 아이템 (간략 정보)
class FollowUser {
  final int id;
  final String nickname;
  final String username;
  final String? profileImage;
  final bool isFollowing;

  FollowUser({
    required this.id,
    required this.nickname,
    required this.username,
    this.profileImage,
    this.isFollowing = false,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id'] ?? 0,
      nickname: json['nickname'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['profileImage'],
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'username': username,
      'profileImage': profileImage,
      'isFollowing': isFollowing,
    };
  }

  FollowUser copyWith({
    int? id,
    String? nickname,
    String? username,
    String? profileImage,
    bool? isFollowing,
  }) {
    return FollowUser(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  /// UserProfile로 변환
  UserProfile toUserProfile() {
    return UserProfile(
      id: id,
      nickname: nickname,
      username: username,
      profileImage: profileImage,
      isFollowing: isFollowing,
    );
  }
}

/// 팔로워/팔로잉 목록 응답
class FollowListResponse {
  final List<FollowUser> users;
  final int totalCount;
  final bool hasMore;

  FollowListResponse({
    required this.users,
    required this.totalCount,
    this.hasMore = false,
  });

  factory FollowListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> content = json['content'] ?? [];
    return FollowListResponse(
      users: content.map((e) => FollowUser.fromJson(e)).toList(),
      totalCount: json['totalCount'] ?? content.length,
      hasMore: json['hasMore'] ?? false,
    );
  }

  factory FollowListResponse.empty() {
    return FollowListResponse(
      users: [],
      totalCount: 0,
      hasMore: false,
    );
  }
}

/// 피드 필터 타입
enum FeedFilterType {
  all,      // 전체 피드
  following // 팔로잉 피드
}
