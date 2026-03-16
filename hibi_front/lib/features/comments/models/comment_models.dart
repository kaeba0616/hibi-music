import 'package:hidi/features/posts/models/post_models.dart';

/// 댓글 작성자 정보
class CommentAuthor {
  final int id;
  final String nickname;
  final String username;
  final String? profileImage;

  CommentAuthor({
    required this.id,
    required this.nickname,
    required this.username,
    this.profileImage,
  });

  CommentAuthor.empty()
      : id = 0,
        nickname = '',
        username = '',
        profileImage = null;

  factory CommentAuthor.fromJson(Map<String, dynamic> json) {
    return CommentAuthor(
      id: json['id'] ?? 0,
      nickname: json['nickname'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  factory CommentAuthor.fromPostAuthor(PostAuthor author) {
    return CommentAuthor(
      id: author.id,
      nickname: author.nickname,
      username: author.username,
      profileImage: author.profileImage,
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

/// 댓글 모델
class Comment {
  final int id;
  final int postId;
  final CommentAuthor author;
  final String content;
  final int? parentId;
  final String? parentAuthorNickname;
  final int likeCount;
  final bool isLiked;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    this.parentId,
    this.parentAuthorNickname,
    this.likeCount = 0,
    this.isLiked = false,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
    this.replies = const [],
  });

  Comment.empty()
      : id = 0,
        postId = 0,
        author = CommentAuthor.empty(),
        content = '',
        parentId = null,
        parentAuthorNickname = null,
        likeCount = 0,
        isLiked = false,
        isDeleted = false,
        createdAt = DateTime.now(),
        updatedAt = null,
        replies = const [];

  /// 삭제된 댓글용 생성자 (대댓글이 있는 경우)
  Comment.deleted({
    required this.id,
    required this.postId,
    required this.createdAt,
    this.replies = const [],
  })  : author = CommentAuthor.empty(),
        content = '',
        parentId = null,
        parentAuthorNickname = null,
        likeCount = 0,
        isLiked = false,
        isDeleted = true,
        updatedAt = null;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? 0,
      author: json['author'] != null
          ? CommentAuthor.fromJson(json['author'])
          : CommentAuthor.empty(),
      content: json['content'] ?? '',
      parentId: json['parentId'],
      parentAuthorNickname: json['parentAuthorNickname'],
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'author': author.toJson(),
      'content': content,
      'parentId': parentId,
      'parentAuthorNickname': parentAuthorNickname,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'replies': replies.map((e) => e.toJson()).toList(),
    };
  }

  Comment copyWith({
    int? id,
    int? postId,
    CommentAuthor? author,
    String? content,
    int? parentId,
    String? parentAuthorNickname,
    int? likeCount,
    bool? isLiked,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      parentAuthorNickname: parentAuthorNickname ?? this.parentAuthorNickname,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
    );
  }

  /// 대댓글인지 확인
  bool get isReply => parentId != null;

  /// 본인 댓글인지 확인
  bool isAuthor(int? userId) => userId != null && author.id == userId;
}

/// 댓글 작성 요청
class CommentCreateRequest {
  final int postId;
  final String content;
  final int? parentId;

  CommentCreateRequest({
    required this.postId,
    required this.content,
    this.parentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'content': content,
      'parentId': parentId,
    };
  }
}

/// 댓글 목록 응답
class CommentListResponse {
  final List<Comment> comments;
  final int totalCount;
  final bool hasMore;

  CommentListResponse({
    required this.comments,
    required this.totalCount,
    this.hasMore = false,
  });

  factory CommentListResponse.fromJson(Map<String, dynamic> json) {
    return CommentListResponse(
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      totalCount: json['totalCount'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }
}
