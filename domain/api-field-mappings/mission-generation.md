# 동기 미션 후보 API 명세

## 상태

- 상태: 확정
- 기준 BE 브랜치: `main`
- 기준 기능 PR: `28th-Web-Team-3-BE#165`
- Swagger 태그: `Mission Candidates`

## 프론트엔드 적용 범위

새 미션 후보 화면은 아래 API를 사용한다. 이 API는 후보를 즉시 반환하며, 생성 job을 만들거나 polling하지 않는다.

기존 `/api/missions/generation-jobs/**` API는 호환성을 위해 남아 있는 비동기 계약이다. 새 화면에서는 이 명세의 동기 API와 섞어 사용하지 않는다.

## API

### `POST /api/missions/generations`

Bearer Access Token이 필요하며, 생년월일과 거주지역을 포함한 온보딩이 완료된 사용자만 요청할 수 있다.

#### Request body

| 필드 | 타입 | 필수 | 허용 값 | 의미 |
| --- | --- | --- | --- | --- |
| `category` | string | 예 | `MEAL`, `LIVING`, `HOBBY` | 사용자가 줄이려는 소비 카테고리 |
| `item` | string | 예 | 활성화된 미션 항목 | 카테고리 안의 구체적인 소비 항목. `category`와 일치해야 한다. |
| `baselineFrequency` | integer | 예 | 1~10 | 해당 항목의 평소 주간 소비 횟수 |
| `baselineAmountWon` | integer | 예 | 1~2,000,000 | 해당 항목의 평소 주간 소비 금액(원) |

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
| `targetCount` | 후보 하나를 선택했을 때의 주간 목표 횟수 | 모든 후보에 요청의 `baselineFrequency`가 그대로 적용된다. 빈도가 1~2여도 후보 수는 줄지 않는다. |
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

## 저장 및 후속 동작

- 이 요청은 `mission_generation_job`, outbox, draft, mission을 생성하지 않는다.
- 응답의 후보에는 DB 식별자나 확정 API 연결 정보가 없다.
- 따라서 이 API는 **후보 조회 전용**이다. 사용자의 후보 선택을 ACTIVE 미션으로 저장하는 별도 계약은 이 명세에 포함되지 않는다.

## 관련 문서

- [API 분석 인벤토리](api-inventory.md)
- [미션 수명주기 API 필드 매핑](mission-lifecycle.md)
- [POLICY-MISSION-002](../policies/mission-002-generation.md) — 기존 비동기 생성 작업 정책
