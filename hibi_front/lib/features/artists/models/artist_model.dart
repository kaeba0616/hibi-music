/// 아티스트 모델
class Artist {
  final int id;
  final String nameKor;
  final String nameEng;
  final String nameJp;
  final String? profileImage;
  final String? description;
  final int followerCount;
  final int songCount;
  final bool isFollowing;

  Artist({
    required this.id,
    required this.nameKor,
    required this.nameEng,
    required this.nameJp,
    this.profileImage,
    this.description,
    this.followerCount = 0,
    this.songCount = 0,
    this.isFollowing = false,
  });

  Artist.empty()
      : id = 0,
        nameKor = '히비',
        nameEng = 'Hibi',
        nameJp = '日々',
        profileImage = null,
        description = null,
        followerCount = 0,
        songCount = 0,
        isFollowing = false;

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] ?? 0,
      nameKor: json['nameKor'] ?? '',
      nameEng: json['nameEng'] ?? '',
      nameJp: json['nameJp'] ?? '',
      profileImage: json['profileImage'],
      description: json['description'],
      followerCount: json['followerCount'] ?? 0,
      songCount: json['songCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameKor': nameKor,
      'nameEng': nameEng,
      'nameJp': nameJp,
      'profileImage': profileImage,
      'description': description,
      'followerCount': followerCount,
      'songCount': songCount,
      'isFollowing': isFollowing,
    };
  }

  Artist copyWith({
    int? id,
    String? nameKor,
    String? nameEng,
    String? nameJp,
    String? profileImage,
    String? description,
    int? followerCount,
    int? songCount,
    bool? isFollowing,
  }) {
    return Artist(
      id: id ?? this.id,
      nameKor: nameKor ?? this.nameKor,
      nameEng: nameEng ?? this.nameEng,
      nameJp: nameJp ?? this.nameJp,
      profileImage: profileImage ?? this.profileImage,
      description: description ?? this.description,
      followerCount: followerCount ?? this.followerCount,
      songCount: songCount ?? this.songCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
