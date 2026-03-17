import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:http/http.dart' as http;
import '../mocks/question_mock.dart' as mock;
import '../models/question_models.dart';

/// Question Repository
class QuestionRepository {
  final bool useMock;
  final basehost = Env.basehost;
  final basepath = "/api/v1/questions";

  QuestionRepository({this.useMock = false});

  /// 문의 목록 조회 (본인 문의만)
  Future<QuestionListResponse> getMyQuestions() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final questions = mock.getMockQuestions(memberId: 1);
      // 최신순 정렬
      questions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return QuestionListResponse(
        questions: questions,
        totalCount: questions.length,
      );
    }

    // Real API
    final uri = Uri.http(basehost, basepath);

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

      log("getMyQuestions: ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body)["data"];
        if (data == null) return QuestionListResponse.empty();

        return QuestionListResponse.fromJson(data);
      }

      log("Error: getMyQuestions - ${response.body}");
      return QuestionListResponse.empty();
    } catch (e) {
      log("Error: getMyQuestions - $e");
      return QuestionListResponse.empty();
    }
  }

  /// 문의 상세 조회
  Future<Question?> getQuestionById(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mock.getMockQuestionById(id);
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$id");

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

      log("getQuestionById: ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body)["data"];
        if (data == null) return null;
        return Question.fromJson(data);
      }

      log("Error: getQuestionById - ${response.body}");
      return null;
    } catch (e) {
      log("Error: getQuestionById - $e");
      return null;
    }
  }

  /// 오늘의 문의 작성 수 조회 (F17)
  Future<int> getTodayQuestionCount() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      // Mock: 오늘 1개 작성한 것으로 가정
      return 1;
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/today-count");

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

      log("getTodayQuestionCount: ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body)["data"];
        return data as int? ?? 0;
      }

      return 0;
    } catch (e) {
      log("Error: getTodayQuestionCount - $e");
      return 0;
    }
  }

  /// 문의 작성
  Future<Question> createQuestion(QuestionCreateRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      // 유효성 검사
      final error = request.validate();
      if (error != null) {
        throw Exception(error);
      }
      return mock.createMockQuestion(request, 1);
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

      log("createQuestion: ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body)["data"];
        if (data == null) {
          throw Exception("문의 생성에 실패했습니다");
        }
        return Question.fromJson(data);
      }

      final errorBody = jsonDecode(response.body);
      final errorMessage = errorBody["message"] ?? "문의 생성에 실패했습니다";
      log("Error: createQuestion - ${response.body}");
      throw Exception(errorMessage);
    } catch (e) {
      log("Error: createQuestion - $e");
      rethrow;
    }
  }
}

/// Mock Provider 패턴 적용
final questionRepoProvider = Provider<QuestionRepository>((ref) {
  const useMock =
      String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return QuestionRepository(useMock: useMock);
});
