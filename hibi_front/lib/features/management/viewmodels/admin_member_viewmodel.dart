/// F12 관리자 사용자 관리 ViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/admin_models.dart';
import '../repos/admin_repo.dart';

/// 사용자 목록 상태
class MemberListState {
  final List<AdminMemberInfo> members;
  final int totalCount;
  final bool isLoading;
  final String? errorMessage;
  final MemberStatus? selectedStatus;
  final String searchQuery;

  const MemberListState({
    this.members = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.errorMessage,
    this.selectedStatus,
    this.searchQuery = '',
  });

  MemberListState copyWith({
    List<AdminMemberInfo>? members,
    int? totalCount,
    bool? isLoading,
    String? errorMessage,
    MemberStatus? selectedStatus,
    String? searchQuery,
    bool clearError = false,
    bool clearStatus = false,
  }) {
    return MemberListState(
      members: members ?? this.members,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// 사용자 목록 ViewModel
class MemberListViewModel extends StateNotifier<MemberListState> {
  final AdminRepository _repository;

  MemberListViewModel(this._repository) : super(const MemberListState());

  /// 사용자 목록 로드
  Future<void> loadMembers({
    MemberStatus? status,
    String? search,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedStatus: status,
      searchQuery: search ?? state.searchQuery,
      clearStatus: status == null && state.selectedStatus != null,
    );

    try {
      final response = await _repository.getMembers(
        status: status ?? state.selectedStatus,
        search: search ?? state.searchQuery,
      );
      state = state.copyWith(
        members: response.members,
        totalCount: response.totalCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '사용자 목록을 불러오는데 실패했습니다',
      );
    }
  }

  /// 필터 변경
  void filterByStatus(MemberStatus? status) {
    loadMembers(status: status);
  }

  /// 검색
  void search(String query) {
    loadMembers(search: query);
  }
}

/// 사용자 상세 상태
class MemberDetailState {
  final AdminMemberInfo? member;
  final bool isLoading;
  final bool isSanctioning;
  final String? errorMessage;
  final bool isSanctioned;

  const MemberDetailState({
    this.member,
    this.isLoading = false,
    this.isSanctioning = false,
    this.errorMessage,
    this.isSanctioned = false,
  });

  MemberDetailState copyWith({
    AdminMemberInfo? member,
    bool? isLoading,
    bool? isSanctioning,
    String? errorMessage,
    bool? isSanctioned,
    bool clearError = false,
  }) {
    return MemberDetailState(
      member: member ?? this.member,
      isLoading: isLoading ?? this.isLoading,
      isSanctioning: isSanctioning ?? this.isSanctioning,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSanctioned: isSanctioned ?? this.isSanctioned,
    );
  }
}

/// 사용자 상세 ViewModel
class MemberDetailViewModel extends StateNotifier<MemberDetailState> {
  final AdminRepository _repository;
  final int memberId;

  MemberDetailViewModel(this._repository, this.memberId)
      : super(const MemberDetailState());

  /// 상세 로드
  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final member = await _repository.getMemberDetail(memberId);
      state = state.copyWith(
        member: member,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '사용자 정보를 불러오는데 실패했습니다',
      );
    }
  }

  /// 사용자 정지
  Future<void> suspendMember({
    required SuspensionDuration duration,
    String? reason,
  }) async {
    state = state.copyWith(isSanctioning: true, clearError: true);

    try {
      await _repository.sanctionMember(
        MemberSanctionRequest(
          memberId: memberId,
          sanctionType: 'SUSPEND',
          duration: duration,
          reason: reason,
        ),
      );
      state = state.copyWith(
        isSanctioning: false,
        isSanctioned: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSanctioning: false,
        errorMessage: '사용자 정지에 실패했습니다',
      );
    }
  }

  /// 사용자 강제 탈퇴
  Future<void> banMember({String? reason}) async {
    state = state.copyWith(isSanctioning: true, clearError: true);

    try {
      await _repository.sanctionMember(
        MemberSanctionRequest(
          memberId: memberId,
          sanctionType: 'BAN',
          reason: reason,
        ),
      );
      state = state.copyWith(
        isSanctioning: false,
        isSanctioned: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSanctioning: false,
        errorMessage: '강제 탈퇴에 실패했습니다',
      );
    }
  }
}

/// 사용자 목록 Provider
final memberListViewModelProvider =
    StateNotifierProvider<MemberListViewModel, MemberListState>((ref) {
  final repository = ref.watch(adminRepoProvider);
  return MemberListViewModel(repository);
});

/// 사용자 상세 Provider Family
final memberDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<MemberDetailViewModel, MemberDetailState, int>((ref, memberId) {
  final repository = ref.watch(adminRepoProvider);
  return MemberDetailViewModel(repository, memberId);
});
