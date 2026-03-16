# Step 2 - Flutter Mock UI Agent

`/mock-ui` 커맨드 실행 시 Mock 데이터로 완전히 동작하는 Flutter UI를 자동 구현하는 Agent입니다.

## 목적
- UX 문서를 분석하여 Dart 모델 자동 생성
- 현실적인 Mock 데이터 생성
- Mock Provider 패턴의 Repository 구현
- Riverpod ViewModel 구현
- Flutter Widget 자동 생성

## 실행 조건

### 필수 사전조건
- [ ] Step 1 (UX Planning) 완료
- [ ] `docs/ux/features/{feature-name}-flow.md` 존재
- [ ] `docs/ux/features/{feature-name}-screens.md` 존재

### 입력
- Feature 이름: `$ARGUMENTS[0]` (예: daily-song)
- Feature ID: `$ARGUMENTS[1]` (예: f2)

## 7단계 자동 작업 프로세스

### Phase 1: UX 문서 분석
```
1. {feature-name}-flow.md 읽기
2. {feature-name}-screens.md 읽기
3. 필요한 데이터 모델 식별
4. 화면별 UI 요소 파악
```

### Phase 2: Dart 모델 생성
```
1. hibi_front/lib/features/{feature}/models/ 폴더 생성
2. 데이터 모델 클래스 작성
3. fromJson/toJson 메서드 포함
```

**생성 파일**: `lib/features/{feature}/models/{model}.dart`

```dart
class {Model} {
  final int id;
  final String title;
  final String? description;
  final DateTime createdAt;

  {Model}({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
  });

  factory {Model}.fromJson(Map<String, dynamic> json) {
    return {Model}(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };
}
```

### Phase 3: Mock 데이터 생성
```
1. hibi_front/lib/features/{feature}/mocks/ 폴더 생성
2. 현실적인 샘플 데이터 3-5개 작성
3. Empty/Error 케이스 포함
```

**생성 파일**: `lib/features/{feature}/mocks/{feature}_mock.dart`

```dart
import '../models/{model}.dart';

// 정상 케이스 (현실적인 데이터!)
final List<{Model}> mock{Model}s = [
  {Model}(
    id: 1,
    title: 'YOASOBI - 夜に駆ける',
    description: '2019년 발매된 YOASOBI의 대표곡',
    createdAt: DateTime(2026, 2, 3),
  ),
  {Model}(
    id: 2,
    title: '아이유 - 밤편지',
    description: '2017년 발매',
    createdAt: DateTime(2026, 2, 2),
  ),
  // 3-5개 샘플
];

// Empty 케이스
final List<{Model}> emptyMock{Model}s = [];

// 지연 시뮬레이션 (로딩 상태 테스트용)
Future<List<{Model}>> getMock{Model}sWithDelay() async {
  await Future.delayed(const Duration(milliseconds: 500));
  return mock{Model}s;
}

// 에러 시뮬레이션
Future<List<{Model}>> getMock{Model}sWithError() async {
  await Future.delayed(const Duration(milliseconds: 300));
  throw Exception('네트워크 오류가 발생했습니다');
}
```

### Phase 4: Repository 생성 (Mock Provider 패턴)
```
1. hibi_front/lib/features/{feature}/repos/ 폴더 생성
2. Mock/Real 전환 가능한 Repository 작성
```

**생성 파일**: `lib/features/{feature}/repos/{feature}_repo.dart`

```dart
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
    // Real API는 Step 4에서 구현
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

  Future<void> create({Model} model) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _dio.post('/api/v1/{feature}s', data: model.toJson());
  }

  Future<void> delete(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    await _dio.delete('/api/v1/{feature}s/$id');
  }
}
```

### Phase 5: Riverpod ViewModel 생성
```
1. hibi_front/lib/features/{feature}/viewmodels/ 폴더 생성
2. StateNotifier 기반 ViewModel 작성
3. Provider 정의
```

**생성 파일**: `lib/features/{feature}/viewmodels/{feature}_viewmodel.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/{feature}_repo.dart';
import '../models/{model}.dart';

// Repository Provider
final {feature}RepoProvider = Provider<{Feature}Repository>((ref) {
  final dio = ref.watch(dioProvider);
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return {Feature}Repository(dio: dio, useMock: useMock);
});

// State
class {Feature}State {
  final List<{Model}> items;
  final bool isLoading;
  final String? error;
  final {Model}? selectedItem;

  const {Feature}State({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedItem,
  });

  {Feature}State copyWith({
    List<{Model}>? items,
    bool? isLoading,
    String? error,
    {Model}? selectedItem,
  }) => {Feature}State(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    selectedItem: selectedItem ?? this.selectedItem,
  );

  bool get isEmpty => items.isEmpty && !isLoading && error == null;
  bool get hasError => error != null;
}

// ViewModel
class {Feature}ViewModel extends StateNotifier<{Feature}State> {
  final {Feature}Repository _repo;

  {Feature}ViewModel(this._repo) : super(const {Feature}State());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.getAll();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadById(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final item = await _repo.getById(id);
      state = state.copyWith(selectedItem: item, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final {feature}ViewModelProvider =
    StateNotifierProvider<{Feature}ViewModel, {Feature}State>((ref) {
  final repo = ref.watch({feature}RepoProvider);
  return {Feature}ViewModel(repo);
});
```

### Phase 6: Flutter Widget 생성
```
1. hibi_front/lib/features/{feature}/views/ 폴더 생성
2. Screens 문서 기반 Widget 작성
3. 모든 상태 UI 구현
```

**생성 파일**: `lib/features/{feature}/views/{feature}_screen.dart`

```dart
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
      appBar: AppBar(
        title: const Text('{Feature}'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody({Feature}State state) {
    // Loading
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (state.hasError) {
      return _buildErrorState(state.error!);
    }

    // Empty
    if (state.isEmpty) {
      return _buildEmptyState();
    }

    // Success
    return _buildListView(state.items);
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('오류가 발생했습니다', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(error, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text('데이터가 없습니다', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildListView(List<dynamic> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.description ?? ''),
          onTap: () {
            // Navigate to detail
          },
        );
      },
    );
  }
}
```

### Phase 7: Widget 테스트 작성
```
1. test/features/{feature}/ 폴더 생성
2. Widget 테스트 작성
```

**생성 파일**: `test/features/{feature}/{feature}_screen_test.dart`

## 중요 원칙

### 필수 준수
- Real API 호출 금지 (Mock만 사용)
- 현실적인 데이터 사용 ("test1" X, "아이유 - 밤편지" O)
- 모든 상태 UI 구현 (Loading, Empty, Error, Success)
- Mock Provider 패턴 적용

### 금지사항
- 하드코딩된 더미 데이터
- Real API 직접 호출
- 상태 UI 누락
- 임시 코드

## 완료 조건
- [ ] 모델 클래스 생성
- [ ] Mock 데이터 생성 (3-5개)
- [ ] Repository 생성 (Mock Provider 패턴)
- [ ] ViewModel 생성 (Riverpod)
- [ ] Widget 생성 (모든 상태 UI)
- [ ] Widget 테스트 작성
- [ ] `flutter test` 성공

## 완료 후
사용자에게 검토 요청 후 승인을 받고 Step 3 (JPA Entity Design)으로 진행합니다.
