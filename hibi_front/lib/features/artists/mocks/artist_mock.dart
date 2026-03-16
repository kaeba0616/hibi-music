import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/artists/models/artist_detail_model.dart';
import 'package:hidi/features/artists/models/artist_song_model.dart';

/// Mock 아티스트 데이터 (현실적인 JPOP 아티스트)
final List<Artist> mockArtists = [
  Artist(
    id: 1,
    nameKor: '요아소비',
    nameEng: 'YOASOBI',
    nameJp: 'YOASOBI',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb72d0cbf3b1fe81a00d0e37f4',
    description: 'Ayase와 ikura로 구성된 일본의 음악 유닛. 소설을 음악으로 표현하는 독특한 콘셉트로 활동 중이며, "밤을 달리다(夜に駆ける)"로 폭발적인 인기를 얻었습니다.',
    followerCount: 15234,
    songCount: 15,
    isFollowing: true,
  ),
  Artist(
    id: 2,
    nameKor: '아이묭',
    nameEng: 'Aimyon',
    nameJp: 'あいみょん',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb8b2f4eb9e0a1c0e8fa587c3a',
    description: '시마네현 출신의 싱어송라이터. 솔직한 가사와 따뜻한 멜로디로 사랑받고 있으며, "마리골드", "하루노히"등의 히트곡을 보유하고 있습니다.',
    followerCount: 12456,
    songCount: 12,
    isFollowing: false,
  ),
  Artist(
    id: 3,
    nameKor: '히게단디즘',
    nameEng: 'Official HIGE DANdism',
    nameJp: 'Official髭男dism',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb2c5beeb34e1c3f15b6e4a0c4',
    description: '2012년에 결성된 4인조 피아노 팝 밴드. "Pretender", "Cry Baby"등 드라마 주제가로 유명하며, 섬세한 보컬과 피아노 사운드가 특징입니다.',
    followerCount: 18902,
    songCount: 20,
    isFollowing: true,
  ),
  Artist(
    id: 4,
    nameKor: '아도',
    nameEng: 'Ado',
    nameJp: 'Ado',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb04aa4c4d7d0c2e2b3b6ad1c9',
    description: '2002년생 여성 가수. 강렬한 보컬과 독특한 음색으로 주목받으며, "うっせぇわ(닥쳐)"로 데뷔하여 큰 인기를 얻었습니다. 원피스 필름 레드 OST로 세계적인 인지도를 얻었습니다.',
    followerCount: 25678,
    songCount: 8,
    isFollowing: false,
  ),
  Artist(
    id: 5,
    nameKor: '이마세',
    nameEng: 'imase',
    nameJp: 'imase',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb5a9ab0a94e1f5c8a7a9b0d8f',
    description: '2002년생 남성 싱어송라이터. TikTok에서 "NIGHT DANCER"가 바이럴 되며 글로벌하게 알려졌습니다. 부드러운 R&B 사운드가 특징입니다.',
    followerCount: 8901,
    songCount: 5,
    isFollowing: true,
  ),
  Artist(
    id: 6,
    nameKor: 'RADWIMPS',
    nameEng: 'RADWIMPS',
    nameJp: 'RADWIMPS',
    profileImage: 'https://i.scdn.co/image/ab6761610000e5eb8f9c7f8f3b5f5d7a4a5b6c7d',
    description: '2001년에 결성된 록 밴드. 신카이 마코토 감독의 "너의 이름은", "날씨의 아이" 등의 OST를 담당하여 세계적인 인지도를 얻었습니다.',
    followerCount: 32145,
    songCount: 18,
    isFollowing: false,
  ),
];

/// Mock 아티스트별 노래 데이터
final Map<int, List<ArtistSong>> mockArtistSongs = {
  1: [
    // YOASOBI
    ArtistSong(
      id: 1,
      titleKor: '밤을 달리다',
      titleJp: '夜に駆ける',
      albumName: 'THE BOOK',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273cd22cba3f3a2e3a7db6f5d8a',
      releaseYear: 2020,
    ),
    ArtistSong(
      id: 2,
      titleKor: '아이돌',
      titleJp: 'アイドル',
      albumName: 'THE BOOK 3',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273a1b2c3d4e5f6a7b8c9d0e1f2',
      releaseYear: 2023,
    ),
    ArtistSong(
      id: 3,
      titleKor: '축복',
      titleJp: '祝福',
      albumName: 'THE BOOK 2',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273b2c3d4e5f6a7b8c9d0e1f2a3',
      releaseYear: 2022,
    ),
  ],
  2: [
    // Aimyon
    ArtistSong(
      id: 4,
      titleKor: '마리골드',
      titleJp: 'マリーゴールド',
      albumName: '瞬間的シックスセンス',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273c3d4e5f6a7b8c9d0e1f2a3b4',
      releaseYear: 2018,
    ),
    ArtistSong(
      id: 5,
      titleKor: '하루노히',
      titleJp: 'ハルノヒ',
      albumName: '瞬間的シックスセンス',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273c3d4e5f6a7b8c9d0e1f2a3b4',
      releaseYear: 2019,
    ),
  ],
  3: [
    // Official髭男dism
    ArtistSong(
      id: 6,
      titleKor: 'Pretender',
      titleJp: 'Pretender',
      albumName: 'Traveler',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273d4e5f6a7b8c9d0e1f2a3b4c5',
      releaseYear: 2019,
    ),
    ArtistSong(
      id: 7,
      titleKor: 'Cry Baby',
      titleJp: 'Cry Baby',
      albumName: 'Editorial',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273e5f6a7b8c9d0e1f2a3b4c5d6',
      releaseYear: 2021,
    ),
    ArtistSong(
      id: 8,
      titleKor: 'Subtitle',
      titleJp: 'Subtitle',
      albumName: 'Editorial',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273e5f6a7b8c9d0e1f2a3b4c5d6',
      releaseYear: 2022,
    ),
  ],
  4: [
    // Ado
    ArtistSong(
      id: 9,
      titleKor: '춤추다',
      titleJp: '踊',
      albumName: '狂言',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273f6a7b8c9d0e1f2a3b4c5d6e7',
      releaseYear: 2022,
    ),
    ArtistSong(
      id: 10,
      titleKor: '새로운 세계',
      titleJp: '新時代',
      albumName: 'ウタの歌',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273a7b8c9d0e1f2a3b4c5d6e7f8',
      releaseYear: 2022,
    ),
  ],
  5: [
    // imase
    ArtistSong(
      id: 11,
      titleKor: 'Night Dancer',
      titleJp: 'NIGHT DANCER',
      albumName: 'Have a nice day',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273b8c9d0e1f2a3b4c5d6e7f8a9',
      releaseYear: 2022,
    ),
  ],
  6: [
    // RADWIMPS
    ArtistSong(
      id: 12,
      titleKor: '전전전세',
      titleJp: '前前前世',
      albumName: '君の名は。',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273c9d0e1f2a3b4c5d6e7f8a9b0',
      releaseYear: 2016,
    ),
    ArtistSong(
      id: 13,
      titleKor: '그랑드 이스케이프',
      titleJp: 'グランドエスケープ',
      albumName: '天気の子',
      albumImageUrl: 'https://i.scdn.co/image/ab67616d0000b273d0e1f2a3b4c5d6e7f8a9b0c1',
      releaseYear: 2019,
    ),
  ],
};

/// 아티스트 목록 가져오기 (Mock)
List<Artist> getMockArtists({bool? followingOnly, String? searchQuery}) {
  var result = mockArtists;

  // 팔로우 필터
  if (followingOnly == true) {
    result = result.where((a) => a.isFollowing).toList();
  }

  // 검색 필터
  if (searchQuery != null && searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    result = result.where((a) {
      return a.nameKor.toLowerCase().contains(query) ||
          a.nameEng.toLowerCase().contains(query) ||
          a.nameJp.toLowerCase().contains(query);
    }).toList();
  }

  return result;
}

/// 아티스트 상세 가져오기 (Mock)
ArtistDetail? getMockArtistDetail(int artistId) {
  try {
    final artist = mockArtists.firstWhere((a) => a.id == artistId);
    final songs = mockArtistSongs[artistId] ?? [];
    return ArtistDetail(artist: artist, songs: songs);
  } catch (e) {
    return null;
  }
}

/// 팔로우 토글 (Mock) - 로컬 상태 변경
Artist toggleMockFollow(int artistId) {
  final index = mockArtists.indexWhere((a) => a.id == artistId);
  if (index != -1) {
    final artist = mockArtists[index];
    final updatedArtist = artist.copyWith(
      isFollowing: !artist.isFollowing,
      followerCount: artist.isFollowing
          ? artist.followerCount - 1
          : artist.followerCount + 1,
    );
    mockArtists[index] = updatedArtist;
    return updatedArtist;
  }
  return Artist.empty();
}
