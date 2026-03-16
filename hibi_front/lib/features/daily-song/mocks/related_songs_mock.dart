import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/mocks/daily_song_mock.dart';

/// Mock 연관곡 데이터 (F15)
List<RelatedSong> mockRelatedSongsForSong1 = [
  RelatedSong(
    id: 6,
    titleKor: '아이돌',
    titleJp: 'アイドル',
    artist: mockArtists[0], // YOASOBI
    album: Album(
      id: 6,
      name: 'THE BOOK 3',
      imageUrl: 'assets/images/album_the_book2.jpg',
      releaseDate: DateTime(2023, 6, 21),
    ),
    reason: '같은 아티스트의 곡',
  ),
  RelatedSong(
    id: 3,
    titleKor: '프리텐더',
    titleJp: 'Pretender',
    artist: mockArtists[2], // 히게단디즘
    album: Album(
      id: 3,
      name: 'Traveler',
      imageUrl: 'assets/images/album_higedan.jpg',
      releaseDate: DateTime(2019, 10, 9),
    ),
    reason: '장르가 비슷한 곡',
  ),
  RelatedSong(
    id: 5,
    titleKor: 'NIGHT DANCER',
    titleJp: 'NIGHT DANCER',
    artist: mockArtists[4], // 이마세
    album: Album(
      id: 5,
      name: 'Have a nice day',
      imageUrl: 'assets/images/album_imase.jpg',
      releaseDate: DateTime(2022, 11, 16),
    ),
    reason: '분위기가 유사한 곡',
  ),
];

/// Mock 좋아요 곡 목록 데이터 (F15 - AC-F2-7)
List<DailySong> get mockLikedSongs {
  final now = DateTime.now();
  return [
    DailySong(
      id: 1,
      titleKor: '밤을 달리다',
      titleJp: '夜に駆ける',
      artist: mockArtists[0],
      album: mockAlbums[0],
      lyrics: Lyrics.empty(),
      genre: 'J-Pop',
      recommendedDate: DateTime(now.year, now.month, now.day),
      externalLinks: ExternalLinks.empty(),
      youtubeUrl: 'https://www.youtube.com/watch?v=x8VYWazR5mE',
      isLiked: true,
      likeCount: 1542,
    ),
    DailySong(
      id: 3,
      titleKor: '프리텐더',
      titleJp: 'Pretender',
      artist: mockArtists[2],
      album: mockAlbums[2],
      lyrics: Lyrics.empty(),
      genre: 'J-Pop / Rock',
      recommendedDate: DateTime(now.year, now.month, now.day - 4),
      externalLinks: ExternalLinks.empty(),
      youtubeUrl: 'https://www.youtube.com/watch?v=TQ8WlA2GnHQ',
      isLiked: true,
      likeCount: 2301,
    ),
    DailySong(
      id: 4,
      titleKor: '새벽녘',
      titleJp: 'うっせぇわ',
      artist: mockArtists[3],
      album: mockAlbums[3],
      lyrics: Lyrics.empty(),
      genre: 'J-Pop / Rock',
      recommendedDate: DateTime(now.year, now.month, now.day - 6),
      externalLinks: ExternalLinks.empty(),
      isLiked: true,
      likeCount: 3120,
    ),
    DailySong(
      id: 5,
      titleKor: 'NIGHT DANCER',
      titleJp: 'NIGHT DANCER',
      artist: mockArtists[4],
      album: mockAlbums[4],
      lyrics: Lyrics.empty(),
      genre: 'J-Pop / City Pop',
      recommendedDate: DateTime(now.year, now.month, now.day - 8),
      externalLinks: ExternalLinks.empty(),
      youtubeUrl: 'https://www.youtube.com/watch?v=ZGuvPD1JQTA',
      isLiked: true,
      likeCount: 891,
    ),
  ];
}

/// Mock 좋아요 곡 빈 리스트
List<DailySong> get emptyLikedSongs => [];

/// Mock 좋아요 곡 조회 (딜레이 포함)
Future<List<DailySong>> getMockLikedSongsWithDelay() async {
  await Future.delayed(const Duration(milliseconds: 500));
  return mockLikedSongs;
}

/// Mock 연관곡 조회 (딜레이 포함)
Future<List<RelatedSong>> getMockRelatedSongsWithDelay(int songId) async {
  await Future.delayed(const Duration(milliseconds: 300));
  if (songId == 1) return mockRelatedSongsForSong1;
  return [];
}
