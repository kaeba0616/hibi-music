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
}

/// Mock 현재 사용자 작성자 정보
final mockCurrentAuthor = CommentAuthor(
  id: 5,
  nickname: '나',
  username: 'current_user',
  profileImage: 'https://i.pravatar.cc/150?img=5',
);

/// Mock 내가 쓴 댓글 데이터 (5개)
final mockMyComments = [
  MyComment(
    comment: Comment(
      id: 101,
      postId: 1,
      author: mockCurrentAuthor,
      content: '정말 좋은 곡이에요! 출퇴근길에 매일 듣고 있습니다. 가사가 정말 마음에 와닿아요.',
      likeCount: 3,
      isLiked: false,
      createdAt: DateTime(2026, 3, 15, 14, 30),
    ),
    songInfo: const MyCommentSongInfo(
      songId: 1,
      songTitle: '夜に駆ける',
      artistName: 'YOASOBI',
    ),
  ),
  MyComment(
    comment: Comment(
      id: 102,
      postId: 2,
      author: mockCurrentAuthor,
      content: 'Lemon은 정말 명곡이죠. 요네즈 켄시의 감성이 느껴져요.',
      likeCount: 7,
      isLiked: true,
      createdAt: DateTime(2026, 3, 14, 9, 15),
    ),
    songInfo: const MyCommentSongInfo(
      songId: 2,
      songTitle: 'Lemon',
      artistName: '米津玄師',
    ),
  ),
  MyComment(
    comment: Comment(
      id: 103,
      postId: 3,
      author: mockCurrentAuthor,
      content: '@음악러버 앨범 전체가 명반이에요! 다른 곡들도 꼭 들어보세요.',
      parentId: 1,
      parentAuthorNickname: '음악러버',
      likeCount: 2,
      isLiked: false,
      createdAt: DateTime(2026, 3, 13, 18, 45),
    ),
    songInfo: const MyCommentSongInfo(
      songId: 3,
      songTitle: 'アイドル',
      artistName: 'YOASOBI',
    ),
  ),
  MyComment(
    comment: Comment(
      id: 104,
      postId: 4,
      author: mockCurrentAuthor,
      content: '이 곡을 들으면 항상 힐링이 돼요. 아이묭 최고!',
      likeCount: 5,
      isLiked: false,
      createdAt: DateTime(2026, 3, 12, 22, 0),
    ),
    songInfo: const MyCommentSongInfo(
      songId: 4,
      songTitle: 'マリーゴールド',
      artistName: 'あいみょん',
    ),
  ),
  MyComment(
    comment: Comment(
      id: 105,
      postId: 5,
      author: mockCurrentAuthor,
      content: '처음 들었는데 바로 빠져버렸어요. 중독성 강한 멜로디네요!',
      likeCount: 1,
      isLiked: false,
      createdAt: DateTime(2026, 3, 10, 11, 20),
    ),
    songInfo: const MyCommentSongInfo(
      songId: 5,
      songTitle: 'Pretender',
      artistName: 'Official髭男dism',
    ),
  ),
];
