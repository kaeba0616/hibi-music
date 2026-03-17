# F16: 댓글 기능 강화 - 화면 구조

## 기존 화면 확장

기존 댓글 섹션(`comment_section.dart`)에 3가지 기능을 추가한다.

---

## CE-01: Top3 추천 댓글 섹션

### 위치
댓글 섹션 헤더 아래, 전체 댓글 목록 위

### UI 요소
- **섹션 제목**: "추천 댓글" + 메달 아이콘
- **Top3 카드 목록**: 기존 CommentCard 재활용, 하이라이트 배경
  - 1등: 금색 crown 아이콘 (Icons.emoji_events, Colors.amber)
  - 2등: 은색 아이콘 (Colors.grey[400])
  - 3등: 동색 아이콘 (Colors.brown[300])
- **구분선**: Top3 섹션과 전체 댓글 사이 Divider

### 표시 조건
- 좋아요 1개 이상인 댓글이 최소 1개 이상일 때만 표시
- 최대 3개 (좋아요 수 내림차순, 동점 시 최신순)
- Top3에 포함된 댓글도 전체 목록에서 중복 표시 (일반 스타일)

### 스타일
- 배경: `colorScheme.primaryContainer.withOpacity(0.1)`
- 좌측 랭킹 아이콘: 24px
- 패딩: EdgeInsets.symmetric(horizontal: 16, vertical: 8)

---

## CE-02: 댓글 신고 기능

### 진입점
기존 CommentCard의 더보기(⋮) 메뉴 확장
- 본인 댓글: "삭제" (기존)
- 타인 댓글: "신고하기" (신규 추가)

### CommentReportSheet (Bottom Sheet)

#### 헤더
- 제목: "댓글 신고"
- 닫기 버튼 (X)

#### 신고 사유 목록 (RadioListTile)
| 값 | 표시 텍스트 |
|----|-----------|
| SPAM | 스팸/광고 |
| ABUSE | 욕설/비방 |
| INAPPROPRIATE | 불쾌한 내용 |
| COPYRIGHT | 저작권 침해 |
| OTHER | 기타 |

#### 기타 상세 입력
- "기타" 선택 시에만 표시
- TextField (maxLength: 300, maxLines: 3)
- 힌트 텍스트: "신고 사유를 입력해주세요"

#### 하단 버튼
- "신고하기" FilledButton (사유 미선택 시 비활성)
- 로딩 중: CircularProgressIndicator

#### 결과 처리
- 성공: Sheet 닫기 + SnackBar "신고가 접수되었습니다"
- 중복 신고: SnackBar "이미 신고한 댓글입니다"
- 실패: SnackBar "신고에 실패했습니다. 다시 시도해주세요"

---

## CE-03: 부적절 댓글 필터링

### Comment 모델 확장
- `isFiltered` 필드 추가 (boolean, default: false)

### 필터링된 댓글 표시
- 내용: "[부적절한 내용이 포함된 댓글입니다]"
- 스타일: italic, `colorScheme.onSurfaceVariant`
- 배경: `colorScheme.errorContainer.withOpacity(0.1)`
- 좋아요 버튼: 비활성화 (회색)
- 답글 버튼: 비활성화
- 더보기 메뉴: 표시하지 않음

### 서버 처리
- 백엔드에서 `isFiltered=true` 댓글의 content를 빈 문자열로 응답
- 프론트엔드에서 `isFiltered` 상태를 확인하여 대체 텍스트 표시
