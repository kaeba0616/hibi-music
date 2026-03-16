# /mock-ui - Flutter Mock UI (Step 2)

Mock 데이터로 완전히 동작하는 Flutter UI를 구현합니다.

## 사용법
```
/mock-ui <feature-name> <feature-id>
```

## 실행 방법
`flutter-mock-guide` 스킬을 통해 수동 모드로 진행합니다.

## 전제조건
- Step 1 (UX Planning) 완료
- `docs/ux/features/<feature>-flow.md` 존재
- `docs/ux/features/<feature>-screens.md` 존재

## 입력 문서
- UX Flow 문서
- Screens 문서

## 생성 파일
```
hibi_front/lib/features/<feature>/
├── models/<model>.dart           # Dart 데이터 모델
├── mocks/<feature>_mock.dart     # Mock 데이터 (3-5개 샘플)
├── repos/<feature>_repo.dart     # Repository (Mock Provider 패턴)
├── viewmodels/<feature>_viewmodel.dart  # Riverpod ViewModel
└── views/<view>.dart             # Flutter Widget
```

## 7단계 작업 프로세스
1. **UX 문서 분석**: Flow와 화면 사양 파악
2. **Dart 모델 생성**: TypeScript 스타일의 클래스 정의
3. **Mock 데이터 생성**: 현실적인 샘플 데이터 (정상/Empty/에러 케이스)
4. **Repository 작성**: Mock Provider 패턴 적용
5. **ViewModel 작성**: Riverpod StateNotifier/AsyncNotifier
6. **Flutter Widget 구현**: Material Design 기반
7. **테스트 작성**: Widget 테스트

## Mock Provider 패턴
```dart
class FeatureRepository {
  final bool useMock;

  Future<List<Model>> getAll() async {
    if (useMock) return mockData;
    // Real API는 Step 4에서 구현
  }
}

final featureRepoProvider = Provider((ref) {
  final useMock = const String.fromEnvironment('USE_MOCK') == 'true';
  return FeatureRepository(useMock: useMock);
});
```

## 중요 원칙
- Real API 구현 금지 (Mock만 사용)
- 현실적인 데이터 사용 ("테스트1" X, "아이유 - 밤편지" O)
- 모든 상태(Loading, Empty, Error) UI 구현

## 완료 조건
- [ ] Mock 데이터로 모든 화면 동작
- [ ] 모든 UI 상태 구현
- [ ] Widget 테스트 작성 및 통과

## 다음 단계
완료 후 사용자 승인을 받고 `/design-db`로 진행합니다.
