# 미션 생성 API 필드 매핑

## 상태

- 상태: 현재 구현 기준
- 기준 FE 커밋: `6ba701fb3c85a8980ab090b9321f645edcfab325`
- 기준 BE 커밋: `6deb8af2f5e167cbbaf0d15ce9a025cf7c7a6227`
- Swagger 태그: `Mission Generation`, `Mission Candidates`

## 프론트엔드 적용 범위

현재 FE 추천 생성 화면은 `/api/missions/generation-jobs/**` 경로를 사용한다. 생성 작업 요청, 상태 조회, 초안 조회, 선택 초안 확정 순서다.

`POST /api/missions/generations`는 BE에 함께 존재하는 동기 후보 조회 계약이다. 생성 작업이나 저장 가능한 초안을 만들지 않으며 현재 FE 추천 생성 화면은 호출하지 않는다. 두 경로의 응답을 한 생성 과정에서 섞지 않는다.

## 현재 FE 생성 작업 API

추천 생성 작업 요청에는 Bearer Access Token이 필요하다. 서버는 온보딩 상태가 `COMPLETED`이고 생년월일과 주소가 모두 저장된 사용자만 허용한다.

### 공통 생성 입력

| 필드 | 타입 | 필수 | 허용 값 | 의미 |
| --- | --- | --- | --- | --- |
| `category` | string | 예 | `MEAL`, `LIVING`, `HOBBY` | 사용자가 줄이려는 소비 카테고리 |
| `item` | string | 예 | 활성화된 미션 항목 | 카테고리 안의 구체적인 소비 항목. `category`와 일치해야 한다. |
| `baselineFrequency` | integer | 예 | 1~10 | 입력한 소비 빈도. 각 초안의 `targetCount`로 그대로 저장된다. |
| `baselineAmountWon` | integer | 예 | 1~2,000,000 | 입력한 소비 금액. 각 초안의 `estimatedSavingsWon`으로 그대로 저장된다. |

### API별 입출력

| API | request/parameter | response와 처리 |
| --- | --- | --- |
| `POST /api/missions/generation-jobs` | 공통 생성 입력 | `jobId`, `status`, `failureCode`, `generationSource`, `draftsAvailable`, `expiresAt`, `confirmed`, `pollingIntervalMillis` |
| `GET /api/missions/generation-jobs/{jobId}` | path `jobId` | 같은 생성 작업 상태. FE가 `SUCCEEDED`와 `draftsAvailable`을 확인한다. |
| `GET /api/missions/generation-jobs/{jobId}/drafts` | path `jobId` | 작업에 저장된 카테고리별 초안 3개. 성공하고 만료되지 않은 작업만 조회된다. |
| `POST /api/missions/generation-jobs/{jobId}/confirm` | `selectedDraftIds` 1~3개 | 선택한 초안을 `RECOMMENDED` 미션으로 확정한 `missions` 배열 |

### 생성 결과 필드 규칙

| 필드 | 현재 의미 |
| --- | --- |
| `generationSource` | 고정 BE 설정에서는 활성 DB 직접 템플릿을 사용한 `DIRECT`다. `RECOMMENDED` 수명주기 source와 다른 필드다. |
| `title` | 선택 항목의 직접 템플릿 `{count}`를 입력 `baselineFrequency`로 치환한 문구 |
| `targetCount` | 입력 `baselineFrequency`를 그대로 사용한 값 |
| `targetUnit` | `TIMES_PER_WEEK` |
| `estimatedSavingsWon` | 입력 `baselineAmountWon`을 그대로 사용한 값. 후보 수로 나누거나 1회 단가·100원 단위 계산을 하지 않는다. |
| `savingsEstimateVersion` | 현재 생성 작업 초안은 `V2_DIRECT_CANDIDATE` |
| `savingsLabel` | 절약 예상액을 포함해 서버가 만든 표시 문구 |
| `savingsDisclaimer` | `단순 추정치로 정확하지 않을 수 있어요`. 고정 FE 스키마는 이 필드를 소비하지 않는다. |

## 동기 후보 조회 호환 계약

### `POST /api/missions/generations`

Bearer Access Token이 필요하며 생성 작업과 같은 온보딩 선행 조건을 적용한다. request body는 위 공통 생성 입력과 같다.

#### Success response — `200 OK`

```json
{
  "candidates": [
    {
      "category": "MEAL",
      "item": "DELIVERY_FOOD",
      "title": "배달 앱 대신 집밥 레시피를 2회 도전하기",
      "description": "이번 주 소비를 줄이는 행동을 실천해 보세요.",
      "actionCode": "DELIVERY_FOOD",
      "metricType": "COUNT",
      "targetCount": 2,
      "targetUnit": "TIMES_PER_WEEK",
      "estimatedSavingsWon": 30000,
      "savingsEstimateVersion": "V2_DIRECT_CANDIDATE",
      "savingsLabel": "미션을 완료하면 평소보다 배달음식비를 30000원 아낄 수 있어요",
      "savingsDisclaimer": "단순 추정치로 정확하지 않을 수 있어요"
    }
  ]
}
```

#### Response field rules

| 필드 | 의미 | FE 처리 규칙 |
| --- | --- | --- |
| `candidates` | 직접 선택할 미션 후보 배열 | 항상 정확히 3개다. 배열 순서는 서버가 선택한 순서이며 우선순위 의미를 보장하지 않는다. |
| `category`, `item` | 요청한 카테고리·항목 | 후보 카드의 분류/표시에 사용한다. |
| `title` | `{count}`가 목표 횟수로 치환된 카드 제목 | 그대로 표시한다. |
| `description` | 공통 실행 안내 문구 | 그대로 표시한다. |
| `actionCode` | 항목 코드 | 표시용이 아닌 내부 식별 보조 정보다. |
| `metricType` | 목표 측정 방식 | 현재 동기 후보 API에서는 항상 `COUNT`다. |
| `targetCount` | 후보의 목표 횟수 | 모든 후보에 요청의 `baselineFrequency`가 그대로 적용된다. 빈도가 1~2여도 후보 수는 줄지 않는다. |
| `targetUnit` | 목표 횟수 단위 | 현재 `TIMES_PER_WEEK`다. |
| `estimatedSavingsWon` | 후보 하나를 선택했을 때의 단순 절약 예상액 | 모든 후보에 요청의 `baselineAmountWon`이 그대로 적용된다. |
| `savingsEstimateVersion` | 절약 예상액 계산 정책 식별자 | 현재 `V2_DIRECT_CANDIDATE`다. 화면 문구를 분기하지 말고 관측/호환성 용도로만 사용한다. |
| `savingsLabel` | 절약 예상액 안내 문구 | 그대로 표시한다. |
| `savingsDisclaimer` | 절약 예상액의 비정확성 고지 | 절약 예상액을 보여 주면 함께 표시한다. |

#### Error response

| HTTP | 오류 코드 | 발생 조건 | FE 처리 |
| --- | --- | --- | --- |
| `400` | `MISSION_GENERATION_INPUT_INVALID` | 카테고리·항목 조합, 비활성 항목, 횟수 또는 금액 범위가 유효하지 않음 | 입력값을 다시 받는다. |
| `401` | 인증 오류 | Access Token이 없거나 유효하지 않음 | 로그인/게스트 인증을 다시 진행한다. |
| `409` | `ONBOARDING_INCOMPLETE` | 필수 온보딩 정보가 없거나 완료되지 않음 | 온보딩 완료 화면으로 유도한다. |

## 동기 후보 저장 및 후속 동작

- 이 요청은 `mission_generation_job`, outbox, draft, mission을 생성하지 않는다.
- 응답의 후보에는 DB 식별자나 확정 API 연결 정보가 없다.
- 따라서 이 API는 **후보 조회 전용**이다. 사용자의 후보 선택을 ACTIVE 미션으로 저장하는 별도 계약은 이 명세에 포함되지 않는다.

## 관련 문서

- [API 분석 인벤토리](api-inventory.md)
- [미션 수명주기 API 필드 매핑](mission-lifecycle.md)
- [POLICY-MISSION-002](../policies/mission-002-generation.md) — 현재 FE 생성 작업 정책
- [FLOW-MISSION-001](../workflows/mission-001-survey-and-generation.md)
- [2026-08-25-mission-main-baseline](../../decisions/2026-08-25-mission-main-baseline.md)
