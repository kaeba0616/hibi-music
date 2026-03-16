import '../models/question_models.dart';

/// Mock 문의 데이터
final List<Question> mockQuestions = [
  // 답변 완료된 문의
  Question(
    id: 1,
    memberId: 1,
    type: QuestionType.account,
    title: '로그인이 계속 안 돼요',
    content: '''앱을 다시 설치해도 로그인이 안 됩니다.
이메일은 user@example.com이고 비밀번호도 맞게 입력하고 있습니다.
확인 부탁드립니다.''',
    status: QuestionStatus.answered,
    answer: '''안녕하세요, hibi 운영팀입니다.

확인 결과, 해당 이메일로 가입된 계정이 없습니다.
다른 이메일로 가입하셨는지 확인 부탁드립니다.

혹시 소셜 로그인(Google, Apple)으로 가입하셨다면,
해당 소셜 계정으로 로그인해주세요.

추가 문의사항이 있으시면 새 문의를 작성해주세요.

감사합니다.''',
    answeredAt: DateTime(2026, 2, 2, 10, 0),
    createdAt: DateTime(2026, 2, 1, 15, 30),
    updatedAt: DateTime(2026, 2, 2, 10, 0),
  ),

  // 처리 중인 문의
  Question(
    id: 2,
    memberId: 1,
    type: QuestionType.bug,
    title: '앱이 갑자기 종료됩니다',
    content: '''아티스트 상세 화면에서 스크롤하다가 앱이 꺼집니다.
특히 YOASOBI 아티스트 페이지에서 자주 발생합니다.
iPhone 14 Pro, iOS 17.3 사용 중입니다.''',
    status: QuestionStatus.processing,
    answer: null,
    answeredAt: null,
    createdAt: DateTime(2026, 2, 2, 9, 15),
    updatedAt: DateTime(2026, 2, 2, 14, 0),
  ),

  // 접수된 문의
  Question(
    id: 3,
    memberId: 1,
    type: QuestionType.feature,
    title: '플레이리스트 기능이 있으면 좋겠어요',
    content: '''좋아하는 노래들을 모아서 나만의 플레이리스트를 만들고 싶어요.
Spotify나 Apple Music처럼 재생 기능까지는 아니더라도,
좋아하는 곡들을 카테고리별로 정리할 수 있으면 좋겠습니다.

예를 들어:
- 계절별 플레이리스트 (봄 노래, 여름 노래 등)
- 기분별 플레이리스트 (신나는 곡, 잔잔한 곡 등)
- 아티스트별 베스트 모음

검토 부탁드립니다!''',
    status: QuestionStatus.received,
    answer: null,
    answeredAt: null,
    createdAt: DateTime(2026, 2, 3, 11, 20),
    updatedAt: DateTime(2026, 2, 3, 11, 20),
  ),

  // 서비스 이용 문의 (답변 완료)
  Question(
    id: 4,
    memberId: 1,
    type: QuestionType.service,
    title: '오늘의 노래 추천 기준이 궁금해요',
    content: '''매일 추천되는 노래는 어떤 기준으로 선정되나요?
제가 좋아요 누른 곡이나 팔로우한 아티스트와 관련이 있나요?''',
    status: QuestionStatus.answered,
    answer: '''안녕하세요, hibi 운영팀입니다.

오늘의 노래는 다음 기준으로 선정됩니다:

1. 운영팀이 직접 큐레이션한 곡
2. 시즌/계절에 어울리는 곡
3. 신곡 및 화제곡
4. 사용자 반응이 좋았던 곡의 유사 곡

현재는 개인화 추천 기능이 없지만,
향후 업데이트에서 사용자 취향 기반 추천을
도입할 예정입니다.

좋은 의견 감사합니다!''',
    answeredAt: DateTime(2026, 1, 30, 14, 30),
    createdAt: DateTime(2026, 1, 29, 16, 45),
    updatedAt: DateTime(2026, 1, 30, 14, 30),
  ),

  // 기타 문의
  Question(
    id: 5,
    memberId: 1,
    type: QuestionType.other,
    title: '음악 관련 제휴 문의드립니다',
    content: '''안녕하세요, 일본 음악 관련 미디어 회사입니다.
hibi 앱과 콘텐츠 제휴 관련하여 논의하고 싶습니다.
담당자 연락처 공유 부탁드립니다.''',
    status: QuestionStatus.processing,
    answer: null,
    answeredAt: null,
    createdAt: DateTime(2026, 2, 1, 10, 0),
    updatedAt: DateTime(2026, 2, 2, 9, 0),
  ),
];

/// Mock 문의 목록 조회
List<Question> getMockQuestions({int? memberId}) {
  if (memberId != null) {
    return mockQuestions.where((q) => q.memberId == memberId).toList();
  }
  return mockQuestions;
}

/// Mock 문의 상세 조회
Question? getMockQuestionById(int id) {
  try {
    return mockQuestions.firstWhere((q) => q.id == id);
  } catch (e) {
    return null;
  }
}

/// Mock 문의 생성 (다음 ID 반환)
int _nextId = 6;

Question createMockQuestion(QuestionCreateRequest request, int memberId) {
  final now = DateTime.now();
  final question = Question(
    id: _nextId++,
    memberId: memberId,
    type: request.type,
    title: request.title,
    content: request.content,
    status: QuestionStatus.received,
    answer: null,
    answeredAt: null,
    createdAt: now,
    updatedAt: now,
  );
  mockQuestions.insert(0, question);
  return question;
}
