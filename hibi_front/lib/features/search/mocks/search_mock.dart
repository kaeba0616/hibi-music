import 'package:hidi/features/search/models/search_models.dart';

/// Mock 노래 검색 결과
final List<SearchSong> mockSearchSongs = [
  SearchSong(
    id: 1,
    titleKor: '밤을 달리다',
    titleJp: '夜に駆ける',
    artistName: 'YOASOBI',
    albumName: 'THE BOOK',
    albumImageUrl: 'https://example.com/thebook.jpg',
    releaseYear: 2021,
    genre: 'J-Pop',
    likeCount: 1542,
  ),
  SearchSong(
    id: 2,
    titleKor: '아이돌',
    titleJp: 'アイドル',
    artistName: 'YOASOBI',
    albumName: 'THE BOOK 3',
    albumImageUrl: 'https://example.com/thebook3.jpg',
    releaseYear: 2023,
    genre: 'J-Pop',
    likeCount: 3210,
  ),
  SearchSong(
    id: 3,
    titleKor: '군청',
    titleJp: '群青',
    artistName: 'YOASOBI',
    albumName: 'THE BOOK',
    albumImageUrl: 'https://example.com/thebook.jpg',
    releaseYear: 2021,
    genre: 'J-Pop',
    likeCount: 890,
  ),
  SearchSong(
    id: 4,
    titleKor: '마리골드',
    titleJp: 'マリーゴールド',
    artistName: '아이묭',
    albumName: 'LOVE',
    albumImageUrl: 'https://example.com/love.jpg',
    releaseYear: 2018,
    genre: 'J-Pop',
    likeCount: 2100,
  ),
  SearchSong(
    id: 5,
    titleKor: '레몬',
    titleJp: 'Lemon',
    artistName: '요네즈 켄시',
    albumName: 'BOOTLEG',
    albumImageUrl: 'https://example.com/bootleg.jpg',
    releaseYear: 2018,
    genre: 'J-Pop',
    likeCount: 4500,
  ),
];

/// Mock 아티스트 검색 결과
final List<SearchArtist> mockSearchArtists = [
  SearchArtist(
    id: 1,
    nameKor: '요아소비',
    nameEng: 'YOASOBI',
    nameJp: 'YOASOBI',
    profileUrl: 'https://example.com/yoasobi.jpg',
    songCount: 15,
    followerCount: 12500,
    isFollowing: true,
  ),
  SearchArtist(
    id: 2,
    nameKor: '아이묭',
    nameEng: 'Aimyon',
    nameJp: 'あいみょん',
    profileUrl: 'https://example.com/aimyon.jpg',
    songCount: 42,
    followerCount: 8700,
    isFollowing: false,
  ),
  SearchArtist(
    id: 3,
    nameKor: '요네즈 켄시',
    nameEng: 'Kenshi Yonezu',
    nameJp: '米津玄師',
    profileUrl: 'https://example.com/yonezu.jpg',
    songCount: 38,
    followerCount: 15200,
    isFollowing: true,
  ),
  SearchArtist(
    id: 4,
    nameKor: '스피츠',
    nameEng: 'Spitz',
    nameJp: 'スピッツ',
    profileUrl: 'https://example.com/spitz.jpg',
    songCount: 120,
    followerCount: 9800,
    isFollowing: false,
  ),
];

/// Mock 게시글 검색 결과
final List<SearchPost> mockSearchPosts = [
  SearchPost(
    id: 1,
    content: 'YOASOBI 신곡 너무 좋아요! 밤을 달리다 들으면서 새벽까지 작업했어요.',
    authorNickname: '음악러버',
    authorProfileImage: 'https://example.com/user1.jpg',
    likeCount: 24,
    commentCount: 5,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  SearchPost(
    id: 2,
    content: '요아소비 라이브 갔다왔어요! 진짜 미쳤음... ikura 목소리 실화냐',
    authorNickname: 'JPOP팬',
    authorProfileImage: 'https://example.com/user2.jpg',
    likeCount: 156,
    commentCount: 32,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  SearchPost(
    id: 3,
    content: '아이돌 가사 해석 올려봅니다. 오시노 아이의 심리를 잘 표현한 것 같아요.',
    authorNickname: '가사해석러',
    authorProfileImage: 'https://example.com/user3.jpg',
    likeCount: 89,
    commentCount: 15,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  SearchPost(
    id: 4,
    content: '오늘 추천곡 군청인데 이 노래 진짜 좋음 ㅠㅠ 요아소비 최고',
    authorNickname: '일상공유',
    authorProfileImage: null,
    likeCount: 12,
    commentCount: 3,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

/// Mock 사용자 검색 결과
final List<SearchUser> mockSearchUsers = [
  SearchUser(
    id: 1,
    nickname: '요아소비팬',
    username: 'yoasobi_fan',
    profileImage: 'https://example.com/user_yoasobi.jpg',
    isFollowing: false,
  ),
  SearchUser(
    id: 2,
    nickname: 'YOASOBI_LOVER',
    username: 'yoasobi_lover',
    profileImage: 'https://example.com/user_lover.jpg',
    isFollowing: true,
  ),
  SearchUser(
    id: 3,
    nickname: '밤을달리다',
    username: 'yoru_ni_kakeru',
    profileImage: null,
    isFollowing: false,
  ),
];

/// Mock 최근 검색어
List<RecentSearch> mockRecentSearches = [
  RecentSearch(
    query: 'YOASOBI',
    searchedAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  RecentSearch(
    query: '밤을 달리다',
    searchedAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  RecentSearch(
    query: '아이묭',
    searchedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  RecentSearch(
    query: '요네즈 켄시',
    searchedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  RecentSearch(
    query: '스피츠',
    searchedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

/// 인기 검색어
final List<String> popularKeywords = [
  '요아소비',
  '아이돌',
  '스피츠',
  '우타다히카루',
  '아이묭',
];

/// 검색 실행 (Mock)
SearchResult searchMock(String query) {
  final lowerQuery = query.toLowerCase();

  // 노래 검색
  final songs = mockSearchSongs.where((song) {
    return song.titleKor.toLowerCase().contains(lowerQuery) ||
        song.titleJp.toLowerCase().contains(lowerQuery) ||
        song.artistName.toLowerCase().contains(lowerQuery);
  }).toList();

  // 아티스트 검색
  final artists = mockSearchArtists.where((artist) {
    return artist.nameKor.toLowerCase().contains(lowerQuery) ||
        artist.nameEng.toLowerCase().contains(lowerQuery) ||
        artist.nameJp.toLowerCase().contains(lowerQuery);
  }).toList();

  // 게시글 검색
  final posts = mockSearchPosts.where((post) {
    return post.content.toLowerCase().contains(lowerQuery);
  }).toList();

  // 사용자 검색
  final users = mockSearchUsers.where((user) {
    return user.nickname.toLowerCase().contains(lowerQuery) ||
        user.username.toLowerCase().contains(lowerQuery);
  }).toList();

  return SearchResult(
    songs: songs,
    artists: artists,
    posts: posts,
    users: users,
    totalSongs: songs.length,
    totalArtists: artists.length,
    totalPosts: posts.length,
    totalUsers: users.length,
  );
}

/// 최근 검색어 추가
void addRecentSearch(String query) {
  // 이미 있으면 제거
  mockRecentSearches.removeWhere((s) => s.query == query);

  // 맨 앞에 추가
  mockRecentSearches.insert(
    0,
    RecentSearch(query: query, searchedAt: DateTime.now()),
  );

  // 최대 10개 유지
  if (mockRecentSearches.length > 10) {
    mockRecentSearches = mockRecentSearches.sublist(0, 10);
  }
}

/// 최근 검색어 삭제
void removeRecentSearch(String query) {
  mockRecentSearches.removeWhere((s) => s.query == query);
}

/// 최근 검색어 전체 삭제
void clearRecentSearches() {
  mockRecentSearches.clear();
}

/// 아티스트 팔로우 토글
void toggleArtistFollow(int artistId) {
  final index = mockSearchArtists.indexWhere((a) => a.id == artistId);
  if (index != -1) {
    final artist = mockSearchArtists[index];
    mockSearchArtists[index] = artist.copyWith(
      isFollowing: !artist.isFollowing,
      followerCount: artist.isFollowing
          ? artist.followerCount - 1
          : artist.followerCount + 1,
    );
  }
}

/// 사용자 팔로우 토글
void toggleUserFollow(int userId) {
  final index = mockSearchUsers.indexWhere((u) => u.id == userId);
  if (index != -1) {
    final user = mockSearchUsers[index];
    mockSearchUsers[index] = user.copyWith(
      isFollowing: !user.isFollowing,
    );
  }
}
