/// F12 Management 모델 정의
/// 관리자 기능에 사용되는 데이터 모델

/// 관리자 대시보드 통계
class AdminStats {
  final int pendingReports;
  final int unansweredQuestions;
  final int totalMembers;
  final int totalFaqs;
  final int todayNewMembers;
  final int todayNewReports;

  const AdminStats({
    required this.pendingReports,
    required this.unansweredQuestions,
    required this.totalMembers,
    required this.totalFaqs,
    this.todayNewMembers = 0,
    this.todayNewReports = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      pendingReports: json['pendingReports'] as int,
      unansweredQuestions: json['unansweredQuestions'] as int,
      totalMembers: json['totalMembers'] as int,
      totalFaqs: json['totalFaqs'] as int,
      todayNewMembers: json['todayNewMembers'] as int? ?? 0,
      todayNewReports: json['todayNewReports'] as int? ?? 0,
    );
  }

  factory AdminStats.empty() {
    return const AdminStats(
      pendingReports: 0,
      unansweredQuestions: 0,
      totalMembers: 0,
      totalFaqs: 0,
    );
  }
}

/// 사용자 상태
enum MemberStatus {
  active('ACTIVE', '활성'),
  suspended('SUSPENDED', '정지'),
  banned('BANNED', '탈퇴');

  const MemberStatus(this.code, this.displayName);
  final String code;
  final String displayName;

  static MemberStatus fromCode(String code) {
    return MemberStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MemberStatus.active,
    );
  }
}

/// 사용자 권한
enum MemberRole {
  user('USER', '일반 사용자'),
  admin('ADMIN', '관리자');

  const MemberRole(this.code, this.displayName);
  final String code;
  final String displayName;

  static MemberRole fromCode(String code) {
    return MemberRole.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MemberRole.user,
    );
  }
}

/// 관리자용 사용자 정보
class AdminMemberInfo {
  final int id;
  final String email;
  final String nickname;
  final String? profileImage;
  final MemberRole role;
  final MemberStatus status;
  final DateTime createdAt;
  final int postCount;
  final int commentCount;
  final int followerCount;
  final int followingCount;
  final int reportReceivedCount;
  final int reportSentCount;

  const AdminMemberInfo({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImage,
    required this.role,
    required this.status,
    required this.createdAt,
    this.postCount = 0,
    this.commentCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.reportReceivedCount = 0,
    this.reportSentCount = 0,
  });

  factory AdminMemberInfo.fromJson(Map<String, dynamic> json) {
    return AdminMemberInfo(
      id: json['id'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profileImage'] as String?,
      role: MemberRole.fromCode(json['role'] as String),
      status: MemberStatus.fromCode(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      postCount: json['postCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      followerCount: json['followerCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      reportReceivedCount: json['reportReceivedCount'] as int? ?? 0,
      reportSentCount: json['reportSentCount'] as int? ?? 0,
    );
  }
}

/// 사용자 목록 응답
class AdminMemberListResponse {
  final List<AdminMemberInfo> members;
  final int totalCount;
  final int page;
  final int pageSize;

  const AdminMemberListResponse({
    required this.members,
    required this.totalCount,
    this.page = 0,
    this.pageSize = 20,
  });

  factory AdminMemberListResponse.fromJson(Map<String, dynamic> json) {
    return AdminMemberListResponse(
      members: (json['members'] as List)
          .map((e) => AdminMemberInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }

  factory AdminMemberListResponse.empty() {
    return const AdminMemberListResponse(
      members: [],
      totalCount: 0,
    );
  }
}

/// 정지 기간
enum SuspensionDuration {
  days7('7일', 7),
  days30('30일', 30),
  permanent('영구 정지', -1);

  const SuspensionDuration(this.displayName, this.days);
  final String displayName;
  final int days;
}

/// 사용자 제재 요청
class MemberSanctionRequest {
  final int memberId;
  final String sanctionType; // SUSPEND, BAN
  final SuspensionDuration? duration;
  final String? reason;

  const MemberSanctionRequest({
    required this.memberId,
    required this.sanctionType,
    this.duration,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'sanctionType': sanctionType,
      if (duration != null) 'durationDays': duration!.days,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
    };
  }
}
