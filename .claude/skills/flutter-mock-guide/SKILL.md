# Flutter Mock Guide Skill

Step 2: Flutter Mock UI 구현의 상세 가이드입니다.

## 트리거
`/mock-ui <feature-name> <feature-id>` 커맨드 실행 시

## 전제조건
- Step 1 (UX Planning) 완료
- `docs/ux/features/{feature-name}-flow.md` 존재
- `docs/ux/features/{feature-name}-screens.md` 존재

## 체크리스트

### Phase 1: UX 문서 분석
- [ ] Flow 문서에서 AC 확인
- [ ] Screens 문서에서 화면 구조 확인
- [ ] UI 요소 및 상태 파악

### Phase 2: Dart 모델 생성
- [ ] `hibi_front/lib/features/{feature}/models/` 폴더 생성
- [ ] 데이터 모델 클래스 작성

**모델 템플릿**:
```dart
// lib/features/{feature}/models/{model}.dart

class {Model} {
  final int id;
  final String name;
  final DateTime createdAt;

  {Model}({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory {Model}.fromJson(Map<String, dynamic> json) {
    return {Model}(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```

### Phase 3: Mock 데이터 생성
- [ ] `hibi_front/lib/features/{feature}/mocks/` 폴더 생성
- [ ] 현실적인 샘플 데이터 3-5개 작성
- [ ] Empty 케이스용 빈 리스트 포함
- [ ] Error 케이스용 예외 시뮬레이션 포함

**Mock 데이터 템플릿**:
```dart
// lib/features/{feature}/mocks/{feature}_mock.dart

import '../models/{model}.dart';

// 정상 케이스
final List<{Model}> mock{Model}s = [
  {Model}(
    id: 1,
    name: '아이유 - 밤편지',  // 현실적인 데이터
    createdAt: DateTime(2026, 2, 3),
  ),
  {Model}(
    id: 2,
    name: 'YOASOBI - 夜に駆ける',
    createdAt: DateTime(2026, 2, 2),
  ),
  // 3-5개 샘플
];

// Empty 케이스
final List<{Model}> emptyMock{Model}s = [];

// 지연 시뮬레이션
Future<List<{Model}>> getMock{Model}sWithDelay() async {
  await Future.delayed(const Duration(milliseconds: 500));
  return mock{Model}s;
}
```

### Phase 4: Repository 작성 (Mock Provider 패턴)
- [ ] `hibi_front/lib/features/{feature}/repos/` 폴더 생성
- [ ] Mock/Real 전환 가능한 Repository 작성

**Repository 템플릿**:
```dart
// lib/features/{feature}/repos/{feature}_repo.dart

import 'package:dio/dio.dart';
import '../models/{model}.dart';
import '../mocks/{feature}_mock.dart';

class {Feature}Repository {
  final Dio _dio;
  final bool useMock;

  {Feature}Repository({
    required Dio dio,
    this.useMock = false,
  }) : _dio = dio;

  Future<List<{Model}>> getAll() async {
    if (useMock) {
      return getMock{Model}sWithDelay();
    }

    // Real API (Step 4에서 구현)
    final response = await _dio.get('/api/v1/{feature}s');
    return (response.data['data'] as List)
        .map((e) => {Model}.fromJson(e))
        .toList();
  }

  Future<{Model}> getById(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mock{Model}s.firstWhere((e) => e.id == id);
    }

    final response = await _dio.get('/api/v1/{feature}s/$id');
    return {Model}.fromJson(response.data['data']);
  }

  Future<void> create({Model}CreateRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _dio.post('/api/v1/{feature}s', data: request.toJson());
  }
}
```

### Phase 5: Riverpod Provider 정의
- [ ] Repository Provider 정의
- [ ] ViewModel/StateNotifier 작성

**Provider 템플릿**:
```dart
// lib/features/{feature}/viewmodels/{feature}_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/{feature}_repo.dart';
import '../models/{model}.dart';

// Repository Provider
final {feature}RepoProvider = Provider<{Feature}Repository>((ref) {
  final dio = ref.watch(dioProvider);
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'false') == 'true';
  return {Feature}Repository(dio: dio, useMock: useMock);
});

// State
class {Feature}State {
  final List<{Model}> items;
  final bool isLoading;
  final String? error;

  {Feature}State({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  {Feature}State copyWith({
    List<{Model}>? items,
    bool? isLoading,
    String? error,
  }) {
    return {Feature}State(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ViewModel
class {Feature}ViewModel extends StateNotifier<{Feature}State> {
  final {Feature}Repository _repo;

  {Feature}ViewModel(this._repo) : super({Feature}State());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.getAll();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// ViewModel Provider
final {feature}ViewModelProvider =
    StateNotifierProvider<{Feature}ViewModel, {Feature}State>((ref) {
  final repo = ref.watch({feature}RepoProvider);
  return {Feature}ViewModel(repo);
});
```

### Phase 6: Flutter Widget 구현
- [ ] `hibi_front/lib/features/{feature}/views/` 폴더 생성
- [ ] 화면별 Widget 작성
- [ ] 상태별 UI (Loading, Empty, Error, Success) 구현

**Widget 템플릿**:
```dart
// lib/features/{feature}/views/{feature}_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/{feature}_viewmodel.dart';

class {Feature}Screen extends ConsumerStatefulWidget {
  const {Feature}Screen({super.key});

  @override
  ConsumerState<{Feature}Screen> createState() => _{Feature}ScreenState();
}

class _{Feature}ScreenState extends ConsumerState<{Feature}Screen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read({feature}ViewModelProvider.notifier).loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch({feature}ViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('{Feature}')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody({Feature}State state) {
    // Loading
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류: ${state.error}'),
            ElevatedButton(
              onPressed: () {
                ref.read({feature}ViewModelProvider.notifier).loadAll();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // Empty
    if (state.items.isEmpty) {
      return const Center(
        child: Text('데이터가 없습니다'),
      );
    }

    // Success
    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text(item.createdAt.toString()),
        );
      },
    );
  }
}
```

### Phase 7: Widget 테스트 작성
- [ ] `hibi_front/test/features/{feature}/` 폴더 생성
- [ ] Widget 테스트 작성

**테스트 템플릿**:
```dart
// test/features/{feature}/{feature}_screen_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hibi_front/features/{feature}/views/{feature}_screen.dart';

void main() {
  group('{Feature}Screen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: {Feature}Screen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows data after loading', (tester) async {
      // Mock Provider override 테스트
    });
  });
}
```

## 중요 원칙
- Real API 호출 금지 (Mock만 사용)
- 현실적인 데이터 사용 ("test1" X, "아이유 - 밤편지" O)
- 모든 상태 UI 구현 필수

## 완료 기준
- [ ] 모델 클래스 생성
- [ ] Mock 데이터 생성 (3-5개)
- [ ] Repository 생성 (Mock Provider 패턴)
- [ ] ViewModel 생성 (Riverpod)
- [ ] Widget 생성 (모든 상태 UI)
- [ ] Widget 테스트 작성 및 통과
- [ ] `flutter test` 성공

## 다음 단계
사용자 승인 후 `/design-db {feature-name} {feature-id}`로 진행
