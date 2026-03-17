/// F18 Admin Enhancement - Mock Data

import '../models/admin_song_models.dart';

/// Mock 아티스트 목록 (자동완성용)
final List<ArtistSuggestion> mockArtistSuggestions = [
  const ArtistSuggestion(id: 1, nameKor: '요아소비', nameEng: 'YOASOBI', nameJp: 'YOASOBI'),
  const ArtistSuggestion(id: 2, nameKor: '아이묭', nameEng: 'Aimyon', nameJp: 'あいみょん'),
  const ArtistSuggestion(id: 3, nameKor: '히게단', nameEng: 'Official HIGE DANdism', nameJp: 'Official髭男dism'),
  const ArtistSuggestion(id: 4, nameKor: '아도', nameEng: 'Ado', nameJp: 'Ado'),
  const ArtistSuggestion(id: 5, nameKor: '미세스 그린 애플', nameEng: 'Mrs. GREEN APPLE', nameJp: 'Mrs. GREEN APPLE'),
  const ArtistSuggestion(id: 6, nameKor: '후지이 카제', nameEng: 'Fujii Kaze', nameJp: '藤井風'),
  const ArtistSuggestion(id: 7, nameKor: '이마세', nameEng: 'Imase', nameJp: 'imase'),
  const ArtistSuggestion(id: 8, nameKor: '킹 누', nameEng: 'King Gnu', nameJp: 'King Gnu'),
];

/// Mock 곡 검색 결과 (연관곡 추가용)
final List<SongSearchResult> mockSongSearchResults = [
  const SongSearchResult(id: 1, titleKor: '밤을 달리다', titleJp: '夜に駆ける', artistName: '요아소비'),
  const SongSearchResult(id: 2, titleKor: '마리골드', titleJp: 'マリーゴールド', artistName: '아이묭'),
  const SongSearchResult(id: 3, titleKor: '프리텐더', titleJp: 'Pretender', artistName: '히게단'),
  const SongSearchResult(id: 4, titleKor: '신시대', titleJp: '新時代', artistName: '아도'),
  const SongSearchResult(id: 5, titleKor: '콜럼버스', titleJp: 'コロンブス', artistName: '미세스 그린 애플'),
  const SongSearchResult(id: 6, titleKor: '아이돌', titleJp: 'アイドル', artistName: '요아소비'),
  const SongSearchResult(id: 7, titleKor: '타비지', titleJp: '旅路', artistName: '후지이 카제'),
  const SongSearchResult(id: 8, titleKor: 'NIGHT DANCER', titleJp: 'NIGHT DANCER', artistName: '이마세'),
];

/// Mock 예약 게시 목록
final List<ScheduledSongItem> mockScheduledSongs = [
  ScheduledSongItem(
    id: 1,
    songId: 1,
    songTitle: '밤을 달리다',
    artistName: '요아소비',
    scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 9)),
    status: ScheduleStatus.pending,
    isSongComplete: true,
  ),
  ScheduledSongItem(
    id: 2,
    songId: 4,
    songTitle: '신시대',
    artistName: '아도',
    scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 9)),
    status: ScheduleStatus.pending,
    isSongComplete: true,
  ),
  ScheduledSongItem(
    id: 3,
    songId: 2,
    songTitle: '마리골드',
    artistName: '아이묭',
    scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
    status: ScheduleStatus.published,
    isSongComplete: true,
  ),
  ScheduledSongItem(
    id: 4,
    songId: 3,
    songTitle: '프리텐더',
    artistName: '히게단',
    scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
    status: ScheduleStatus.published,
    isSongComplete: true,
  ),
];

/// Mock 관리자 댓글 목록
final List<AdminCommentItem> mockAdminComments = [
  AdminCommentItem(
    id: 1,
    feedPostId: 10,
    authorNickname: 'music_lover',
    authorId: 1,
    content: '오늘 추천곡 정말 좋아요! 요아소비 최고!',
    likeCount: 15,
    reportCount: 0,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  AdminCommentItem(
    id: 2,
    feedPostId: 10,
    authorNickname: 'jpop_fan99',
    authorId: 2,
    content: '이 곡은 좀 별로인 것 같아요... 다른 곡 추천해주세요',
    likeCount: 3,
    reportCount: 0,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  AdminCommentItem(
    id: 3,
    feedPostId: 12,
    authorNickname: 'spammer123',
    authorId: 50,
    content: '[광고] 무료 음악 다운로드 사이트 바로가기 >>>',
    likeCount: 0,
    reportCount: 5,
    isFiltered: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  AdminCommentItem(
    id: 4,
    feedPostId: 15,
    authorNickname: 'new_user',
    authorId: 30,
    content: '처음 들어봤는데 좋네요! 아이묭 다른 곡도 추천해주세요',
    likeCount: 8,
    reportCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AdminCommentItem(
    id: 5,
    feedPostId: 15,
    authorNickname: 'bad_user',
    authorId: 99,
    content: '부적절한 내용의 댓글입니다.',
    likeCount: 0,
    reportCount: 3,
    isFiltered: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  AdminCommentItem(
    id: 6,
    feedPostId: 18,
    authorNickname: 'daily_listener',
    authorId: 15,
    content: '매일 hibi 추천곡 듣는 게 하루의 낙이에요 :)',
    likeCount: 22,
    reportCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  AdminCommentItem(
    id: 7,
    feedPostId: 20,
    authorNickname: 'singer_fan',
    authorId: 25,
    content: '가사가 정말 아름다워요. 번역도 잘 되어있네요.',
    likeCount: 11,
    reportCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
  ),
  AdminCommentItem(
    id: 8,
    feedPostId: 22,
    authorNickname: 'critic_user',
    authorId: 40,
    content: '이번 주 추천곡이 전체적으로 마음에 들어요. 큐레이션 최고!',
    likeCount: 7,
    reportCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
