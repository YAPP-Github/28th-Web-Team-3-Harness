# 동기 완료 미션 생성 Job API 명세

## 상태

- 상태: 확정
- 기준 BE 커밋: `6deb8af2f5e167cbbaf0d15ce9a025cf7c7a6227`
- 기준 기능 PR: `28th-Web-Team-3-BE#166` (merged)
- Swagger 태그: `Mission Generation`

## 프론트엔드 적용 범위

기존 job 기반 초안 조회·선택 확정 플로우는 아래 API를 사용한다. `POST` 응답을 받을 때 서버는 이미 DB 초안 3개를 만들고 job을 `SUCCEEDED`로 완료한다. dispatcher, worker, polling 완료 대기는 서버 요청 경로에서 사용하지 않는다.

프론트엔드의 생성 중 화면은 서버 상태와 별개로 최소 7초 동안 표시할 수 있다. 이 시간은 UI 연출용이며, 완료 여부를 판단하거나 추가 생성 요청을 보내는 기준으로 사용하지 않는다. FE 코드 변경은 이 명세의 범위가 아니다.

별도 `POST /api/missions/generations`는 후보 조회 전용 API로 유지된다. jobId, draft 조회, confirm이 필요하면 이 문서의 job API를 사용해야 하며 두 API의 응답을 섞어 사용하지 않는다.

## API

### `POST /api/missions/generation-jobs`

Bearer Access Token이 필요하며, 생년월일과 거주지역을 포함한 온보딩이 완료된 사용자만 요청할 수 있다.

#### Request body

| 필드 | 타입 | 필수 | 허용 값 | 의미 |
| --- | --- | --- | --- | --- |
| `category` | string | 예 | `MEAL`, `LIVING`, `HOBBY` | 사용자가 줄이려는 소비 카테고리 |
| `item` | string | 예 | 활성화된 미션 항목 | 카테고리 안의 구체적인 소비 항목이며 `category`와 일치해야 한다. |
| `baselineFrequency` | integer | 예 | 1~10 | 해당 항목의 평소 주간 소비 횟수 |
| `baselineAmountWon` | integer | 예 | 1~2,000,000 | 해당 항목의 평소 주간 소비 금액(원) |

#### Success response — `200 OK`

```json
{
  "jobId": "6b5f1a2e-1fc6-4acd-a9fd-04322df0c18e",
  "status": "SUCCEEDED",
  "generationSource": "DIRECT",
  "draftsAvailable": true,
  "expiresAt": "2026-08-23T06:00:00Z",
  "confirmed": false,
  "pollingIntervalMillis": 2000
}
```

| 필드 | FE 처리 규칙 |
| --- | --- |
| `jobId` | `GET /api/missions/generation-jobs/{jobId}/drafts`와 `POST /api/missions/generation-jobs/{jobId}/confirm`에 사용한다. |
| `status` | 성공 응답에서는 항상 `SUCCEEDED`다. |
| `generationSource` | 운영 환경에서는 DB `mission_action_template` 기반의 `DIRECT`다. |
| `draftsAvailable` | 성공 응답에서는 `true`다. |
| `expiresAt` | 이 시각 이후에는 초안을 조회·확정할 수 없다. |
| `pollingIntervalMillis` | 기존 응답 호환 필드다. 동기 완료 응답의 완료 대기에 사용하지 않는다. |

### `GET /api/missions/generation-jobs/{jobId}/drafts`

POST 성공 직후 호출할 수 있다. 응답은 항상 정확히 3개의 draft를 포함한다.

각 후보에는 요청한 `baselineFrequency`와 `baselineAmountWon` 전체값이 각각 적용된다. 후보 간 횟수·금액을 분배하지 않는다. 따라서 사용자가 여러 후보를 확정하면 각 미션이 각각 전체 목표·예상 절약액을 가진다.

### `POST /api/missions/generation-jobs/{jobId}/confirm`

`selectedDraftIds`에는 같은 job의 초안 ID를 중복 없이 **1~3개** 전달한다. 선택한 모든 초안은 ACTIVE 미션으로 저장된다.

| HTTP | 오류 코드 | 발생 조건 |
| --- | --- | --- |
| `400` | `MISSION_CONFIRM_INVALID` | 0개, 4개 이상, 중복 ID 또는 해당 job에 없는 draft ID |
| `409` | `MISSION_CONFIRM_CONFLICT` | 이전 확정과 다른 선택으로 재확정 시도 |
| `409` | `MISSION_DRAFT_EXPIRED` | 초안 만료 후 조회·확정 시도 |

## 생성 정책

- 외부 AI, knowledge retrieval, dispatcher, worker, outbox를 요청 경로에서 사용하지 않는다.
- 서버는 요청한 `item`의 활성 `mission_action_template` 중 결정적으로 선택한 정확히 3개를 draft로 저장한다.
- 각 draft의 `targetCount`는 `baselineFrequency`, `estimatedSavingsWon`은 `baselineAmountWon`, `targetUnit`은 `TIMES_PER_WEEK`, `savingsEstimateVersion`은 `V2_DIRECT_CANDIDATE`다.
- template이 3개 미만이거나 유효하지 않으면 요청 전체가 실패하며 job·draft는 저장되지 않는다.
