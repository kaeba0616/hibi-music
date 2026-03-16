import '../models/faq_models.dart';

/// Mock FAQ 데이터
final List<FAQ> mockFAQs = [
  // 계정 관련 FAQ
  FAQ(
    id: 1,
    question: '비밀번호를 잊어버렸어요. 어떻게 해야 하나요?',
    answer: '로그인 화면에서 "비밀번호 찾기"를 탭하면 가입하신 이메일로 비밀번호 재설정 링크가 발송됩니다. 메일함을 확인해주세요. 메일이 오지 않는 경우 스팸함을 확인하시거나 고객센터로 문의해주세요.',
    category: FAQCategory.account,
    order: 1,
    createdAt: DateTime(2024, 1, 1),
  ),
  FAQ(
    id: 2,
    question: '회원 탈퇴는 어떻게 하나요?',
    answer: '설정 > 계정 관리 > 회원 탈퇴에서 탈퇴할 수 있습니다. 탈퇴 시 작성한 게시글과 댓글은 삭제되며, 복구가 불가능합니다. 탈퇴 후 30일 이내에는 같은 이메일로 재가입이 제한됩니다.',
    category: FAQCategory.account,
    order: 2,
    createdAt: DateTime(2024, 1, 1),
  ),
  FAQ(
    id: 3,
    question: '닉네임을 변경하고 싶어요.',
    answer: '프로필 > 프로필 편집에서 닉네임을 변경할 수 있습니다. 닉네임은 2~20자 이내로 설정 가능하며, 이미 사용 중인 닉네임은 사용할 수 없습니다.',
    category: FAQCategory.account,
    order: 3,
    createdAt: DateTime(2024, 1, 5),
  ),

  // 서비스 이용 관련 FAQ
  FAQ(
    id: 4,
    question: '오늘의 노래는 언제 업데이트되나요?',
    answer: '오늘의 노래는 매일 자정(한국 시간, KST 00:00)에 업데이트됩니다. 새로운 하루가 시작될 때 새로운 JPOP 한 곡이 추천됩니다. 알림 설정을 켜두시면 새 곡이 추천될 때 푸시 알림을 받으실 수 있습니다.',
    category: FAQCategory.service,
    order: 1,
    createdAt: DateTime(2024, 1, 1),
  ),
  FAQ(
    id: 5,
    question: '좋아요한 노래는 어디서 확인하나요?',
    answer: '캘린더 탭에서 "좋아요만" 필터를 적용하면 좋아요 표시한 노래만 모아볼 수 있습니다. 또는 프로필 > 좋아요한 노래에서도 확인 가능합니다.',
    category: FAQCategory.service,
    order: 2,
    createdAt: DateTime(2024, 1, 3),
  ),
  FAQ(
    id: 6,
    question: '과거 추천곡을 다시 볼 수 있나요?',
    answer: '네, 캘린더 탭에서 지난 날짜를 선택하면 해당 날짜에 추천되었던 곡을 확인할 수 있습니다. 월별로 이동하며 히스토리를 살펴보세요.',
    category: FAQCategory.service,
    order: 3,
    createdAt: DateTime(2024, 1, 5),
  ),
  FAQ(
    id: 7,
    question: '아티스트를 팔로우하면 어떤 기능이 있나요?',
    answer: '아티스트를 팔로우하면 해당 아티스트의 노래가 추천될 때 알림을 받을 수 있습니다. 또한 아티스트 탭에서 "팔로우 중" 필터로 관심 아티스트만 모아볼 수 있습니다.',
    category: FAQCategory.service,
    order: 4,
    createdAt: DateTime(2024, 1, 10),
  ),

  // 커뮤니티 관련 FAQ
  FAQ(
    id: 8,
    question: '게시글은 어떻게 작성하나요?',
    answer: '피드 탭 우측 하단의 + 버튼을 탭하면 게시글 작성 화면으로 이동합니다. 텍스트와 이미지(최대 4장)를 첨부할 수 있으며, 노래 태그 기능으로 추천곡을 함께 공유할 수 있습니다.',
    category: FAQCategory.community,
    order: 1,
    createdAt: DateTime(2024, 1, 1),
  ),
  FAQ(
    id: 9,
    question: '게시글에 노래를 태그하려면 어떻게 하나요?',
    answer: '게시글 작성 화면에서 음표 아이콘을 탭하면 노래 검색 창이 나타납니다. 원하는 노래를 검색하여 선택하면 게시글에 노래 정보가 첨부됩니다.',
    category: FAQCategory.community,
    order: 2,
    createdAt: DateTime(2024, 1, 5),
  ),
  FAQ(
    id: 10,
    question: '댓글에 답글을 달 수 있나요?',
    answer: '네, 댓글에 답글(대댓글)을 달 수 있습니다. 댓글 하단의 "답글" 버튼을 탭하면 해당 댓글에 대한 답글을 작성할 수 있습니다. 대댓글은 1단계까지 지원됩니다.',
    category: FAQCategory.community,
    order: 3,
    createdAt: DateTime(2024, 1, 8),
  ),
  FAQ(
    id: 11,
    question: '다른 사용자를 팔로우하면 무엇이 달라지나요?',
    answer: '사용자를 팔로우하면 피드에서 "팔로잉" 필터를 적용했을 때 해당 사용자의 게시글만 모아볼 수 있습니다. 팔로우한 사용자의 새 게시글 알림도 받을 수 있습니다.',
    category: FAQCategory.community,
    order: 4,
    createdAt: DateTime(2024, 1, 12),
  ),

  // 기타 FAQ
  FAQ(
    id: 12,
    question: '앱 버전은 어디서 확인하나요?',
    answer: '설정 > 앱 정보에서 현재 설치된 앱 버전을 확인할 수 있습니다. 최신 버전이 아닌 경우 앱 스토어에서 업데이트해주세요.',
    category: FAQCategory.other,
    order: 1,
    createdAt: DateTime(2024, 1, 1),
  ),
  FAQ(
    id: 13,
    question: '오류가 발생했을 때 어떻게 해야 하나요?',
    answer: '먼저 앱을 종료 후 다시 실행해보세요. 문제가 지속되면 설정 > 문의하기에서 오류 내용과 함께 문의해주시면 빠르게 도움드리겠습니다. 스크린샷을 첨부해주시면 더욱 정확한 해결이 가능합니다.',
    category: FAQCategory.other,
    order: 2,
    createdAt: DateTime(2024, 1, 3),
  ),
  FAQ(
    id: 14,
    question: '서비스 이용약관은 어디서 볼 수 있나요?',
    answer: '설정 > 약관 및 정책에서 서비스 이용약관, 개인정보 처리방침 등을 확인하실 수 있습니다.',
    category: FAQCategory.other,
    order: 3,
    createdAt: DateTime(2024, 1, 5),
  ),
];

/// 카테고리별로 그룹화된 FAQ 조회
Map<FAQCategory, List<FAQ>> getGroupedFAQs({
  FAQCategory? category,
  String? keyword,
}) {
  List<FAQ> filteredFAQs = mockFAQs.where((faq) => faq.isPublished).toList();

  // 카테고리 필터
  if (category != null && category != FAQCategory.all) {
    filteredFAQs = filteredFAQs.where((faq) => faq.category == category).toList();
  }

  // 키워드 필터
  if (keyword != null && keyword.isNotEmpty) {
    filteredFAQs = filteredFAQs.where((faq) => faq.matchesKeyword(keyword)).toList();
  }

  // 정렬
  filteredFAQs.sort((a, b) {
    if (a.category != b.category) {
      return a.category.index.compareTo(b.category.index);
    }
    return a.order.compareTo(b.order);
  });

  // 그룹화
  final Map<FAQCategory, List<FAQ>> grouped = {};
  for (final faq in filteredFAQs) {
    grouped.putIfAbsent(faq.category, () => []);
    grouped[faq.category]!.add(faq);
  }

  return grouped;
}

/// FAQ 목록 조회 (flat)
List<FAQ> getFAQList({
  FAQCategory? category,
  String? keyword,
}) {
  List<FAQ> filteredFAQs = mockFAQs.where((faq) => faq.isPublished).toList();

  // 카테고리 필터
  if (category != null && category != FAQCategory.all) {
    filteredFAQs = filteredFAQs.where((faq) => faq.category == category).toList();
  }

  // 키워드 필터
  if (keyword != null && keyword.isNotEmpty) {
    filteredFAQs = filteredFAQs.where((faq) => faq.matchesKeyword(keyword)).toList();
  }

  // 정렬
  filteredFAQs.sort((a, b) {
    if (a.category != b.category) {
      return a.category.index.compareTo(b.category.index);
    }
    return a.order.compareTo(b.order);
  });

  return filteredFAQs;
}
