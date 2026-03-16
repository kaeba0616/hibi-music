import 'package:hidi/features/posts/models/post_models.dart';

/// Mock 작성자 데이터
final mockAuthors = [
  PostAuthor(
    id: 1,
    nickname: 'JPOP러버',
    username: 'jpop_lover',
    profileImage: 'https://i.pravatar.cc/150?u=jpop_lover',
  ),
  PostAuthor(
    id: 2,
    nickname: '음악팬',
    username: 'musicfan',
    profileImage: 'https://i.pravatar.cc/150?u=musicfan',
  ),
  PostAuthor(
    id: 3,
    nickname: '요아소비덕후',
    username: 'yoasobi_fan',
    profileImage: 'https://i.pravatar.cc/150?u=yoasobi_fan',
  ),
  PostAuthor(
    id: 4,
    nickname: '히게단팬',
    username: 'higedan_love',
    profileImage: 'https://i.pravatar.cc/150?u=higedan_love',
  ),
  PostAuthor(
    id: 5,
    nickname: '나',
    username: 'me',
    profileImage: 'https://i.pravatar.cc/150?u=me',
  ),
];

/// Mock 태그된 노래 데이터
final mockTaggedSongs = [
  TaggedSong(
    id: 1,
    titleKor: '밤을 달리다',
    titleJp: '夜に駆ける',
    artistName: '요아소비',
    albumImageUrl: 'assets/images/album_the_book.jpg',
    albumName: 'THE BOOK',
    releaseYear: 2021,
  ),
  TaggedSong(
    id: 2,
    titleKor: '마리골드',
    titleJp: 'マリーゴールド',
    artistName: '아이묭',
    albumImageUrl: 'assets/images/album_aimyon.jpg',
    albumName: '瞬間的シックスセンス',
    releaseYear: 2019,
  ),
  TaggedSong(
    id: 3,
    titleKor: 'Pretender',
    titleJp: 'Pretender',
    artistName: '히게단디즘',
    albumImageUrl: 'assets/images/album_higedan.jpg',
    albumName: 'Editorial',
    releaseYear: 2021,
  ),
  TaggedSong(
    id: 4,
    titleKor: '춤추다',
    titleJp: '踊',
    artistName: '아도',
    albumImageUrl: 'assets/images/album_ado.jpg',
    albumName: '狂言',
    releaseYear: 2022,
  ),
];

/// Mock 게시글 데이터 (현실적인 JPOP 커뮤니티 게시글)
List<Post> get mockPosts {
  final now = DateTime.now();
  return [
    Post(
      id: 1,
      author: mockAuthors[0],
      content: '오늘 들은 곡 너무 좋아요! YOASOBI 신곡 최고 ❤️\n진짜 이 곡 듣고 하루 종일 기분이 좋았어요. 다들 한번 들어보세요!',
      taggedSong: mockTaggedSongs[0],
      likeCount: 24,
      commentCount: 5,
      isLiked: false,
      createdAt: now.subtract(const Duration(minutes: 3)),
    ),
    Post(
      id: 2,
      author: mockAuthors[1],
      content: '요즘 아이묭 노래에 빠졌어요 🎵\n마리골드 무한반복 중... 가사가 너무 좋아서 눈물날 것 같아요 ㅠㅠ',
      taggedSong: mockTaggedSongs[1],
      likeCount: 42,
      commentCount: 12,
      isLiked: true,
      createdAt: now.subtract(const Duration(hours: 1)),
    ),
    Post(
      id: 3,
      author: mockAuthors[2],
      content: '요아소비 라이브 직캠 봤는데 소름돋음...ikura 보컬 진짜 미쳤어요\n언젠가 꼭 라이브 가고 싶다 🥺',
      images: [
        'https://picsum.photos/seed/yoasobi1/400/300',
        'https://picsum.photos/seed/yoasobi2/400/300',
      ],
      likeCount: 156,
      commentCount: 28,
      isLiked: true,
      createdAt: now.subtract(const Duration(hours: 3)),
    ),
    Post(
      id: 4,
      author: mockAuthors[3],
      content: 'Pretender 들으면서 출근하는데 왜 눈물이 나죠...?\n이 노래 듣고 첫사랑 생각나는 사람 저만 있나요 ㅋㅋㅋ',
      taggedSong: mockTaggedSongs[2],
      likeCount: 89,
      commentCount: 15,
      isLiked: false,
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
    Post(
      id: 5,
      author: mockAuthors[4], // 본인 게시글
      content: '오늘 처음으로 Ado 곡 들어봤는데 뭐야 이거 왜 이렇게 좋아?!\n목소리가 진짜 독특하고 중독성 있어요',
      taggedSong: mockTaggedSongs[3],
      likeCount: 31,
      commentCount: 7,
      isLiked: true,
      createdAt: now.subtract(const Duration(hours: 8)),
    ),
    Post(
      id: 6,
      author: mockAuthors[0],
      content: '오늘의 플레이리스트 공유합니다!\n\n1. 夜に駆ける - YOASOBI\n2. マリーゴールド - あいみょん\n3. Pretender - Official髭男dism\n4. 踊 - Ado\n\n다들 좋은 하루 보내세요 🎶',
      likeCount: 67,
      commentCount: 9,
      isLiked: false,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    Post(
      id: 7,
      author: mockAuthors[1],
      content: '일본 여행 중에 들은 노래들이 자꾸 생각나요... 그때 카페에서 우연히 들은 곡인데 아직도 기억에 남아요',
      images: [
        'https://picsum.photos/seed/japan1/400/300',
        'https://picsum.photos/seed/japan2/400/300',
        'https://picsum.photos/seed/japan3/400/300',
      ],
      likeCount: 203,
      commentCount: 34,
      isLiked: true,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
  ];
}

/// Mock 현재 사용자 ID (본인 게시글 확인용)
const mockCurrentUserId = 5;

/// 게시글 목록 가져오기 (Mock)
List<Post> getMockPosts({int page = 0, int size = 20}) {
  final posts = mockPosts;
  final start = page * size;
  if (start >= posts.length) return [];
  final end = (start + size) > posts.length ? posts.length : start + size;
  return posts.sublist(start, end);
}

/// 게시글 상세 가져오기 (Mock)
Post? getMockPostById(int id) {
  try {
    return mockPosts.firstWhere((post) => post.id == id);
  } catch (e) {
    return null;
  }
}

/// 게시글 생성 (Mock) - 새 게시글 반환
Post createMockPost({
  required String content,
  List<String> images = const [],
  TaggedSong? taggedSong,
}) {
  final newId = mockPosts.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
  return Post(
    id: newId,
    author: mockAuthors[4], // 현재 사용자
    content: content,
    images: images,
    taggedSong: taggedSong,
    likeCount: 0,
    commentCount: 0,
    isLiked: false,
    createdAt: DateTime.now(),
  );
}

/// 노래 검색 (Mock)
List<TaggedSong> searchMockSongs(String query) {
  if (query.isEmpty) return mockTaggedSongs;
  final lowerQuery = query.toLowerCase();
  return mockTaggedSongs.where((song) =>
    song.titleKor.toLowerCase().contains(lowerQuery) ||
    song.titleJp.toLowerCase().contains(lowerQuery) ||
    song.artistName.toLowerCase().contains(lowerQuery)
  ).toList();
}
