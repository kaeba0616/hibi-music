# F18: 관리자 기능 강화 - 화면 구조

## AE-01: 곡 등록 폼 (Enhanced Song Registration)

### 레이아웃
- AppBar: "곡 등록" 타이틀, 뒤로가기 버튼
- ScrollView (SingleChildScrollView)

### UI 요소
1. **제목 섹션**
   - TextFormField: 한국어 제목 (필수)
   - TextFormField: 영어 제목
   - TextFormField: 일본어 제목 (필수)

2. **아티스트 섹션**
   - Autocomplete TextField: 아티스트 이름 검색
   - 검색 결과 드롭다운 (기존 아티스트 목록)

3. **스토리 섹션**
   - TextFormField (multiline, maxLines: 5): 추천 이유/스토리

4. **가사 섹션**
   - TabBar: "일본어" | "한국어"
   - TabBarView:
     - TextFormField (multiline, maxLines: 10): 일본어 가사
     - TextFormField (multiline, maxLines: 10): 한국어 가사

5. **YouTube URL 섹션**
   - TextFormField: YouTube URL
   - URL 유효성 검사 아이콘

6. **연관곡 섹션**
   - "연관곡 추가" 버튼
   - 추가된 연관곡 리스트 (Card 형태)
     - 곡 제목 + 아티스트
     - 선정 이유 TextField
     - 삭제 버튼 (X)
   - 연관곡 검색 BottomSheet (검색 → 선택)

7. **액션 버튼**
   - FilledButton: "저장"
   - OutlinedButton: "취소"

---

## AE-02: 예약 게시 (Scheduled Publishing)

### 레이아웃
- AppBar: "예약 게시" 타이틀
- TabBar: "예약 등록" | "예약 목록"

### 예약 등록 탭
1. **곡 선택 섹션**
   - DropdownButton 또는 검색 가능한 곡 선택
   - 선택된 곡 요약 Card (제목, 아티스트, 등록 상태)

2. **일시 선택 섹션**
   - DatePicker: 게시 날짜 선택
   - TimePicker: 게시 시간 선택
   - 선택된 일시 표시 Text

3. **미리보기 섹션**
   - Card: 곡 정보 요약 (제목, 아티스트, 가사 유무, YouTube 유무)
   - 완성도 표시 (필수 항목 체크리스트)

4. **액션 버튼**
   - FilledButton: "예약 게시" (곡 미완성 시 disabled + 안내 문구)

### 예약 목록 탭
- ListView: 예약된 곡 목록
  - Card: 곡 제목, 예약 일시, 게시 상태 (대기/게시됨)
  - 예약 취소 버튼 (대기 상태만)

---

## AE-03: 댓글 관리 (Admin Comment Management)

### 레이아웃
- AppBar: "댓글 관리" 타이틀
- FilterChipBar: "전체" | "신고된 댓글"

### UI 요소
1. **댓글 목록**
   - ListView (페이지네이션)
   - 각 아이템 Card:
     - Row: 작성자 닉네임 + 작성일
     - Text: 댓글 내용 (최대 2줄, overflow ellipsis)
     - Text: 게시글 정보 (게시글 ID 또는 제목)
     - Row: 좋아요 수 + 신고 수 배지
     - IconButton: 삭제 (휴지통 아이콘)

2. **삭제 확인 다이얼로그**
   - AlertDialog
   - "이 댓글을 삭제하시겠습니까?"
   - "취소" / "삭제" 버튼

3. **빈 상태**
   - 댓글이 없을 때 안내 메시지

4. **페이지네이션**
   - 하단 스크롤 시 다음 페이지 로드
