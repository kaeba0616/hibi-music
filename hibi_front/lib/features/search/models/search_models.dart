/// 검색 카테고리
enum SearchCategory {
  all,      // 전체
  songs,    // 노래
  artists,  // 아티스트
  posts,    // 게시글
  users,    // 사용자
}

extension SearchCategoryExtension on SearchCategory {
  String get label {
    switch (this) {
      case SearchCategory.all:
        return '전체';
      case SearchCategory.songs:
        return '노래';
      case SearchCategory.artists:
        return '아티스트';
      case SearchCategory.posts:
        return '게시글';
      case SearchCategory.users:
        return '사용자';
    }
  }
}

/// 검색 결과 노래
class SearchSong {
  final int id;
  final String titleKor;
  final String titleJp;
  final String artistName;
  final String albumName;
  final String? albumImageUrl;
  final int releaseYear;
  final String? genre;
  final int likeCount;

  SearchSong({
    required this.id,
    required this.titleKor,
    required this.titleJp,
    required this.artistName,
    required this.albumName,
    this.albumImageUrl,
    required this.releaseYear,
    this.genre,
    this.likeCount = 0,
  });

  factory SearchSong.fromJson(Map<String, dynamic> json) {
    return SearchSong(
      id: json['id'] ?? 0,
      titleKor: json['titleKor'] ?? '',
      titleJp: json['titleJp'] ?? '',
      artistName: json['artistName'] ?? '',
      albumName: json['albumName'] ?? '',
      albumImageUrl: json['albumImageUrl'],
      releaseYear: json['releaseYear'] ?? 0,
      genre: json['genre'],
      likeCount: json['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKor': titleKor,
      'titleJp': titleJp,
      'artistName': artistName,
      'albumName': albumName,
      'albumImageUrl': albumImageUrl,
      'releaseYear': releaseYear,
      'genre': genre,
      'likeCount': likeCount,
    };
  }
}

/// 검색 결과 아티스트
class SearchArtist {
  final int id;
  final String nameKor;
  final String nameEng;
  final String nameJp;
  final String? profileUrl;
  final int songCount;
  final int followerCount;
  final bool isFollowing;

  SearchArtist({
    required this.id,
    required this.nameKor,
    required this.nameEng,
    required this.nameJp,
    this.profileUrl,
    this.songCount = 0,
    this.followerCount = 0,
    this.isFollowing = false,
  });

  factory SearchArtist.fromJson(Map<String, dynamic> json) {
    return SearchArtist(
      id: json['id'] ?? 0,
      nameKor: json['nameKor'] ?? '',
      nameEng: json['nameEng'] ?? '',
      nameJp: json['nameJp'] ?? '',
      profileUrl: json['profileUrl'],
      songCount: json['songCount'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameKor': nameKor,
      'nameEng': nameEng,
      'nameJp': nameJp,
      'profileUrl': profileUrl,
      'songCount': songCount,
      'followerCount': followerCount,
      'isFollowing': isFollowing,
    };
  }

  SearchArtist copyWith({
    int? id,
    String? nameKor,
    String? nameEng,
    String? nameJp,
    String? profileUrl,
    int? songCount,
    int? followerCount,
    bool? isFollowing,
  }) {
    return SearchArtist(
      id: id ?? this.id,
      nameKor: nameKor ?? this.nameKor,
      nameEng: nameEng ?? this.nameEng,
      nameJp: nameJp ?? this.nameJp,
      profileUrl: profileUrl ?? this.profileUrl,
      songCount: songCount ?? this.songCount,
      followerCount: followerCount ?? this.followerCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

/// 검색 결과 게시글
class SearchPost {
  final int id;
  final String content;
  final String authorNickname;
  final String? authorProfileImage;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  SearchPost({
    required this.id,
    required this.content,
    required this.authorNickname,
    this.authorProfileImage,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
  });

  factory SearchPost.fromJson(Map<String, dynamic> json) {
    return SearchPost(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      authorNickname: json['authorNickname'] ?? '',
      authorProfileImage: json['authorProfileImage'],
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorNickname': authorNickname,
      'authorProfileImage': authorProfileImage,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 검색 결과 사용자
class SearchUser {
  final int id;
  final String nickname;
  final String username;
  final String? profileImage;
  final bool isFollowing;

  SearchUser({
    required this.id,
    required this.nickname,
    required this.username,
    this.profileImage,
    this.isFollowing = false,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
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

  SearchUser copyWith({
    int? id,
    String? nickname,
    String? username,
    String? profileImage,
    bool? isFollowing,
  }) {
    return SearchUser(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

/// 통합 검색 결과
class SearchResult {
  final List<SearchSong> songs;
  final List<SearchArtist> artists;
  final List<SearchPost> posts;
  final List<SearchUser> users;
  final int totalSongs;
  final int totalArtists;
  final int totalPosts;
  final int totalUsers;

  SearchResult({
    this.songs = const [],
    this.artists = const [],
    this.posts = const [],
    this.users = const [],
    this.totalSongs = 0,
    this.totalArtists = 0,
    this.totalPosts = 0,
    this.totalUsers = 0,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      songs: (json['songs'] as List<dynamic>?)
              ?.map((e) => SearchSong.fromJson(e))
              .toList() ??
          [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => SearchArtist.fromJson(e))
              .toList() ??
          [],
      posts: (json['posts'] as List<dynamic>?)
              ?.map((e) => SearchPost.fromJson(e))
              .toList() ??
          [],
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => SearchUser.fromJson(e))
              .toList() ??
          [],
      totalSongs: json['totalSongs'] ?? 0,
      totalArtists: json['totalArtists'] ?? 0,
      totalPosts: json['totalPosts'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
    );
  }

  factory SearchResult.empty() {
    return SearchResult();
  }

  bool get isEmpty =>
      songs.isEmpty && artists.isEmpty && posts.isEmpty && users.isEmpty;

  int get totalCount => totalSongs + totalArtists + totalPosts + totalUsers;
}

/// 최근 검색어
class RecentSearch {
  final String query;
  final DateTime searchedAt;

  RecentSearch({
    required this.query,
    required this.searchedAt,
  });

  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      query: json['query'] ?? '',
      searchedAt: json['searchedAt'] != null
          ? DateTime.parse(json['searchedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }
}
