# 미션 수명주기 API 필드 매핑

## API별 입출력

| API | request/parameter | response |
| --- | --- | --- |
| `GET /api/missions/catalog` | 없음 | 카테고리와 항목 목록 |
| `GET /api/missions` | query `status`, `category`(선택) | `missions[]` |
| `GET /api/missions/progress` | query `category`(선택) | 이번 주 완료 수·전체 수·진행률·주 시작일 |
| `GET /api/missions/histories` | query `year`, `month` | 선택한 달과 겹치는 주차별 미션 완료 내역 |
| `POST /api/missions/manual` | `category`, 최대 30자 `text` | 직접 추가 미션 |
| `DELETE /api/missions/{source}/{missionId}` | source, missionId | 없음 (`204`) |
| `PATCH /api/missions/{source}/{missionId}/complete` | source, missionId | 이번 주 완료 상태의 미션 |

## 공통 응답 의미

| 필드 | 의미 |
| --- | --- |
| `source` | `RECOMMENDED`는 생성 작업의 초안을 확정한 추천 미션, `MANUAL`은 직접 추가 미션. 현재 추천 미션은 직접 템플릿 기반이며 값 자체가 AI 생성을 뜻하지 않는다. |
| `category` | `MEAL`, `LIVING`, `HOBBY` 중 하나 |
| `item` | 추천 생성 입력에서 선택한 구체 항목. 직접 추가 미션에는 없음 |
| `targetCount` | 추천 생성 입력의 `baselineFrequency`를 그대로 저장한 목표 횟수. 직접 추가 미션에는 없음 |
| `targetUnit` | 추천 미션은 현재 `TIMES_PER_WEEK`. 직접 추가 미션에는 없음 |
| `estimatedSavingsWon` | 추천 생성 입력의 `baselineAmountWon`을 그대로 저장한 단순 추정액. 1회 단가나 100원 단위 계산을 하지 않으며 직접 추가 미션에는 없음 |
| `savingsEstimateVersion` | 추천 미션 절약액 계산 계약 버전. 현재 생성 작업 결과는 `V2_DIRECT_CANDIDATE` |
| `savingsLabel` | 추천 미션의 현재 완료 상태에 맞춰 서버가 만든 절약 안내 문구 |
| `savingsDisclaimer` | 추천 미션 절약액이 있으면 `단순 추정치로 정확하지 않을 수 있어요` |
| `status` | 현재 주 완료 행이 있으면 `COMPLETED`, 없으면 `ACTIVE` |
| `weekEndsAt` | 현재 주 다음 월요일 00:00(Asia/Seoul) |

`INCOMPLETE` 자동 마감 상태는 새 정책에서 사용하지 않는다. 삭제는 미션 정의를 soft delete하며 주간 완료 기록을 보존한다.

직접 추가 API는 활성 카테고리와 공백 제거 후 1~30자 문구를 검증한다. 추천 생성에 필요한 온보딩 완료·생년월일·주소 조건은 이 API에 적용되지 않는다.

## 관련 문서

- [POLICY-MISSION-002](../policies/mission-002-generation.md)
- [POLICY-MISSION-003](../policies/mission-003-lifecycle.md)
- [FLOW-MISSION-001](../workflows/mission-001-survey-and-generation.md)
- [FLOW-MISSION-002](../workflows/mission-002-lifecycle.md)
- [2026-08-25-mission-main-baseline](../../decisions/2026-08-25-mission-main-baseline.md)
