# Frontend 테스트 케이스 상세 (Flutter)

## 1. Widget 테스트

### 1.1 공통 컴포넌트

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-01 | StatusBadge | 상태별 색상 표시 | PENDING=노랑, RESOLVED=초록 | P1 |
| FW-02 | FilterChipBar | 칩 선택 시 콜백 호출 | onSelected 호출됨 | P1 |
| FW-03 | EmptyView | 빈 상태 메시지 표시 | 메시지, 아이콘 표시 | P1 |
| FW-04 | ErrorView | 에러 메시지 및 재시도 버튼 | 메시지 표시, 재시도 버튼 동작 | P1 |
| FW-05 | LoadingView | 로딩 인디케이터 | CircularProgressIndicator | P2 |

### 1.2 인증 관련 (F1)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-AUTH-01 | LoginView | 이메일/비밀번호 입력 | 입력 필드 동작 | P0 |
| FW-AUTH-02 | LoginView | 로그인 버튼 비활성화 | 빈 필드 시 disabled | P0 |
| FW-AUTH-03 | LoginView | 에러 메시지 표시 | 로그인 실패 시 Snackbar | P0 |
| FW-AUTH-04 | SignupView | 유효성 검사 에러 표시 | 각 필드 에러 텍스트 | P0 |
| FW-AUTH-05 | SignupView | 비밀번호 확인 불일치 | 에러 메시지 표시 | P0 |

### 1.3 Daily Song 관련 (F2)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-DS-01 | DailySongCard | 노래 정보 표시 | 제목, 아티스트, 앨범 커버 | P0 |
| FW-DS-02 | DailySongCard | 좋아요 버튼 토글 | 아이콘 색상 변경 | P0 |
| FW-DS-03 | DailySongCard | 외부 링크 버튼 | Spotify, Apple Music 버튼 표시 | P1 |
| FW-DS-04 | LyricsView | 가사 표시 | 일본어/한국어 가사 | P1 |

### 1.4 아티스트 관련 (F3)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-ART-01 | ArtistListTile | 아티스트 정보 표시 | 이름, 프로필, 팔로워 수 | P0 |
| FW-ART-02 | ArtistListTile | 팔로우 버튼 상태 | isFollowing에 따른 UI | P0 |
| FW-ART-03 | ArtistDetailView | 상세 정보 표시 | 설명, 노래 목록 | P1 |
| FW-ART-04 | ArtistSearchBar | 검색어 입력 | debounce 후 검색 | P1 |

### 1.5 게시글 관련 (F5)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-POST-01 | PostCard | 게시글 정보 표시 | 작성자, 내용, 이미지 | P0 |
| FW-POST-02 | PostCard | 좋아요/댓글 카운트 | 숫자 표시 | P0 |
| FW-POST-03 | PostCard | 태그된 노래 표시 | 노래 카드 표시 | P1 |
| FW-POST-04 | PostCreateView | 내용 입력 | 500자 제한 표시 | P0 |
| FW-POST-05 | PostCreateView | 이미지 선택 | 최대 4개 표시 | P1 |
| FW-POST-06 | PostCard | 더보기 메뉴 | 수정/삭제 (본인), 신고 (타인) | P0 |

### 1.6 댓글 관련 (F6)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-CMT-01 | CommentTile | 댓글 정보 표시 | 작성자, 내용, 시간 | P0 |
| FW-CMT-02 | CommentTile | 대댓글 들여쓰기 | 대댓글 왼쪽 마진 | P0 |
| FW-CMT-03 | CommentTile | 삭제된 댓글 표시 | "삭제된 댓글입니다" | P0 |
| FW-CMT-04 | CommentInput | 댓글 입력 | 전송 버튼 활성화 | P0 |
| FW-CMT-05 | CommentTile | 좋아요 버튼 | 토글 동작 | P1 |

### 1.7 팔로우 관련 (F7)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-FLW-01 | ProfileHeader | 팔로워/팔로잉 수 표시 | 숫자 및 탭 가능 | P0 |
| FW-FLW-02 | FollowButton | 팔로우 상태 표시 | 팔로우/팔로잉 텍스트 | P0 |
| FW-FLW-03 | FollowerListTile | 사용자 정보 표시 | 닉네임, 프로필 | P0 |
| FW-FLW-04 | FollowerListTile | 맞팔로우 표시 | isFollowing 표시 | P1 |

### 1.8 검색 관련 (F8)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-SRC-01 | SearchBar | 검색어 입력 | debounce 적용 | P0 |
| FW-SRC-02 | SearchResultView | 카테고리별 결과 | 노래/아티스트/게시글/사용자 섹션 | P0 |
| FW-SRC-03 | SearchResultView | 검색 결과 없음 | Empty 상태 표시 | P0 |
| FW-SRC-04 | RecentSearchChip | 최근 검색어 표시 | 칩 목록 | P1 |

### 1.9 FAQ 관련 (F9)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-FAQ-01 | FAQCategoryTabs | 카테고리 탭 표시 | 전체/계정/서비스 등 | P0 |
| FW-FAQ-02 | FAQItemTile | 아코디언 동작 | 탭 시 확장/축소 | P0 |
| FW-FAQ-03 | FAQSearchBar | 검색 필터링 | 키워드 매칭 | P1 |
| FW-FAQ-04 | FAQContactCard | 문의하기 유도 | 버튼 표시 및 네비게이션 | P1 |

### 1.10 문의 관련 (F10)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-QST-01 | QuestionTypeSelector | 유형 선택 | 라디오 버튼 동작 | P0 |
| FW-QST-02 | QuestionCreateView | 유효성 검사 | 제목/내용 필수 체크 | P0 |
| FW-QST-03 | QuestionListTile | 문의 상태 표시 | 접수됨/처리중/답변완료 | P0 |
| FW-QST-04 | QuestionAnswerCard | 답변 표시 | 답변 내용 및 시간 | P0 |

### 1.11 신고 관련 (F11)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-RPT-01 | ReportReasonTile | 신고 사유 선택 | 라디오 버튼 동작 | P0 |
| FW-RPT-02 | ReportBottomSheet | 제출 버튼 활성화 | 사유 선택 후 활성화 | P0 |
| FW-RPT-03 | ReportSuccessDialog | 완료 메시지 표시 | 성공 아이콘 및 메시지 | P0 |
| FW-RPT-04 | ReportDuplicateDialog | 중복 신고 안내 | 이미 신고 메시지 | P0 |

### 1.12 관리자 관련 (F12)

| TC-ID | Widget | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|--------|--------------|-----------|----------|
| FW-ADM-01 | AdminStatCard | 통계 카드 표시 | 제목, 값, 서브텍스트 | P0 |
| FW-ADM-02 | AdminMenuTile | 메뉴 항목 표시 | 아이콘, 제목, 뱃지 | P0 |
| FW-ADM-03 | AdminReportTile | 신고 정보 표시 | 신고자, 대상, 상태 | P0 |
| FW-ADM-04 | AdminQuestionTile | 문의 정보 표시 | 작성자, 제목, 상태 | P0 |
| FW-ADM-05 | AdminFAQTile | FAQ 정보 표시 | 질문, 공개 상태 | P0 |
| FW-ADM-06 | AdminMemberTile | 회원 정보 표시 | 닉네임, 상태, 신고 수 | P0 |
| FW-ADM-07 | SanctionDialog | 제재 옵션 | 정지/강제탈퇴 선택 | P0 |
| FW-ADM-08 | ReportActionDialog | 처리 옵션 | 해결/기각 선택 | P0 |

---

## 2. ViewModel 테스트

### 2.1 인증 ViewModel

| TC-ID | ViewModel | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|-----------|--------------|-----------|----------|
| FVM-AUTH-01 | AuthViewModel | 로그인 성공 | state.isLoggedIn = true | P0 |
| FVM-AUTH-02 | AuthViewModel | 로그인 실패 | state.error 설정 | P0 |
| FVM-AUTH-03 | AuthViewModel | 회원가입 성공 | 토큰 저장, 로그인 상태 | P0 |
| FVM-AUTH-04 | AuthViewModel | 로그아웃 | 토큰 삭제, 상태 초기화 | P0 |

### 2.2 피드 ViewModel

| TC-ID | ViewModel | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|-----------|--------------|-----------|----------|
| FVM-FEED-01 | FeedViewModel | 게시글 로드 | state.posts 업데이트 | P0 |
| FVM-FEED-02 | FeedViewModel | 좋아요 토글 | 해당 게시글 isLiked 변경 | P0 |
| FVM-FEED-03 | FeedViewModel | 무한 스크롤 | 다음 페이지 로드 | P0 |
| FVM-FEED-04 | FeedViewModel | 새로고침 | 첫 페이지 재로드 | P0 |

### 2.3 관리자 ViewModel

| TC-ID | ViewModel | 테스트 케이스 | 예상 결과 | 우선순위 |
|-------|-----------|--------------|-----------|----------|
| FVM-ADM-01 | AdminDashboardVM | 통계 로드 | state.stats 업데이트 | P0 |
| FVM-ADM-02 | AdminReportVM | 신고 필터링 | status별 필터링 동작 | P0 |
| FVM-ADM-03 | AdminReportVM | 신고 처리 | 상태 변경 반영 | P0 |
| FVM-ADM-04 | AdminQuestionVM | 답변 작성 | status=ANSWERED 변경 | P0 |
| FVM-ADM-05 | AdminFAQVM | FAQ 생성 | 목록에 추가 | P0 |
| FVM-ADM-06 | AdminMemberVM | 회원 제재 | status 변경 | P0 |

---

## 3. Integration 테스트

### 3.1 네비게이션 테스트

| TC-ID | 시나리오 | 시작 화면 | 예상 결과 | 우선순위 |
|-------|----------|-----------|-----------|----------|
| FI-NAV-01 | 로그인 → 홈 | LoginView | HomeView 이동 | P0 |
| FI-NAV-02 | 게시글 탭 → 상세 | FeedView | PostDetailView | P0 |
| FI-NAV-03 | 프로필 → 팔로워 | ProfileView | FollowerListView | P1 |
| FI-NAV-04 | FAQ → 문의하기 | FAQView | QuestionCreateView | P1 |
| FI-NAV-05 | 관리자 메뉴 → 신고 목록 | AdminDashboard | AdminReportListView | P1 |

### 3.2 데이터 플로우 테스트

| TC-ID | 시나리오 | 동작 | 예상 결과 | 우선순위 |
|-------|----------|------|-----------|----------|
| FI-DATA-01 | 게시글 좋아요 | 좋아요 버튼 탭 | 피드 목록에서도 반영 | P0 |
| FI-DATA-02 | 팔로우 후 피드 | 팔로우 버튼 탭 | 팔로잉 피드에 게시글 표시 | P0 |
| FI-DATA-03 | 게시글 삭제 | 삭제 확인 | 목록에서 제거 | P0 |
| FI-DATA-04 | 문의 작성 후 | 제출 완료 | 내역에 표시 | P1 |

---

## 4. E2E 테스트 시나리오

### 4.1 P0 (Critical Path)

```dart
// E2E-01: 회원가입 → 로그인 → 프로필 확인
testWidgets('User signup and login flow', (tester) async {
  // 1. 앱 시작
  await tester.pumpWidget(MyApp());

  // 2. 회원가입 화면으로 이동
  await tester.tap(find.text('회원가입'));
  await tester.pumpAndSettle();

  // 3. 정보 입력
  await tester.enterText(find.byKey(Key('email')), 'test@test.com');
  await tester.enterText(find.byKey(Key('password')), 'password123');
  await tester.enterText(find.byKey(Key('nickname')), '테스트유저');

  // 4. 가입 버튼 탭
  await tester.tap(find.text('가입하기'));
  await tester.pumpAndSettle();

  // 5. 홈 화면 확인
  expect(find.text('오늘의 노래'), findsOneWidget);

  // 6. 프로필 탭
  await tester.tap(find.byIcon(Icons.person));
  await tester.pumpAndSettle();

  // 7. 닉네임 확인
  expect(find.text('테스트유저'), findsOneWidget);
});
```

### 4.2 P1 (Important)

```dart
// E2E-04: 아티스트 검색 → 팔로우
testWidgets('Artist search and follow', (tester) async {
  // 로그인 상태에서 시작
  await tester.pumpWidget(MyApp(isLoggedIn: true));

  // 검색 탭으로 이동
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();

  // 검색어 입력
  await tester.enterText(find.byType(TextField), '요아소비');
  await tester.pumpAndSettle(Duration(milliseconds: 500));

  // 아티스트 결과 확인
  expect(find.text('YOASOBI'), findsOneWidget);

  // 아티스트 상세로 이동
  await tester.tap(find.text('YOASOBI'));
  await tester.pumpAndSettle();

  // 팔로우 버튼 탭
  await tester.tap(find.text('팔로우'));
  await tester.pumpAndSettle();

  // 팔로잉 상태 확인
  expect(find.text('팔로잉'), findsOneWidget);
});
```

---

## 5. Mock Provider 테스트 설정

### 5.1 테스트용 Provider Overrides

```dart
// test/mocks/mock_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

// Mock Repositories
class MockAdminRepository extends Mock implements AdminRepository {}
class MockPostRepository extends Mock implements PostRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

// Provider Overrides
List<Override> getTestOverrides() {
  final mockAdminRepo = MockAdminRepository();
  final mockPostRepo = MockPostRepository();

  // 기본 응답 설정
  when(mockAdminRepo.getStats()).thenAnswer(
    (_) async => AdminStats(
      totalMembers: 100,
      todayNewMembers: 5,
      pendingReports: 3,
      todayReports: 1,
      unansweredQuestions: 2,
    ),
  );

  return [
    adminRepoProvider.overrideWithValue(mockAdminRepo),
    postRepoProvider.overrideWithValue(mockPostRepo),
  ];
}

// 테스트 래퍼
Widget createTestWidget(Widget child) {
  return ProviderScope(
    overrides: getTestOverrides(),
    child: MaterialApp(home: child),
  );
}
```

### 5.2 테스트 유틸리티

```dart
// test/utils/test_utils.dart

import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExtension on WidgetTester {
  /// 로딩 상태가 끝날 때까지 대기
  Future<void> waitForLoading() async {
    await pumpAndSettle(const Duration(seconds: 5));
  }

  /// Snackbar 메시지 확인
  void expectSnackbar(String message) {
    expect(find.text(message), findsOneWidget);
  }
}
```
