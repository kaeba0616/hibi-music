class Song {
  final int id;
  final int artistId;
  final String titleKor;
  final String titleEng;
  final String titleJp;

  Song({
    required this.id,
    required this.artistId,
    required this.titleKor,
    required this.titleEng,
    required this.titleJp,
  });

  Song.empty()
    : id = 0,
      artistId = 0,
      titleKor = "히비",
      titleEng = "hibi",
      titleJp = "日々";
  Song copyWith({
    int? id,
    int? artistId,
    String? titleKor,
    String? titleEng,
    String? titleJp,
  }) {
    return Song(
      id: id ?? this.id,
      artistId: artistId ?? this.artistId,
      titleKor: titleKor ?? this.titleKor,
      titleEng: titleEng ?? this.titleEng,
      titleJp: titleJp ?? this.titleJp,
    );
  }

  Song.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      artistId = json['artistId'],
      titleKor = json['titleKor'],
      titleEng = json['titleEng'],
      titleJp = json['titleJp'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artistId': artistId,
      'titleKor': titleKor,
      'titleEng': titleEng,
      'titleJp': titleJp,
    };
  }
}
