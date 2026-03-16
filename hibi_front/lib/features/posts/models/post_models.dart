import 'package:hidi/features/daily-song/models/daily_song_model.dart';

/// 게시글 작성자 정보
class PostAuthor {
  final int id;
  final String nickname;
  final String username;
  final String? profileImage;

  PostAuthor({
    required this.id,
    required this.nickname,
    required this.username,
    this.profileImage,
  });

  PostAuthor.empty()
      : id = 0,
        nickname = '',
        username = '',
        profileImage = null;

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] ?? 0,
      nickname: json['nickname'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'username': username,
      'profileImage': profileImage,
    };
  }
}

/// 게시글에 태그된 노래 정보 (간략)
class TaggedSong {
  final int id;
  final String titleKor;
  final String titleJp;
  final String artistName;
  final String? albumImageUrl;
  final String? albumName;
  final int? releaseYear;

  TaggedSong({
    required this.id,
    required this.titleKor,
    required this.titleJp,
    required this.artistName,
    this.albumImageUrl,
    this.albumName,
    this.releaseYear,
  });

  factory TaggedSong.fromDailySong(DailySong song) {
    return TaggedSong(
      id: song.id,
      titleKor: song.titleKor,
      titleJp: song.titleJp,
      artistName: song.artist.nameKor,
      albumImageUrl: song.album.imageUrl,
      albumName: song.album.name,
      releaseYear: song.album.releaseDate.year,
    );
  }

  factory TaggedSong.fromJson(Map<String, dynamic> json) {
    return TaggedSong(
      id: json['id'] ?? 0,
      titleKor: json['titleKor'] ?? '',
      titleJp: json['titleJp'] ?? '',
      artistName: json['artistName'] ?? '',
      albumImageUrl: json['albumImageUrl'],
      albumName: json['albumName'],
      releaseYear: json['releaseYear'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKor': titleKor,
      'titleJp': titleJp,
      'artistName': artistName,
      'albumImageUrl': albumImageUrl,
      'albumName': albumName,
      'releaseYear': releaseYear,
    };
  }
}

/// 게시글 모델
class Post {
  final int id;
  final PostAuthor author;
  final String content;
  final List<String> images;
  final TaggedSong? taggedSong;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Post({
    required this.id,
    required this.author,
    required this.content,
    this.images = const [],
    this.taggedSong,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.updatedAt,
  });

  Post.empty()
      : id = 0,
        author = PostAuthor.empty(),
        content = '',
        images = const [],
        taggedSong = null,
        likeCount = 0,
        commentCount = 0,
        isLiked = false,
        createdAt = DateTime.now(),
        updatedAt = null;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      author: json['author'] != null
          ? PostAuthor.fromJson(json['author'])
          : PostAuthor.empty(),
      content: json['content'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : const [],
      taggedSong: json['taggedSong'] != null
          ? TaggedSong.fromJson(json['taggedSong'])
          : null,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'images': images,
      'taggedSong': taggedSong?.toJson(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Post copyWith({
    int? id,
    PostAuthor? author,
    String? content,
    List<String>? images,
    TaggedSong? taggedSong,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearTaggedSong = false,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      images: images ?? this.images,
      taggedSong: clearTaggedSong ? null : (taggedSong ?? this.taggedSong),
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 본인 게시글인지 확인
  bool isAuthor(int? userId) => userId != null && author.id == userId;
}

/// 게시글 작성 요청
class PostCreateRequest {
  final String content;
  final List<String> images;
  final int? taggedSongId;

  PostCreateRequest({
    required this.content,
    this.images = const [],
    this.taggedSongId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'images': images,
      'taggedSongId': taggedSongId,
    };
  }
}

/// 게시글 수정 요청
class PostUpdateRequest {
  final String content;
  final List<String> images;
  final int? taggedSongId;

  PostUpdateRequest({
    required this.content,
    this.images = const [],
    this.taggedSongId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'images': images,
      'taggedSongId': taggedSongId,
    };
  }
}
