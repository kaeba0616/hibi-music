# Phase 3: Advanced Features 계획

## 개요
- Phase ID: 3
- Phase 이름: Advanced Features
- Status: [status: completed]
- 목표: 고급 기능 및 관리자 도구

---

## Features 상세

### F9: FAQ (자주 묻는 질문) [status: completed]

#### 설명
사용자가 서비스 이용 중 궁금한 점을 쉽게 해결할 수 있는 FAQ 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 관련 파일
- UX 문서: `docs/ux/features/faq-flow.md`, `faq-screens.md`
- Frontend: `hibi_front/lib/features/faq/`
  - models/faq_models.dart - FAQ, FAQCategory 모델
  - mocks/faq_mock.dart - Mock FAQ 데이터 (14개 샘플)
  - repos/faq_repo.dart - Repository (Mock Provider 패턴 + Real API)
  - viewmodels/faq_viewmodel.dart - FAQViewModel (검색, 필터, 확장 상태)
  - widgets/faq_search_bar.dart - 검색창 위젯
  - widgets/faq_category_tabs.dart - 카테고리 탭 위젯
  - widgets/faq_category_header.dart - 카테고리 헤더 위젯
  - widgets/faq_item_tile.dart - FAQ 항목 위젯 (아코디언)
  - widgets/faq_empty_view.dart - Empty/Error View 위젯
  - widgets/faq_contact_card.dart - 문의하기 유도 카드 위젯
  - views/faq_view.dart - FAQ 메인 화면 (FA-01)
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/faq/`
  - entity/FAQCategory.java - FAQ 카테고리 Enum
  - entity/FAQ.java - FAQ JPA Entity
  - repository/FAQRepository.java - Spring Data JPA Repository
  - dto/response/FAQResponse.java - FAQ 응답 DTO
  - dto/response/FAQListResponse.java - FAQ 목록 응답 DTO
  - service/FAQService.java - FAQ 서비스
  - controller/FAQController.java - FAQ REST 컨트롤러
- API 문서: `docs/tech/api-spec.md` 섹션 10 참조
- DB Schema 문서: `docs/tech/db-schema.md` 섹션 14 참조

---

### F10: Question (문의하기) [status: completed]

#### 설명
FAQ에서 해결되지 않은 문의사항을 직접 보내는 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 관련 파일
- UX 문서: `docs/ux/features/question-flow.md`, `question-screens.md`
- PRD AC 정의: `docs/product/prd-main.md` 섹션 3.6 F10
- Frontend: `hibi_front/lib/features/question/`
  - models/question_models.dart - Question, QuestionType, QuestionStatus 모델
  - mocks/question_mock.dart - Mock 문의 데이터 (5개 샘플)
  - repos/question_repo.dart - Repository (Mock Provider 패턴)
  - viewmodels/question_viewmodel.dart - QuestionListViewModel, QuestionFormViewModel
  - widgets/question_type_selector.dart - 유형 선택 위젯
  - widgets/question_status_badge.dart - 상태 뱃지 위젯
  - widgets/question_list_tile.dart - 목록 항목 위젯
  - widgets/question_empty_view.dart - Empty/Error View 위젯
  - widgets/question_answer_card.dart - 답변 카드 위젯
  - widgets/login_required_dialog.dart - 로그인 필요 다이얼로그
  - views/question_create_view.dart - QU-01 문의 작성 화면
  - views/question_complete_view.dart - QU-02 제출 완료 화면
  - views/question_history_view.dart - QU-03 문의 내역 화면
  - views/question_detail_view.dart - QU-04 문의 상세 화면
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/question/`
  - entity/QuestionType.java - 문의 유형 Enum
  - entity/QuestionStatus.java - 문의 상태 Enum
  - entity/Question.java - Question JPA Entity
  - repository/QuestionRepository.java - Spring Data JPA Repository
- DB Schema 문서: `docs/tech/db-schema.md` 섹션 15 참조
  - dto/request/QuestionCreateRequest.java - 문의 생성 요청 DTO
  - dto/response/QuestionResponse.java - 문의 응답 DTO
  - dto/response/QuestionListResponse.java - 문의 목록 응답 DTO
  - service/QuestionService.java - 문의 서비스
  - controller/QuestionController.java - 문의 REST 컨트롤러
- API 문서: `docs/tech/api-spec.md` 섹션 11 참조

---

### F11: Report (신고) [status: completed]

#### 설명
부적절한 게시글/댓글/사용자를 신고하는 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 관련 파일
- UX 문서: `docs/ux/features/report-flow.md`, `report-screens.md`
- PRD AC 정의: `docs/product/prd-main.md` 섹션 3.6 F11
- Frontend: `hibi_front/lib/features/report/`
  - models/report_models.dart - Report, ReportTargetType, ReportReason, ReportStatus 모델
  - mocks/report_mock.dart - Mock 신고 데이터 (5개 샘플)
  - repos/report_repo.dart - Repository (Mock Provider 패턴 + Real API)
  - viewmodels/report_viewmodel.dart - ReportFormViewModel
  - widgets/report_reason_tile.dart - 신고 사유 선택 타일
  - widgets/report_description_field.dart - 상세 내용 입력 필드
  - widgets/report_submit_button.dart - 제출 버튼
  - widgets/report_success_dialog.dart - RP-02 신고 완료 다이얼로그
  - widgets/report_duplicate_dialog.dart - 중복 신고 안내 다이얼로그
  - widgets/more_menu_helper.dart - 더보기 메뉴 헬퍼 (게시글/댓글/프로필)
  - views/report_bottom_sheet.dart - RP-01 신고 바텀시트
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/report/`
  - entity/ReportTargetType.java - 신고 대상 유형 Enum
  - entity/ReportReason.java - 신고 사유 Enum
  - entity/ReportStatus.java - 신고 상태 Enum
  - entity/Report.java - Report JPA Entity
  - repository/ReportRepository.java - Spring Data JPA Repository
  - dto/request/ReportCreateRequest.java - 신고 생성 요청 DTO
  - dto/response/ReportResponse.java - 신고 응답 DTO
  - dto/response/ReportCheckResponse.java - 중복 신고 여부 응답 DTO
  - service/ReportService.java - 신고 서비스
  - controller/ReportController.java - 신고 REST 컨트롤러
- API 문서: `docs/tech/api-spec.md` 섹션 12 참조
- DB Schema 문서: `docs/tech/db-schema.md` 섹션 17 참조

---

### F12: Management (관리자 기능) [status: completed]

#### 설명
관리자용 대시보드 및 콘텐츠 관리 기능

#### Step 완료 현황
- [x] Step 1: UX Planning
- [x] Step 2: Flutter Mock UI
- [x] Step 3: JPA Entity Design
- [x] Step 4: Spring Boot API

#### 관련 파일
- UX 문서: `docs/ux/features/management-flow.md`, `management-screens.md`
- PRD AC 정의: `docs/product/prd-main.md` 섹션 3.6 F12
- Frontend: `hibi_front/lib/features/management/`
  - models/admin_models.dart - AdminStats, MemberStatus, MemberRole, AdminMemberInfo 모델
  - models/admin_report_models.dart - AdminReportDetail, ReportAction 모델
  - models/admin_question_models.dart - AdminQuestionItem, QuestionAnswerRequest 모델
  - models/admin_faq_models.dart - AdminFAQItem, FAQSaveRequest 모델
  - mocks/admin_mock.dart - Mock 관리자 데이터
  - repos/admin_repo.dart - Repository (Mock Provider 패턴 + Real API)
  - viewmodels/admin_dashboard_viewmodel.dart - 대시보드 ViewModel
  - viewmodels/admin_report_viewmodel.dart - 신고 관리 ViewModel
  - viewmodels/admin_question_viewmodel.dart - 문의 관리 ViewModel
  - viewmodels/admin_faq_viewmodel.dart - FAQ 관리 ViewModel
  - viewmodels/admin_member_viewmodel.dart - 회원 관리 ViewModel
  - widgets/admin_stat_card.dart - 통계 카드 위젯
  - widgets/admin_menu_tile.dart - 메뉴 타일 위젯
  - widgets/status_badge.dart - 상태 뱃지 위젯들
  - widgets/admin_report_tile.dart - 신고 목록 타일
  - widgets/admin_question_tile.dart - 문의 목록 타일
  - widgets/admin_faq_tile.dart - FAQ 목록 타일
  - widgets/admin_member_tile.dart - 회원 목록 타일
  - widgets/filter_chip_bar.dart - 필터 칩 바
  - widgets/action_dialog.dart - 액션 다이얼로그들
  - views/admin_dashboard_view.dart - MG-01 대시보드 화면
  - views/admin_report_list_view.dart - MG-02 신고 목록 화면
  - views/admin_report_detail_view.dart - MG-03 신고 상세 화면
  - views/admin_question_list_view.dart - MG-04 문의 목록 화면
  - views/admin_question_detail_view.dart - MG-05 문의 상세/답변 화면
  - views/admin_faq_list_view.dart - MG-06 FAQ 목록 화면
  - views/admin_faq_edit_view.dart - MG-07 FAQ 편집 화면
  - views/admin_member_list_view.dart - MG-08 회원 목록 화면
  - views/admin_member_detail_view.dart - MG-09 회원 상세 화면
- Backend: `hibi_backend/src/main/java/com/hibi/server/domain/admin/`
  - dto/request/MemberSanctionRequest.java - 회원 제재 요청 DTO
  - dto/request/ReportActionRequest.java - 신고 처리 요청 DTO
  - dto/request/QuestionAnswerRequest.java - 문의 답변 요청 DTO
  - dto/request/FAQSaveRequest.java - FAQ 저장 요청 DTO
  - dto/response/AdminStatsResponse.java - 대시보드 통계 응답 DTO
  - dto/response/AdminMemberResponse.java - 회원 상세 응답 DTO
  - dto/response/AdminMemberListResponse.java - 회원 목록 응답 DTO
  - dto/response/AdminReportResponse.java - 신고 상세 응답 DTO
  - dto/response/AdminReportTargetContent.java - 신고 대상 콘텐츠 DTO
  - dto/response/AdminReportListResponse.java - 신고 목록 응답 DTO
  - dto/response/AdminQuestionResponse.java - 문의 상세 응답 DTO
  - dto/response/AdminQuestionListResponse.java - 문의 목록 응답 DTO
  - dto/response/AdminFAQResponse.java - FAQ 응답 DTO
  - dto/response/AdminFAQListResponse.java - FAQ 목록 응답 DTO
  - service/AdminService.java - 관리자 서비스
  - controller/AdminController.java - 관리자 REST 컨트롤러 (@PreAuthorize ADMIN)
- Backend 확장: 기존 Entity/Repository 확장
  - entity/MemberStatus.java - 회원 상태 Enum (ACTIVE, SUSPENDED, BANNED)
  - Member.java 확장 - status, suspendedUntil, suspendedReason 필드 추가
  - Report.java 확장 - adminNote, resolvedAt, resolvedBy 필드 추가
  - MemberRepository.java 확장 - 관리자용 쿼리 메서드 추가
  - ReportRepository.java 확장 - 관리자용 쿼리 메서드 추가
  - QuestionRepository.java 확장 - 관리자용 쿼리 메서드 추가
  - FAQRepository.java 확장 - 관리자용 쿼리 메서드 추가
  - CommentRepository.java 확장 - countByMemberId() 추가
  - MemberFollowRepository.java 확장 - countByFollowingId(), countByFollowerId() 추가
- API 문서: `docs/tech/api-spec.md` 섹션 13 참조
- DB Schema 문서: `docs/tech/db-schema.md` 섹션 19 참조

---

## Phase 3 진행률

| Feature | Step 1 | Step 2 | Step 3 | Step 4 | Status |
|---------|--------|--------|--------|--------|--------|
| F9: FAQ | Done | Done | Done | Done | **completed** |
| F10: Question | Done | Done | Done | Done | **completed** |
| F11: Report | Done | Done | Done | Done | **completed** |
| F12: Management | Done | Done | Done | Done | **completed** |

**Phase 3 진행률**: 4/4 Features (100%) - Phase 3 완료!
