import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/artists/models/artist_song_model.dart';

/// 아티스트 상세 정보 모델
class ArtistDetail {
  final Artist artist;
  final List<ArtistSong> songs;

  ArtistDetail({
    required this.artist,
    required this.songs,
  });

  factory ArtistDetail.fromJson(Map<String, dynamic> json) {
    return ArtistDetail(
      artist: Artist.fromJson(json),
      songs: (json['songs'] as List<dynamic>?)
              ?.map((s) => ArtistSong.fromJson(s))
              .toList() ??
          [],
    );
  }

  ArtistDetail copyWith({
    Artist? artist,
    List<ArtistSong>? songs,
  }) {
    return ArtistDetail(
      artist: artist ?? this.artist,
      songs: songs ?? this.songs,
    );
  }
}
