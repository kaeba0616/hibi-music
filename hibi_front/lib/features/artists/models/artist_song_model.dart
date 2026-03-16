/// 아티스트 상세 화면에서 보여줄 노래 정보 (간략화)
class ArtistSong {
  final int id;
  final String titleKor;
  final String titleJp;
  final String albumName;
  final String? albumImageUrl;
  final int releaseYear;

  ArtistSong({
    required this.id,
    required this.titleKor,
    required this.titleJp,
    required this.albumName,
    this.albumImageUrl,
    required this.releaseYear,
  });

  factory ArtistSong.fromJson(Map<String, dynamic> json) {
    return ArtistSong(
      id: json['id'] ?? 0,
      titleKor: json['titleKor'] ?? '',
      titleJp: json['titleJp'] ?? '',
      albumName: json['albumName'] ?? '',
      albumImageUrl: json['albumImageUrl'],
      releaseYear: json['releaseYear'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKor': titleKor,
      'titleJp': titleJp,
      'albumName': albumName,
      'albumImageUrl': albumImageUrl,
      'releaseYear': releaseYear,
    };
  }
}
