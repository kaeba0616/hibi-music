/// F12 Management Repository
/// Mock Provider 패턴 적용 + Real API

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:http/http.dart' as http;

import '../../report/models/report_models.dart';
import '../../question/models/question_models.dart';
import '../../faq/models/faq_models.dart';
import '../models/admin_models.dart';
import '../models/admin_report_models.dart';
import '../models/admin_question_models.dart';
import '../models/admin_faq_models.dart';
import '../models/admin_song_models.dart';
import '../mocks/admin_mock.dart';
import '../mocks/admin_song_mock.dart' as song_mock;

/// Admin Repository
class AdminRepository {
  final bool useMock;
  final String baseHost = Env.basehost;
  final String basePath = '/api/v1/admin';

  AdminRepository({this.useMock = false});

  // ==================== Dashboard ====================

  /// 대시보드 통계 조회
  Future<AdminStats> getStats() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return mockAdminStats;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.get(
        Uri.http(baseHost, '$basePath/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('getStats: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminStats.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? '통계 조회 실패');
    }
  }

  // ==================== Reports ====================

  /// 신고 목록 조회
  Future<AdminReportListResponse> getReports({
    ReportStatus? status,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      var reports = mockAdminReports;
      if (status != null) {
        reports = reports.where((r) => r.status == status).toList();
      }
      return AdminReportListResponse(
        reports: reports,
        totalCount: reports.length,
        page: page,
        pageSize: pageSize,
      );
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': pageSize.toString(),
    };
    if (status != null) {
      queryParams['status'] = status.code;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.get(
        Uri.http(baseHost, '$basePath/reports', queryParams),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('getReports: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminReportListResponse.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? '신고 목록 조회 실패');
    }
  }

  /// 신고 상세 조회
  Future<AdminReportDetail> getReportDetail(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return getMockReportDetail(id);
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.get(
        Uri.http(baseHost, '$basePath/reports/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('getReportDetail: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminReportDetail.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? '신고 상세 조회 실패');
    }
  }

  /// 신고 처리
  Future<void> processReport(ReportActionRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.post(
        Uri.http(baseHost, '$basePath/reports/process'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ),
    );

    log('processReport: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? '신고 처리 실패');
    }
  }

  // ==================== Questions ====================

  /// 문의 목록 조회
  Future<AdminQuestionListResponse> getQuestions({
    QuestionStatus? status,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      var questions = mockAdminQuestions;
      if (status != null) {
        questions = questions.where((q) => q.status == status).toList();
      }
      return AdminQuestionListResponse(
        questions: questions,
        totalCount: questions.length,
        page: page,
        pageSize: pageSize,
      );
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': pageSize.toString(),
    };
    if (status != null) {
      queryParams['status'] = status.code;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.get(
        Uri.http(baseHost, '$basePath/questions', queryParams),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('getQuestions: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminQuestionListResponse.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? '문의 목록 조회 실패');
    }
  }

  /// 문의 상세 조회
  Future<AdminQuestionDetail> getQuestionDetail(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return getMockQuestionDetail(id);
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.get(
        Uri.http(baseHost, '$basePath/questions/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('getQuestionDetail: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminQuestionDetail.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? '문의 상세 조회 실패');
    }
  }

  /// 문의 답변 작성
  Future<void> answerQuestion(QuestionAnswerRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.post(
        Uri.http(baseHost, '$basePath/questions/answer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ),
    );

    log('answerQuestion: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? '답변 등록 실패');
    }
  }

  // ==================== FAQs ====================

  /// FAQ 목록 조회 (관리자용 - 비공개 포함)
  Future<AdminFAQListResponse> getFaqs({FAQCategory? category}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      var faqs = mockAdminFaqs;
      if (category != null) {
        faqs = faqs.where((f) => f.category == category).toList();
      }
      return AdminFAQListResponse(
        faqs: faqs,
        totalCount: faqs.length,
      );
    }

    final queryParams = <String, String>{};
    if (category != null) {
      queryParams['category'] = category.code;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.get(
        Uri.http(baseHost, '$basePath/faqs', queryParams),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('getFaqs: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminFAQListResponse.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'FAQ 목록 조회 실패');
    }
  }

  /// FAQ 생성/수정
  Future<AdminFAQItem> saveFaq(FAQSaveRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return AdminFAQItem(
        id: request.id ?? (mockAdminFaqs.length + 1),
        category: request.category,
        question: request.question,
        answer: request.answer,
        displayOrder: request.displayOrder,
        isPublished: request.isPublished,
        createdAt: DateTime.now(),
        updatedAt: request.isUpdate ? DateTime.now() : null,
      );
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.post(
        Uri.http(baseHost, '$basePath/faqs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ),
    );

    log('saveFaq: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminFAQItem.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? 'FAQ 저장 실패');
    }
  }

  /// FAQ 삭제
  Future<void> deleteFaq(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.delete(
        Uri.http(baseHost, '$basePath/faqs/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('deleteFaq: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'FAQ 삭제 실패');
    }
  }

  // ==================== Members ====================

  /// 회원 목록 조회
  Future<AdminMemberListResponse> getMembers({
    String? search,
    MemberStatus? status,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      var members = mockAdminMembers;
      if (status != null) {
        members = members.where((m) => m.status == status).toList();
      }
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        members = members.where((m) =>
          m.nickname.toLowerCase().contains(query) ||
          m.email.toLowerCase().contains(query)
        ).toList();
      }
      return AdminMemberListResponse(
        members: members,
        totalCount: members.length,
        page: page,
        pageSize: pageSize,
      );
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': pageSize.toString(),
    };
    if (status != null) {
      queryParams['status'] = status.code;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.get(
        Uri.http(baseHost, '$basePath/members', queryParams),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('getMembers: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminMemberListResponse.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? '회원 목록 조회 실패');
    }
  }

  /// 회원 상세 조회
  Future<AdminMemberInfo> getMemberDetail(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return getMockMemberDetail(id);
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.get(
        Uri.http(baseHost, '$basePath/members/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('getMemberDetail: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminMemberInfo.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? '회원 상세 조회 실패');
    }
  }

  /// 회원 제재 (정지/강제탈퇴)
  Future<void> sanctionMember(MemberSanctionRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.post(
        Uri.http(baseHost, '$basePath/members/sanction'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ),
    );

    log('sanctionMember: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? '회원 제재 실패');
    }
  }

  // ==================== F18: Admin Enhancement ====================

  /// 관리자 곡 등록 (Enhanced)
  Future<void> createAdminSong(AdminSongCreateRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.post(
        Uri.http(baseHost, '$basePath/songs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ),
    );

    log('createAdminSong: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? '곡 등록 실패');
    }
  }

  /// 예약 게시 등록
  Future<void> scheduleSongPublish(SchedulePublishRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.post(
        Uri.http(baseHost, '$basePath/songs/${request.songId}/schedule'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ),
    );

    log('scheduleSongPublish: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? '예약 등록 실패');
    }
  }

  /// 예약 취소
  Future<void> cancelScheduledPublish(int scheduleId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.delete(
        Uri.http(baseHost, '$basePath/songs/schedule/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('cancelScheduledPublish: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? '예약 취소 실패');
    }
  }

  /// 관리자 댓글 목록 조회
  Future<AdminCommentListResponse> getAdminComments({
    bool onlyReported = false,
    int page = 0,
    int pageSize = 20,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      var comments = song_mock.mockAdminComments;
      if (onlyReported) {
        comments = comments.where((c) => c.reportCount > 0).toList();
      }
      return AdminCommentListResponse(
        comments: comments,
        totalCount: comments.length,
        page: page,
        pageSize: pageSize,
      );
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': pageSize.toString(),
    };
    if (onlyReported) {
      queryParams['reported'] = 'true';
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.get(
        Uri.http(baseHost, '$basePath/comments', queryParams),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('getAdminComments: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminCommentListResponse.fromJson(body['data']);
    } else {
      throw Exception(body['message'] ?? '댓글 목록 조회 실패');
    }
  }

  /// 관리자 댓글 삭제
  Future<void> deleteAdminComment(int commentId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.delete(
        Uri.http(baseHost, '$basePath/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('deleteAdminComment: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? '댓글 삭제 실패');
    }
  }

  /// 회원 정지 해제
  Future<void> unbanMember(int memberId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final response = await AuthenticationRepository.requestWithRetry(
      (token) => http.post(
        Uri.http(baseHost, '$basePath/members/$memberId/unban'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    log('unbanMember: ${response.statusCode}');
    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? '정지 해제 실패');
    }
  }
}

/// Admin Repository Provider
final adminRepoProvider = Provider<AdminRepository>((ref) {
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return AdminRepository(useMock: useMock);
});
