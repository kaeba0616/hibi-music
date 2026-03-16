import 'package:hidi/features/artists/models/artist_model.dart';

/// 앨범 정보 모델
class Album {
  final int id;
  final String name;
  final String imageUrl;
  final DateTime releaseDate;

  Album({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.releaseDate,
  });

  Album.empty()
      : id = 0,
        name = '',
        imageUrl = '',
        releaseDate = DateTime.now();

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'releaseDate': releaseDate.toIso8601String(),
    };
  }
}

/// 가사 모델 (일본어 + 한글 번역)
class Lyrics {
  final String japanese;
  final String korean;

  Lyrics({
    required this.japanese,
    required this.korean,
  });

  Lyrics.empty()
      : japanese = '',
        korean = '';

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      japanese: json['japanese'] ?? '',
      korean: json['korean'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'japanese': japanese,
      'korean': korean,
    };
  }
}

/// 외부 스트리밍 링크 모델
class ExternalLinks {
  final String? spotify;
  final String? appleMusic;
  final String? youtube;

  ExternalLinks({
    this.spotify,
    this.appleMusic,
    this.youtube,
  });

  ExternalLinks.empty()
      : spotify = null,
        appleMusic = null,
        youtube = null;

  factory ExternalLinks.fromJson(Map<String, dynamic> json) {
    return ExternalLinks(
      spotify: json['spotify'],
      appleMusic: json['appleMusic'],
      youtube: json['youtube'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spotify': spotify,
      'appleMusic': appleMusic,
      'youtube': youtube,
    };
  }

  bool get hasAnyLink => spotify != null || appleMusic != null || youtube != null;
}

/// 연관곡 모델 (F15)
class RelatedSong {
  final int id;
  final String titleKor;
  final String titleJp;
  final Artist artist;
  final Album album;
  final String reason;

  RelatedSong({
    required this.id,
    required this.titleKor,
    required this.titleJp,
    required this.artist,
    required this.album,
    required this.reason,
  });

  factory RelatedSong.fromJson(Map<String, dynamic> json) {
    return RelatedSong(
      id: json['id'] ?? 0,
      titleKor: json['titleKor'] ?? '',
      titleJp: json['titleJp'] ?? '',
      artist: json['artist'] != null
          ? Artist.fromJson(json['artist'])
          : Artist.empty(),
      album: json['album'] != null ? Album.fromJson(json['album']) : Album.empty(),
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKor': titleKor,
      'titleJp': titleJp,
      'artist': artist.toJson(),
      'album': album.toJson(),
      'reason': reason,
    };
  }
}

/// 오늘의 노래 모델 (Daily Song)
class DailySong {
  final int id;
  final String titleKor;
  final String titleJp;
  final Artist artist;
  final Album album;
  final Lyrics lyrics;
  final String genre;
  final DateTime recommendedDate;
  final ExternalLinks externalLinks;
  final String? youtubeUrl;
  final List<RelatedSong> relatedSongs;
  final bool isLiked;
  final int likeCount;

  DailySong({
    required this.id,
    required this.titleKor,
    required this.titleJp,
    required this.artist,
    required this.album,
    required this.lyrics,
    required this.genre,
    required this.recommendedDate,
    required this.externalLinks,
    this.youtubeUrl,
    this.relatedSongs = const [],
    this.isLiked = false,
    this.likeCount = 0,
  });

  DailySong.empty()
      : id = 0,
        titleKor = '',
        titleJp = '',
        artist = Artist.empty(),
        album = Album.empty(),
        lyrics = Lyrics.empty(),
        genre = '',
        recommendedDate = DateTime.now(),
        externalLinks = ExternalLinks.empty(),
        youtubeUrl = null,
        relatedSongs = const [],
        isLiked = false,
        likeCount = 0;

  factory DailySong.fromJson(Map<String, dynamic> json) {
    return DailySong(
      id: json['id'] ?? 0,
      titleKor: json['titleKor'] ?? '',
      titleJp: json['titleJp'] ?? '',
      artist: json['artist'] != null
          ? Artist.fromJson(json['artist'])
          : Artist.empty(),
      album: json['album'] != null ? Album.fromJson(json['album']) : Album.empty(),
      lyrics:
          json['lyrics'] != null ? Lyrics.fromJson(json['lyrics']) : Lyrics.empty(),
      genre: json['genre'] ?? '',
      recommendedDate: json['recommendedDate'] != null
          ? DateTime.parse(json['recommendedDate'])
          : DateTime.now(),
      externalLinks: json['externalLinks'] != null
          ? ExternalLinks.fromJson(json['externalLinks'])
          : ExternalLinks.empty(),
      youtubeUrl: json['youtubeUrl'],
      relatedSongs: json['relatedSongs'] != null
          ? (json['relatedSongs'] as List)
              .map((e) => RelatedSong.fromJson(e))
              .toList()
          : [],
      isLiked: json['isLiked'] ?? false,
      likeCount: json['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKor': titleKor,
      'titleJp': titleJp,
      'artist': artist.toJson(),
      'album': album.toJson(),
      'lyrics': lyrics.toJson(),
      'genre': genre,
      'recommendedDate': recommendedDate.toIso8601String(),
      'externalLinks': externalLinks.toJson(),
      'youtubeUrl': youtubeUrl,
      'relatedSongs': relatedSongs.map((e) => e.toJson()).toList(),
      'isLiked': isLiked,
      'likeCount': likeCount,
    };
  }

  DailySong copyWith({
    int? id,
    String? titleKor,
    String? titleJp,
    Artist? artist,
    Album? album,
    Lyrics? lyrics,
    String? genre,
    DateTime? recommendedDate,
    ExternalLinks? externalLinks,
    String? youtubeUrl,
    List<RelatedSong>? relatedSongs,
    bool? isLiked,
    int? likeCount,
  }) {
    return DailySong(
      id: id ?? this.id,
      titleKor: titleKor ?? this.titleKor,
      titleJp: titleJp ?? this.titleJp,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      lyrics: lyrics ?? this.lyrics,
      genre: genre ?? this.genre,
      recommendedDate: recommendedDate ?? this.recommendedDate,
      externalLinks: externalLinks ?? this.externalLinks,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      relatedSongs: relatedSongs ?? this.relatedSongs,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}
