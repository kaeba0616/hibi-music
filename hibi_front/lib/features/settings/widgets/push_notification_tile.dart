import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 푸시 알림 설정 상태
class PushNotificationState {
  final bool isEnabled;
  final bool isLoading;

  const PushNotificationState({
    this.isEnabled = true,
    this.isLoading = false,
  });

  PushNotificationState copyWith({
    bool? isEnabled,
    bool? isLoading,
  }) {
    return PushNotificationState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 푸시 알림 설정 ViewModel
class PushNotificationViewModel extends StateNotifier<PushNotificationState> {
  final bool useMock;

  PushNotificationViewModel({this.useMock = false})
      : super(const PushNotificationState());

  /// 푸시 알림 토글
  Future<void> toggle() async {
    final previousState = state.isEnabled;
    state = state.copyWith(
      isEnabled: !previousState,
      isLoading: true,
    );

    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 300));
        state = state.copyWith(isLoading: false);
        return;
      }

      // TODO: Real API - PATCH /api/v1/members/me (pushEnabled)
      state = state.copyWith(isLoading: false);
    } catch (e) {
      // 실패 시 롤백
      state = state.copyWith(
        isEnabled: previousState,
        isLoading: false,
      );
    }
  }

  /// 서버에서 현재 설정 로드
  Future<void> loadSettings() async {
    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 200));
        state = state.copyWith(isEnabled: true);
        return;
      }

      // TODO: Real API - GET /api/v1/members/me -> pushEnabled
    } catch (e) {
      // 기본값 유지
    }
  }
}

/// 푸시 알림 Provider
final pushNotificationProvider =
    StateNotifierProvider<PushNotificationViewModel, PushNotificationState>(
        (ref) {
  const useMock =
      String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return PushNotificationViewModel(useMock: useMock);
});

/// MP-02: 푸시 알림 토글 타일 위젯
class PushNotificationTile extends ConsumerWidget {
  const PushNotificationTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pushNotificationProvider);

    return SwitchListTile(
      secondary: Icon(
        state.isEnabled
            ? Icons.notifications_active
            : Icons.notifications_off_outlined,
        size: 28,
        color: state.isEnabled ? Colors.teal : Colors.grey,
      ),
      title: const Text('푸시 알림'),
      subtitle: Text(
        state.isEnabled ? '오늘의 곡 알림을 받습니다' : '알림이 꺼져있습니다',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      value: state.isEnabled,
      onChanged: state.isLoading
          ? null
          : (value) {
              ref.read(pushNotificationProvider.notifier).toggle();
            },
    );
  }
}
