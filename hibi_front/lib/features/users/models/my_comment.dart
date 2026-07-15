import 'package:hidi/features/comments/models/comment_models.dart';

/// 내가 쓴 댓글에 포함되는 곡 정보
class MyCommentSongInfo {
  final int songId;
  final String songTitle;
  final String artistName;

  const MyCommentSongInfo({
    required this.songId,
    required this.songTitle,
    required this.artistName,
  });
}

/// 내가 쓴 댓글 (곡 정보 포함)
class MyComment {
  final Comment comment;
  final MyCommentSongInfo songInfo;

  const MyComment({
    required this.comment,
    required this.songInfo,
  });

  /// 백엔드 MyCommentResponse 매핑
  /// {commentId, content, likeCount, createdAt, songId, songTitle, artistName}
  factory MyComment.fromJson(Map<String, dynamic> json) {
    return MyComment(
      comment: Comment(
        id: json['commentId'] as int,
        postId: 0, // 응답에 게시글 ID가 없어 미사용 값으로 둔다
        author: CommentAuthor(id: 0, nickname: '나', username: ''),
        content: json['content'] as String? ?? '',
        likeCount: json['likeCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      ),
      songInfo: MyCommentSongInfo(
        songId: json['songId'] as int? ?? 0,
        songTitle: json['songTitle'] as String? ?? '',
        artistName: json['artistName'] as String? ?? '',
      ),
    );
  }
}
