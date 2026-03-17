import 'package:hidi/features/comments/models/comment_models.dart';

/// Mock 댓글 작성자 데이터
final mockCommentAuthors = [
  CommentAuthor(
    id: 1,
    nickname: '음악러버',
    username: 'music_lover_99',
    profileImage: 'https://i.pravatar.cc/150?img=1',
  ),
  CommentAuthor(
    id: 2,
    nickname: 'JPOP팬',
    username: 'jpop_fan_kr',
    profileImage: 'https://i.pravatar.cc/150?img=2',
  ),
  CommentAuthor(
    id: 3,
    nickname: '요아소비덕후',
    username: 'yoasobi_daisuki',
    profileImage: 'https://i.pravatar.cc/150?img=3',
  ),
  CommentAuthor(
    id: 4,
    nickname: '아이묭팬',
    username: 'aimyon_lover',
    profileImage: null,
  ),
  CommentAuthor(
    id: 5,
    nickname: '나',
    username: 'current_user',
    profileImage: 'https://i.pravatar.cc/150?img=5',
  ),
];

/// 현재 사용자 ID (Mock용)
const mockCurrentUserId = 5;

/// Mock 댓글 데이터 - 게시글 1번에 대한 댓글
final mockCommentsForPost1 = [
  Comment(
    id: 1,
    postId: 1,
    author: mockCommentAuthors[0],
    content: '정말 좋은 곡이죠! 저도 요즘 매일 듣고 있어요. 특히 후렴구가 정말 인상적이에요.',
    likeCount: 12,
    isLiked: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    replies: [
      Comment(
        id: 2,
        postId: 1,
        author: mockCommentAuthors[1],
        content: '@음악러버 저도 동감이에요! 후렴구 멜로디가 머리에서 안 떠나요 ㅋㅋ',
        parentId: 1,
        parentAuthorNickname: '음악러버',
        likeCount: 5,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Comment(
        id: 3,
        postId: 1,
        author: mockCommentAuthors[4], // 현재 사용자
        content: '@음악러버 앨범 전체가 명반이에요! 다른 곡들도 추천드려요.',
        parentId: 1,
        parentAuthorNickname: '음악러버',
        likeCount: 2,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  ),
  Comment(
    id: 4,
    postId: 1,
    author: mockCommentAuthors[2],
    content: '요아소비 노래는 가사도 정말 좋아요. 일본어 공부하면서 들으면 더 좋더라고요.',
    likeCount: 8,
    isLiked: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    replies: [],
  ),
  Comment(
    id: 5,
    postId: 1,
    author: mockCommentAuthors[3],
    content: '이 노래 덕분에 JPOP에 입문했어요! 감사합니다.',
    likeCount: 3,
    isLiked: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    replies: [
      Comment(
        id: 6,
        postId: 1,
        author: mockCommentAuthors[0],
        content: '@아이묭팬 환영해요! JPOP 세계는 정말 넓고 좋은 곡들이 많아요.',
        parentId: 5,
        parentAuthorNickname: '아이묭팬',
        likeCount: 1,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ],
  ),
  Comment(
    id: 7,
    postId: 1,
    author: mockCommentAuthors[4], // 현재 사용자
    content: '저도 이 곡 정말 좋아해요! 출퇴근길에 항상 듣고 있어요.',
    likeCount: 0,
    isLiked: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    replies: [],
  ),
  // F16: 필터링된 댓글 (부적절 내용)
  Comment(
    id: 8,
    postId: 1,
    author: CommentAuthor(
      id: 99,
      nickname: '악성유저',
      username: 'bad_user',
      profileImage: null,
    ),
    content: '',
    likeCount: 0,
    isLiked: false,
    isFiltered: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    replies: [],
  ),
];

/// Mock 댓글 데이터 - 게시글 2번에 대한 댓글 (삭제된 댓글 포함)
final mockCommentsForPost2 = [
  Comment.deleted(
    id: 10,
    postId: 2,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    replies: [
      Comment(
        id: 11,
        postId: 2,
        author: mockCommentAuthors[1],
        content: '@삭제됨 그래도 동의해요!',
        parentId: 10,
        parentAuthorNickname: '삭제됨',
        likeCount: 1,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
    ],
  ),
  Comment(
    id: 12,
    postId: 2,
    author: mockCommentAuthors[2],
    content: '좋은 정보 감사합니다!',
    likeCount: 2,
    isLiked: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    replies: [],
  ),
];

/// Mock 댓글 데이터 - 댓글 없는 게시글
final List<Comment> mockCommentsEmpty = [];

/// 게시글 ID별 Mock 댓글 반환
List<Comment> getMockCommentsForPost(int postId) {
  switch (postId) {
    case 1:
      return mockCommentsForPost1;
    case 2:
      return mockCommentsForPost2;
    default:
      return mockCommentsEmpty;
  }
}

/// 게시글 ID별 댓글 수 반환
int getMockCommentCount(int postId) {
  final comments = getMockCommentsForPost(postId);
  int count = 0;
  for (final comment in comments) {
    count += 1 + comment.replies.length;
  }
  return count;
}
