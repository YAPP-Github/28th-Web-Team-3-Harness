# 미션 수명주기 API 필드 매핑

## API별 입출력

| API | request/parameter | response |
| --- | --- | --- |
| `GET /api/missions/catalog` | 없음 | 카테고리와 항목 목록 |
| `GET /api/missions` | query `status`, `category`(선택) | `missions[]` |
| `GET /api/missions/progress` | query `category`(선택) | 이번 주 완료 수·전체 수·진행률·주 시작일 |
| `POST /api/missions/manual` | `category`, 최대 30자 `text` | 직접 추가 미션 |
| `DELETE /api/missions/{source}/{missionId}` | source, missionId | 없음 (`204`) |
| `PATCH /api/missions/{source}/{missionId}/complete` | source, missionId | 이번 주 완료 상태의 미션 |

## 공통 응답 의미

| 필드 | 의미 |
| --- | --- |
| `source` | `RECOMMENDED`는 AI 미션, `MANUAL`은 직접 추가 미션 |
| `category` | `MEAL`, `LIVING`, `HOBBY` 중 하나 |
| `item` | AI 미션의 구체 항목. 직접 추가는 없음 |
| `targetCount` | AI 대안에 서버가 배분한 이번 주 목표 횟수. 직접 추가는 없음 |
| `estimatedSavingsWon` | 100원 단위로 내린 1회 단가와 목표 횟수로 계산한 단순 추정액. 직접 추가는 없음 |
| `savingsDisclaimer` | 절약액이 있으면 `단순 추정치로 정확하지 않을 수 있어요` |
| `status` | 현재 주 완료 행이 있으면 `COMPLETED`, 없으면 `ACTIVE` |
| `weekEndsAt` | 현재 주 다음 월요일 00:00(Asia/Seoul) |

`INCOMPLETE` 자동 마감 상태는 새 정책에서 사용하지 않는다. 삭제는 미션 정의를 soft delete하며 주간 완료 기록을 보존한다.
