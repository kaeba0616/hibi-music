import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mocks/my_comments_mock.dart';

/// 내가 쓴 댓글 목록 상태
class MyCommentsState {
  final List<MyComment> comments;
  final bool isLoading;
  final String? error;

  const MyCommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  MyCommentsState copyWith({
    List<MyComment>? comments,
    bool? isLoading,
    String? error,
  }) {
    return MyCommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 내가 쓴 댓글 ViewModel
class MyCommentsViewModel extends StateNotifier<MyCommentsState> {
  final bool useMock;

  MyCommentsViewModel({this.useMock = false}) : super(const MyCommentsState());

  /// 내가 쓴 댓글 목록 로드
  Future<void> loadMyComments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        state = state.copyWith(
          comments: mockMyComments,
          isLoading: false,
        );
        return;
      }

      // TODO: Real API - GET /api/v1/members/me/comments
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '댓글 목록을 불러올 수 없습니다',
      );
    }
  }
}

/// 내가 쓴 댓글 Provider
final myCommentsProvider =
    StateNotifierProvider<MyCommentsViewModel, MyCommentsState>((ref) {
  const useMock =
      String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return MyCommentsViewModel(useMock: useMock);
});
