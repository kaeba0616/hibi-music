/// F18 Admin Enhancement - Song Registration & Scheduling Models

/// 관리자 곡 등록 요청
class AdminSongCreateRequest {
  final String titleKor;
  final String? titleEng;
  final String titleJp;
  final int artistId;
  final String? story;
  final String? lyricsJp;
  final String? lyricsKr;
  final String? youtubeUrl;
  final List<RelatedSongInput> relatedSongs;

  const AdminSongCreateRequest({
    required this.titleKor,
    this.titleEng,
    required this.titleJp,
    required this.artistId,
    this.story,
    this.lyricsJp,
    this.lyricsKr,
    this.youtubeUrl,
    this.relatedSongs = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'titleKor': titleKor,
      if (titleEng != null) 'titleEng': titleEng,
      'titleJp': titleJp,
      'artistId': artistId,
      if (story != null) 'story': story,
      if (lyricsJp != null) 'lyricsJp': lyricsJp,
      if (lyricsKr != null) 'lyricsKr': lyricsKr,
      if (youtubeUrl != null) 'youtubeUrl': youtubeUrl,
      'relatedSongIds': relatedSongs.map((r) => r.toJson()).toList(),
    };
  }

  /// 필수 필드가 모두 채워졌는지 확인
  bool get isComplete =>
      titleKor.isNotEmpty && titleJp.isNotEmpty && artistId > 0;
}

/// 연관곡 입력
class RelatedSongInput {
  final int relatedSongId;
  final String reason;

  const RelatedSongInput({
    required this.relatedSongId,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'relatedSongId': relatedSongId,
      'reason': reason,
    };
  }
}

/// 아티스트 자동완성 결과
class ArtistSuggestion {
  final int id;
  final String nameKor;
  final String? nameEng;
  final String? nameJp;

  const ArtistSuggestion({
    required this.id,
    required this.nameKor,
    this.nameEng,
    this.nameJp,
  });

  factory ArtistSuggestion.fromJson(Map<String, dynamic> json) {
    return ArtistSuggestion(
      id: json['id'] as int,
      nameKor: json['nameKor'] as String,
      nameEng: json['nameEng'] as String?,
      nameJp: json['nameJp'] as String?,
    );
  }

  String get displayName {
    final parts = <String>[nameKor];
    if (nameEng != null && nameEng!.isNotEmpty) parts.add(nameEng!);
    return parts.join(' / ');
  }
}

/// 곡 검색 결과 (연관곡 추가용)
class SongSearchResult {
  final int id;
  final String titleKor;
  final String titleJp;
  final String artistName;

  const SongSearchResult({
    required this.id,
    required this.titleKor,
    required this.titleJp,
    required this.artistName,
  });

  factory SongSearchResult.fromJson(Map<String, dynamic> json) {
    return SongSearchResult(
      id: json['id'] as int,
      titleKor: json['titleKor'] as String,
      titleJp: json['titleJp'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
    );
  }
}

/// 예약 게시 상태
enum ScheduleStatus {
  pending('PENDING', '대기'),
  published('PUBLISHED', '게시됨'),
  cancelled('CANCELLED', '취소됨');

  const ScheduleStatus(this.code, this.displayName);
  final String code;
  final String displayName;

  static ScheduleStatus fromCode(String code) {
    return ScheduleStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ScheduleStatus.pending,
    );
  }
}

/// 예약 게시 아이템
class ScheduledSongItem {
  final int id;
  final int songId;
  final String songTitle;
  final String artistName;
  final DateTime scheduledAt;
  final ScheduleStatus status;
  final bool isSongComplete;

  const ScheduledSongItem({
    required this.id,
    required this.songId,
    required this.songTitle,
    required this.artistName,
    required this.scheduledAt,
    required this.status,
    this.isSongComplete = true,
  });

  factory ScheduledSongItem.fromJson(Map<String, dynamic> json) {
    return ScheduledSongItem(
      id: json['id'] as int,
      songId: json['songId'] as int,
      songTitle: json['songTitle'] as String,
      artistName: json['artistName'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      status: ScheduleStatus.fromCode(json['status'] as String),
      isSongComplete: json['isSongComplete'] as bool? ?? true,
    );
  }
}

/// 예약 게시 요청
class SchedulePublishRequest {
  final int songId;
  final DateTime scheduledAt;

  const SchedulePublishRequest({
    required this.songId,
    required this.scheduledAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'songId': songId,
      'scheduledAt': scheduledAt.toIso8601String(),
    };
  }
}

/// 관리자 댓글 아이템
class AdminCommentItem {
  final int id;
  final int feedPostId;
  final String authorNickname;
  final int authorId;
  final String content;
  final int likeCount;
  final int reportCount;
  final bool isFiltered;
  final DateTime createdAt;

  const AdminCommentItem({
    required this.id,
    required this.feedPostId,
    required this.authorNickname,
    required this.authorId,
    required this.content,
    this.likeCount = 0,
    this.reportCount = 0,
    this.isFiltered = false,
    required this.createdAt,
  });

  factory AdminCommentItem.fromJson(Map<String, dynamic> json) {
    return AdminCommentItem(
      id: json['id'] as int,
      feedPostId: json['feedPostId'] as int,
      authorNickname: json['authorNickname'] as String,
      authorId: json['authorId'] as int,
      content: json['content'] as String,
      likeCount: json['likeCount'] as int? ?? 0,
      reportCount: json['reportCount'] as int? ?? 0,
      isFiltered: json['isFiltered'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// 관리자 댓글 목록 응답
class AdminCommentListResponse {
  final List<AdminCommentItem> comments;
  final int totalCount;
  final int page;
  final int pageSize;

  const AdminCommentListResponse({
    required this.comments,
    required this.totalCount,
    this.page = 0,
    this.pageSize = 20,
  });

  factory AdminCommentListResponse.fromJson(Map<String, dynamic> json) {
    return AdminCommentListResponse(
      comments: (json['comments'] as List)
          .map((e) => AdminCommentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }
}
