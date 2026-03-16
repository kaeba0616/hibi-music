/// F11 Report Repository
/// Mock Provider 패턴 적용

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:http/http.dart' as http;

import '../models/report_models.dart';
import '../mocks/report_mock.dart';

/// 신고 결과
class ReportResult {
  final bool success;
  final String? errorCode;
  final String? message;

  const ReportResult({
    required this.success,
    this.errorCode,
    this.message,
  });
}

/// Report Repository
class ReportRepository {
  final bool useMock;
  final basehost = Env.basehost;
  final basepath = "/api/v1/reports";

  ReportRepository({this.useMock = false});

  /// 신고 생성
  Future<ReportResult> createReport(ReportCreateRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));

      final result = createMockReport(request, 1); // Mock reporterId = 1

      if (!result.success) {
        if (result.errorCode == 'DUPLICATE_REPORT') {
          return const ReportResult(
            success: false,
            errorCode: 'DUPLICATE_REPORT',
            message: '이미 신고한 항목입니다',
          );
        }
        return const ReportResult(
          success: false,
          errorCode: 'UNKNOWN_ERROR',
          message: '신고 처리 중 오류가 발생했습니다',
        );
      }

      return const ReportResult(
        success: true,
        message: '신고가 접수되었습니다',
      );
    }

    // Real API
    final uri = Uri.http(basehost, basepath);

    try {
      final response = await AuthenticationRepository.requestWithRetry(
        (accessToken) => http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
          body: jsonEncode(request.toJson()),
        ),
      );

      log("createReport: ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ReportResult(
          success: true,
          message: '신고가 접수되었습니다',
        );
      }

      // 중복 신고 (409 Conflict 또는 에러 메시지로 판단)
      final errorBody = jsonDecode(response.body);
      final errorMessage = errorBody["message"] ?? "";

      if (response.statusCode == 409 || errorMessage.contains("이미 신고")) {
        return const ReportResult(
          success: false,
          errorCode: 'DUPLICATE_REPORT',
          message: '이미 신고한 항목입니다',
        );
      }

      // 본인 콘텐츠 신고 시도
      if (errorMessage.contains("본인")) {
        return ReportResult(
          success: false,
          errorCode: 'SELF_REPORT',
          message: errorMessage,
        );
      }

      log("Error: createReport - ${response.body}");
      return ReportResult(
        success: false,
        errorCode: 'UNKNOWN_ERROR',
        message: errorMessage.isNotEmpty ? errorMessage : '신고 처리 중 오류가 발생했습니다',
      );
    } catch (e) {
      log("Error: createReport - $e");
      return const ReportResult(
        success: false,
        errorCode: 'NETWORK_ERROR',
        message: '네트워크 오류가 발생했습니다',
      );
    }
  }

  /// 중복 신고 체크
  Future<bool> checkAlreadyReported(
    ReportTargetType targetType,
    int targetId,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));

      final targetKey = '${targetType.code}_$targetId';
      return mockReportedTargets.contains(targetKey);
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/check", {
      "targetType": targetType.code,
      "targetId": targetId.toString(),
    });

    try {
      final response = await AuthenticationRepository.requestWithRetry(
        (accessToken) => http.get(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      log("checkAlreadyReported: ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body)["data"];
        if (data == null) return false;
        return data["alreadyReported"] ?? false;
      }

      log("Error: checkAlreadyReported - ${response.body}");
      return false;
    } catch (e) {
      log("Error: checkAlreadyReported - $e");
      return false;
    }
  }
}

/// Report Repository Provider
final reportRepoProvider = Provider<ReportRepository>((ref) {
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return ReportRepository(useMock: useMock);
});
