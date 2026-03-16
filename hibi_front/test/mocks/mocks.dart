/// Mock 생성을 위한 설정 파일
///
/// 사용법:
/// 1. 이 파일에 @GenerateMocks에 Mock할 클래스를 추가
/// 2. 터미널에서 실행: dart run build_runner build
/// 3. 생성된 mocks.mocks.dart 파일을 import하여 사용
///
/// 예시:
/// import 'package:hidi/test/mocks/mocks.mocks.dart';
/// final mockRepo = MockAdminRepository();

import 'package:mockito/annotations.dart';

// Repositories
import 'package:hidi/features/management/repos/admin_repo.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';

// 필요한 Repository를 여기에 추가하세요
@GenerateMocks([
  AdminRepository,
  // AuthenticationRepository는 static 메서드가 많아 Mock하기 어려움
  // 필요 시 Fake 클래스를 직접 작성하세요
])
void main() {}
