import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';

/// Mock 아티스트 데이터
final mockArtists = [
  Artist(
    id: 1,
    nameKor: '요아소비',
    nameEng: 'YOASOBI',
    nameJp: 'YOASOBI',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb72d0cbf3b1fe81a00d0e37f4',
    songCount: 15,
    isFollowing: true,
  ),
  Artist(
    id: 2,
    nameKor: '아이묭',
    nameEng: 'Aimyon',
    nameJp: 'あいみょん',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb8b2f4eb9e0a1c0e8fa587c3a',
    songCount: 12,
    isFollowing: false,
  ),
  Artist(
    id: 3,
    nameKor: '히게단디즘',
    nameEng: 'Official HIGE DANdism',
    nameJp: 'Official髭男dism',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb2c5beeb34e1c3f15b6e4a0c4',
    songCount: 20,
    isFollowing: true,
  ),
  Artist(
    id: 4,
    nameKor: '아도',
    nameEng: 'Ado',
    nameJp: 'Ado',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb04aa4c4d7d0c2e2b3b6ad1c9',
    songCount: 8,
    isFollowing: false,
  ),
  Artist(
    id: 5,
    nameKor: '이마세',
    nameEng: 'imase',
    nameJp: 'imase',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb5a9ab0a94e1f5c8a7a9b0d8f',
    songCount: 5,
    isFollowing: true,
  ),
];

/// Mock 앨범 데이터
final mockAlbums = [
  Album(
    id: 1,
    name: 'THE BOOK',
    imageUrl: 'assets/images/album_the_book.jpg',
    releaseDate: DateTime(2021, 1, 6),
  ),
  Album(
    id: 2,
    name: '瞬間的シックスセンス',
    imageUrl: 'assets/images/album_aimyon.jpg',
    releaseDate: DateTime(2019, 2, 13),
  ),
  Album(
    id: 3,
    name: 'Editorial',
    imageUrl: 'assets/images/album_higedan.jpg',
    releaseDate: DateTime(2021, 8, 18),
  ),
  Album(
    id: 4,
    name: '狂言',
    imageUrl: 'assets/images/album_ado.jpg',
    releaseDate: DateTime(2022, 1, 26),
  ),
  Album(
    id: 5,
    name: 'Have a nice day',
    imageUrl: 'assets/images/album_imase.jpg',
    releaseDate: DateTime(2022, 11, 16),
  ),
];

/// 추가 앨범 데이터 (캘린더 테스트용)
final _extraAlbums = [
  Album(
    id: 6,
    name: 'THE BOOK 2',
    imageUrl: 'assets/images/album_the_book2.jpg',
    releaseDate: DateTime(2021, 12, 1),
  ),
  Album(
    id: 7,
    name: '満月の夜なら',
    imageUrl: 'assets/images/album_aimyon2.jpg',
    releaseDate: DateTime(2018, 4, 25),
  ),
  Album(
    id: 8,
    name: 'Traveler',
    imageUrl: 'assets/images/album_higedan2.jpg',
    releaseDate: DateTime(2019, 10, 9),
  ),
  Album(
    id: 9,
    name: 'ウタの歌',
    imageUrl: 'assets/images/album_ado2.jpg',
    releaseDate: DateTime(2022, 9, 21),
  ),
  Album(
    id: 10,
    name: 'Utopia',
    imageUrl: 'assets/images/album_imase2.jpg',
    releaseDate: DateTime(2023, 5, 17),
  ),
];

/// Mock Daily Song 데이터 (현실적인 JPOP 곡 정보)
/// 캘린더 테스트를 위해 현재 월 여러 날짜에 배치
List<DailySong> get mockDailySongs {
  final now = DateTime.now();
  return [
    // 오늘
    DailySong(
      id: 1,
      titleKor: '밤을 달리다',
      titleJp: '夜に駆ける',
      artist: mockArtists[0], // YOASOBI
      album: mockAlbums[0],
      lyrics: Lyrics(
        japanese: '''沈むように溶けてゆくように
二人だけの空が広がる夜に

「さよなら」だけだった
その一言で全てが分かった
日が沈み出した空と君の姿
フェンス越しに重なっていた

初めて会った日から
僕の心の全てを奪った
どこか儚い空気を纏う君は
寂しい目をしてたんだ''',
        korean: '''가라앉듯이 녹아가듯이
둘만의 하늘이 펼쳐지는 밤에

"안녕"이란 말뿐이었어
그 한마디로 전부 알 수 있었어
해가 지기 시작한 하늘과 너의 모습
펜스 너머로 겹쳐 있었어

처음 만난 날부터
내 마음의 전부를 빼앗았어
어딘가 덧없는 분위기를 두른 너는
외로운 눈을 하고 있었어''',
      ),
      genre: 'J-Pop',
      recommendedDate: DateTime(now.year, now.month, now.day),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/2BHj5zQC9jVq1ZQ8PK8Q2j',
        appleMusic: 'https://music.apple.com/jp/album/yoru-ni-kakeru/1498211271?i=1498211282',
        youtube: 'https://www.youtube.com/watch?v=x8VYWazR5mE',
      ),
      isLiked: false,
      likeCount: 1542,
    ),
    // 2일 전
    DailySong(
      id: 2,
      titleKor: '마리골드',
      titleJp: 'マリーゴールド',
      artist: mockArtists[1], // Aimyon
      album: mockAlbums[1],
      lyrics: Lyrics(
        japanese: '''風の強さがちょっと
心を揺さぶりすぎて
真っ直ぐ歩けないみたいだ
あの日僕らを横目に
車は走ってく
二度と届かない
あの夏の光''',
        korean: '''바람의 세기가 조금
마음을 너무 흔들어서
똑바로 걸을 수 없는 것 같아
그날 우리를 곁눈질하며
차는 달려가
다시는 닿지 않을
그 여름의 빛''',
      ),
      genre: 'J-Pop / Folk',
      recommendedDate: DateTime(now.year, now.month, now.day - 2),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/0bMfXOlOpLy3rZ6xBnT7nG',
        appleMusic: 'https://music.apple.com/jp/album/marigold/1437952218?i=1437952224',
        youtube: 'https://www.youtube.com/watch?v=0xSiBpUdW4E',
      ),
      isLiked: true,
      likeCount: 2301,
    ),
    // 5일 전
    DailySong(
      id: 3,
      titleKor: 'Pretender',
      titleJp: 'Pretender',
      artist: mockArtists[2], // Official髭男dism
      album: mockAlbums[2],
      lyrics: Lyrics(
        japanese: '''君とのラブストーリー
それは予想通り
いざ始まればひとり芝居だ
ずっとそばにいたって
結局ただの観客だ

感情のないアイムソーリー
それはいつも通り
争いもなく終わる恋なんだ
君の運命の人は僕じゃない''',
        korean: '''너와의 러브스토리
그건 예상대로
막상 시작되면 혼자 연기야
계속 곁에 있어도
결국 그저 관객일 뿐

감정 없는 아임 쏘리
그건 언제나 그래
다툼도 없이 끝나는 사랑이야
너의 운명의 사람은 내가 아냐''',
      ),
      genre: 'J-Pop / Rock',
      recommendedDate: DateTime(now.year, now.month, now.day - 5),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/2vC0pGKJ9KcM6v9V8KWPCd',
        appleMusic: 'https://music.apple.com/jp/album/pretender/1460107820?i=1460108095',
        youtube: 'https://www.youtube.com/watch?v=TQ8WlA2GXbk',
      ),
      isLiked: false,
      likeCount: 3127,
    ),
    // 8일 전
    DailySong(
      id: 4,
      titleKor: '춤추다',
      titleJp: '踊',
      artist: mockArtists[3], // Ado
      album: mockAlbums[3],
      lyrics: Lyrics(
        japanese: '''踊れや踊れや 夜が来る前に
踊れや踊れや 鬼が来る前に
踊れや踊れや 火が消える前に
踊れや踊れや あんたも私も

パッと咲いてパッと散ってしまう花みたいに
ずっと変わらないものなんてないんだから''',
        korean: '''춤춰라 춤춰라 밤이 오기 전에
춤춰라 춤춰라 도깨비가 오기 전에
춤춰라 춤춰라 불이 꺼지기 전에
춤춰라 춤춰라 너도 나도

확 피었다가 확 져버리는 꽃처럼
계속 변하지 않는 것 따윈 없으니까''',
      ),
      genre: 'J-Pop / Electronic',
      recommendedDate: DateTime(now.year, now.month, now.day - 8),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/7DFNE7NO8gVsZF7ODMQ7sg',
        youtube: 'https://www.youtube.com/watch?v=lsDZ0A0DxFY',
      ),
      isLiked: true,
      likeCount: 4521,
    ),
    // 12일 전
    DailySong(
      id: 5,
      titleKor: 'Night Dancer',
      titleJp: 'NIGHT DANCER',
      artist: mockArtists[4], // imase
      album: mockAlbums[4],
      lyrics: Lyrics(
        japanese: '''今夜は帰さない
ねぇ ダーリン
踊ろうぜ もっと
ねぇ ダーリン

分からない未来に
ねぇ ダーリン
きっとさ 何か
ねぇ ダーリン''',
        korean: '''오늘 밤은 안 보내줘
이봐 달링
춤추자 더
이봐 달링

모르는 미래에
이봐 달링
분명 뭔가
이봐 달링''',
      ),
      genre: 'J-Pop / R&B',
      recommendedDate: DateTime(now.year, now.month, now.day - 12),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/3Uyt0WO3wOopnUBCe9BaXl',
        appleMusic: 'https://music.apple.com/jp/album/night-dancer/1622126256?i=1622126257',
        youtube: 'https://www.youtube.com/watch?v=lSWq_gL5hnk',
      ),
      isLiked: false,
      likeCount: 2890,
    ),
    // 15일 전
    DailySong(
      id: 6,
      titleKor: '군청',
      titleJp: '群青',
      artist: mockArtists[0], // YOASOBI
      album: _extraAlbums[0],
      lyrics: Lyrics(
        japanese: '''嗚呼、いつもの様に
過ぎる日々にあくびが出る
さんざめく夜、越え
今日も渡る''',
        korean: '''아아, 평소처럼
지나가는 나날에 하품이 나와
떠들썩한 밤을 넘어
오늘도 건너가''',
      ),
      genre: 'J-Pop',
      recommendedDate: DateTime(now.year, now.month, now.day - 15),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/4ZtFanR9U6ndgddUvNcjcG',
        youtube: 'https://www.youtube.com/watch?v=Y4nEEZwckuU',
      ),
      isLiked: true,
      likeCount: 5234,
    ),
    // 18일 전
    DailySong(
      id: 7,
      titleKor: '너의 이야기',
      titleJp: '君はロックを聴かない',
      artist: mockArtists[1], // Aimyon
      album: _extraAlbums[1],
      lyrics: Lyrics(
        japanese: '''少し寂しそうな君に
ロック聞かせてあげたくて
タイトルとか関係なく
今の気持ち歌にした''',
        korean: '''조금 쓸쓸해 보이는 너에게
록을 들려주고 싶어서
제목 같은 건 상관없이
지금 기분을 노래로 했어''',
      ),
      genre: 'J-Pop / Rock',
      recommendedDate: DateTime(now.year, now.month, now.day - 18),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/2aNJRRCWQpIJB5WXD35yWV',
        youtube: 'https://www.youtube.com/watch?v=ARwVe1MYAUA',
      ),
      isLiked: false,
      likeCount: 3890,
    ),
    // 22일 전
    DailySong(
      id: 8,
      titleKor: '이스터데이',
      titleJp: 'Yesterday',
      artist: mockArtists[2], // Official髭男dism
      album: _extraAlbums[2],
      lyrics: Lyrics(
        japanese: '''言葉にできなかった
あの日の夕暮れ
君が背を向けた時
僕は立ち尽くした''',
        korean: '''말로 할 수 없었던
그날의 저녁노을
네가 등을 돌렸을 때
나는 멍하니 서 있었어''',
      ),
      genre: 'J-Pop / Ballad',
      recommendedDate: DateTime(now.year, now.month, now.day - 22),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/5xrtzzzikpG3BLbo4q1Yul',
        youtube: 'https://www.youtube.com/watch?v=dBcVNcA10zw',
      ),
      isLiked: true,
      likeCount: 4567,
    ),
    // 25일 전
    DailySong(
      id: 9,
      titleKor: '새로운 세계',
      titleJp: '新時代',
      artist: mockArtists[3], // Ado
      album: _extraAlbums[3],
      lyrics: Lyrics(
        japanese: '''新時代はこの未来だ
世界中全部変えてしまえばいい
怖いもんなんてない
怯まない 退かない 媚びない''',
        korean: '''새 시대는 이 미래야
세상 전부를 바꿔버리면 돼
무서운 것 따윈 없어
움츠리지 않아 물러서지 않아 아첨하지 않아''',
      ),
      genre: 'J-Pop / Electronic',
      recommendedDate: DateTime(now.year, now.month, now.day - 25),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/0fYTulR3WwPKEGxyX5l3NK',
        youtube: 'https://www.youtube.com/watch?v=1FliVTcX8bQ',
      ),
      isLiked: false,
      likeCount: 8901,
    ),
    // 28일 전
    DailySong(
      id: 10,
      titleKor: '해피',
      titleJp: 'Happy',
      artist: mockArtists[4], // imase
      album: _extraAlbums[4],
      lyrics: Lyrics(
        japanese: '''Happy になりたいな
君と一緒なら
どこへでも行けるさ
僕らの世界へ''',
        korean: '''행복해지고 싶어
너와 함께라면
어디든 갈 수 있어
우리만의 세계로''',
      ),
      genre: 'J-Pop / City Pop',
      recommendedDate: DateTime(now.year, now.month, now.day - 28),
      externalLinks: ExternalLinks(
        spotify: 'https://open.spotify.com/track/6TjuE4p0xaSwq1qF1OjxNE',
        youtube: 'https://www.youtube.com/watch?v=abc123',
      ),
      isLiked: true,
      likeCount: 2345,
    ),
  ];
}

/// 오늘의 노래 가져오기 (Mock)
DailySong? getMockTodaySong() {
  final today = DateTime.now();
  try {
    return mockDailySongs.firstWhere(
      (song) =>
          song.recommendedDate.year == today.year &&
          song.recommendedDate.month == today.month &&
          song.recommendedDate.day == today.day,
    );
  } catch (e) {
    // 오늘 날짜의 곡이 없으면 첫 번째 곡 반환 (데모용)
    return mockDailySongs.isNotEmpty ? mockDailySongs.first : null;
  }
}

/// 날짜별 노래 가져오기 (Mock)
DailySong? getMockSongByDate(DateTime date) {
  try {
    return mockDailySongs.firstWhere(
      (song) =>
          song.recommendedDate.year == date.year &&
          song.recommendedDate.month == date.month &&
          song.recommendedDate.day == date.day,
    );
  } catch (e) {
    return null;
  }
}

/// ID로 노래 가져오기 (Mock)
DailySong? getMockSongById(int id) {
  try {
    return mockDailySongs.firstWhere((song) => song.id == id);
  } catch (e) {
    return null;
  }
}

/// 월별 노래 목록 가져오기 (Mock)
List<DailySong> getMockSongsByMonth(int year, int month) {
  return mockDailySongs
      .where((song) =>
          song.recommendedDate.year == year &&
          song.recommendedDate.month == month)
      .toList();
}
