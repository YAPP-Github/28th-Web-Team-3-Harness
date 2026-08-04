# 온보딩 API 필드 매핑

## 범위와 근거

- 기준: BE `origin/main`의 `8298024`
- Swagger/OpenAPI 경로: `/api/onboarding/profile`(PATCH, GET), `/api/onboarding/report`(GET), `/api/onboarding/goal-plans`(GET), `/api/onboarding/goal`(POST)
- 실제 컨트롤러: `api/.../onboarding/controller/OnboardingController.kt`
- Swagger 문서: `api/.../apidoc/onboarding/OnboardingApi.kt`
- DTO: `api/.../onboarding/dto/`(`ProfileRequests.kt`, `ProfileResponse.kt`, `ReportResponse.kt`, `GoalPlansResponse.kt`, `GoalResponse.kt`)
- 의미 검증: `OnboardingProfileService.kt`, `OnboardingReportService.kt`, `OnboardingGoalService.kt`, `FinancialReportCalculator.kt`, `GoalPlanCalculator.kt`, `OnboardingAcceptanceTest.kt`

`ProfileResponse`는 프로필 부분 저장(PATCH)과 조회(GET)에서 공통으로 사용된다. 모든 금액 필드 단위는 **만원**이다.

## API별 입출력

| API | request/parameter | response |
| --- | --- | --- |
| `PATCH /api/onboarding/profile` | body `ProfilePatchRequest` | `ProfileResponse` |
| `GET /api/onboarding/profile` | 없음 | `ProfileResponse` |
| `GET /api/onboarding/report` | 없음 | `ReportResponse` |
| `GET /api/onboarding/goal-plans` | 없음 | `GoalPlansResponse` |
| `POST /api/onboarding/goal` | body `GoalConfirmRequest` | `GoalResponse` |

온보딩 입력은 스텝별로 필요한 필드만 담아 `PATCH`로 부분 저장하며, 서버가 진행 상태를 보존해 재접속 시 이어서 진행한다.

## 요청

### `ProfilePatchRequest` (`PATCH /api/onboarding/profile`)

각 필드는 선택이며, 해당 스텝에서 입력한 필드만 전송한다.

| JSON 경로 | 한국어 의미 | 값·제약 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `birthDate` | 생년월일 | `YYYY-MM-DD`, 과거 날짜만. 1/4 나이 스텝 | 확정 | `@Schema`, `@Past`, `ProfilePatchRequest` |
| `monthlySalaryManwon` | 월급(세후 실수령액) | 0~650 만원. 세전 통계와 비교할 때는 보정계수로 세전 환산 | 확정 | `@Schema`, `OnboardingProfileService` 범위 검증, `FinancialReportCalculator` |
| `monthlySavingManwon` | 월 저축액 | 0~650 만원, **월급을 초과할 수 없음** | 확정 | `@Schema`, `OnboardingProfileService.validateSavingWithinSalary` |
| `netWorthManwon` | 현재 순자산(투자·예/적금 총합) | 0~10000 만원(1억) | 확정 | `@Schema`, 서비스 범위 검증 |
| `goalPeriodMonths` | 목표 기간(개월) | 3~36 | 확정 | `@Schema`, 서비스 범위 검증 |

### `GoalConfirmRequest` (`POST /api/onboarding/goal`)

| JSON 경로 | 한국어 의미 | 값·제약 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `plan` | 확정할 목표안 | `PLAN_1`(확실하게, 기본 선택), `PLAN_2`(여유롭게) | 확정 | `@Schema`, `GoalPlan` enum, `GoalPlanCalculator`의 안별 라벨 |

## 응답: `ProfileResponse` (프로필 저장·조회 공통)

| JSON 경로 | 한국어 의미 | 값·생성 규칙 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `status` | 온보딩 진행 상태 | `IN_PROGRESS`(진행 중), `COMPLETED`(목표 확정으로 완료) | 확정 | `OnboardingStatus` enum, 목표 확정 시 완료 전이 |
| `birthDate` | 저장된 생년월일 | 미입력 시 `null` | 확정 | 요청 `birthDate`와 동일 |
| `monthlySalaryManwon` | 저장된 월급 | 미입력 시 `null` | 확정 | 요청 `monthlySalaryManwon`과 동일 |
| `monthlySavingManwon` | 저장된 월 저축액 | 미입력 시 `null` | 확정 | 요청 `monthlySavingManwon`과 동일 |
| `netWorthManwon` | 저장된 순자산 | 미입력 시 `null` | 확정 | 요청 `netWorthManwon`과 동일 |
| `goalPeriodMonths` | 저장된 목표 기간 | 미입력 시 `null` | 확정 | 요청 `goalPeriodMonths`와 동일 |

## 응답: `ReportResponse` (`GET /api/onboarding/report`)

재무 분석 리포트 화면 데이터. 필수 입력(월급·월저축·순자산·목표기간)이 모두 있어야 조회된다.

### `simulation` — 저축률 상향 시뮬레이션

| JSON 경로 | 한국어 의미 | 값·생성 규칙 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `simulation.baselineManwon` | 현행 유지 시 예상 금액 | 만원, 연복리 적용 추정치 | 확정 | `FinancialReportCalculator.simulate` |
| `simulation.simulationManwon` | 저축률 상향 시 예상 금액 | 만원, 연복리 적용 추정치 | 확정 | `FinancialReportCalculator.simulate` |
| `simulation.diffManwon` | 두 예상 금액의 차액 | `simulationManwon - baselineManwon`, 만원 | 확정 | `FinancialReportCalculator.simulate` |
| `simulation.upliftPercent` | 시뮬레이션에 적용한 저축률 상향폭 | 백분율(예: `15`) | 확정 | 설정값 `reportUpliftPercent`, 계산기 |
| `simulation.periodMonths` | 시뮬레이션 기간 | 개월(사용자 목표 기간) | 확정 | 계산기, 프로필 `goalPeriodMonths` |

### `peer` — 또래 비교

| JSON 경로 | 한국어 의미 | 값·생성 규칙 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `peer.assetRatioPercent` | 또래 순자산 중앙값 대비 비율 | `순자산 ÷ 중앙값 × 100`, 백분율 | 확정 | 계산기, 통계 데이터셋 중앙값 |
| `peer.incomeTopPercent` | 소득 상위 백분위 | 백분율, 5%p 단위 반올림("약 N%") | 확정 | 계산기 백분위 로직 |
| `peer.consumptionTopPercent` | 소비 상위 백분위 | 백분율, 5%p 단위 반올림 | 확정 | 계산기 백분위 로직 |

### `histogram` — 또래 소득·소비 분포

`histogram.income`, `histogram.consumption` 두 계열 모두 동일 구조(`HistogramSeriesResponse`)이다.

| JSON 경로 | 한국어 의미 | 값·생성 규칙 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `histogram.{income\|consumption}.bins[]` | 구간별 분포 | 구간 배열 | 확정 | `FinancialReportCalculator.series` |
| `bins[].lowerManwon` | 구간 하한 | 만원 | 확정 | 통계 데이터셋 구간 |
| `bins[].upperManwon` | 구간 상한 | 만원, `null`이면 상한 없는 개방 구간 | 확정 | 통계 데이터셋 구간 |
| `bins[].ratio` | 구간 비율 | 백분율(구간 인구 비율) | 확정 | 통계 데이터셋 |
| `bins[].density` | 구간 밀도 | `비율 ÷ 구간 폭`(그래프 높이용) | 확정 | 계산기 밀도 환산 |
| `histogram.{income\|consumption}.markerManwon` | 사용자 위치 값 | 만원(연소득 또는 연소비) | 확정 | 계산기, 마커 배치 |

### `diagnosis` — 종합 진단

| JSON 경로 | 한국어 의미 | 값·생성 규칙 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `diagnosis.branchCode` | 종합 진단 분기 코드 | 자산·소득·소비 3축 조합 1~8 | 확정 | `DiagnosisBranch` |
| `diagnosis.message` | 종합 진단 문구 | 도입부 + 진단 + 액션을 조합한 동적 문자열 | 확정 | 계산기 `diagnose`, `DiagnosisBranch` 템플릿 |

### 리포트 메타

| JSON 경로 | 한국어 의미 | 값·생성 규칙 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `disclaimer` | 면책 문구 | "두 값 모두 연 3.0% 복리 적용. 단순 추정치일 뿐 정확하지 않을 수 있습니다." | 확정 | `FinancialReportCalculator.disclaimer` |
| `datasetVersion` | 통계 데이터셋 버전 | 예: `gafinance-2025-u29` | 확정 | `FinanceStatisticsAdapter` |
| `configVersion` | 계산 설정 버전 | 예: `v1` | 확정 | `onboarding.version` 설정 |

## 응답: `GoalPlansResponse` (`GET /api/onboarding/goal-plans`)

| JSON 경로 | 한국어 의미 | 값·생성 규칙 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `monthlySavingManwon` | 월 저축액 | 만원(온보딩 입력값) | 확정 | `GoalPlanCalculator` |
| `periodMonths` | 목표 기간 | 개월 | 확정 | `GoalPlanCalculator` |
| `plans[]` | 목표안 목록(1안·2안) | 배열 | 확정 | `GoalPlanCalculator.calculate` |
| `plans[].plan` | 목표안 식별 | `PLAN_1`, `PLAN_2` | 확정 | `GoalPlan` enum |
| `plans[].label` | 목표안 표시명 | `확실하게`, `여유롭게` | 확정 | `GoalPlanCalculator` 라벨 |
| `plans[].default` | 기본 선택 여부 | `PLAN_1`이 `true` | 확정 | `GoalPlanCalculator` |
| `plans[].increaseMinManwon` | 목표 증가분 최소 | 만원(기존 저축 대비 추가로 더 모을 금액 범위의 하한) | 확정 | `GoalPlanCalculator` |
| `plans[].increaseMaxManwon` | 목표 증가분 최대 | 만원(범위 상한) | 확정 | `GoalPlanCalculator` |
| `plans[].checkpoints[]` | 기간별 체크포인트 | 목표 기간을 4등분한 시점 배열 | 확정 | `GoalPlanCalculator.checkpointMonths` |
| `checkpoints[].month` | 체크포인트 시점 | 개월 | 확정 | `GoalPlanCalculator` |
| `checkpoints[].amountManwon` | 체크포인트 목표 금액 | 만원 | 확정 | `GoalPlanCalculator` |
| `plans[].card` | 최종 목표 카드 | 마지막 체크포인트와 동일한 `{month, amountManwon}` | 확정 | `GoalPlanCalculator` |

## 응답: `GoalResponse` (`POST /api/onboarding/goal`)

| JSON 경로 | 한국어 의미 | 값·생성 규칙 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `goalId` | 확정된 목표 식별자 | 정수 | 확정 | `OnboardingGoal` 엔티티 |
| `plan` | 확정한 목표안 | `PLAN_1`, `PLAN_2` | 확정 | 요청 `plan` |
| `periodMonths` | 목표 기간 | 개월 | 확정 | 확정 시 프로필 값 |
| `targetAmountManwon` | 확정 목표 금액 | 만원(선택 안의 최종 카드 금액) | 확정 | `OnboardingGoalService.confirm` |
| `status` | 온보딩 상태 | 목표 확정으로 `COMPLETED` | 확정 | 확정 시 상태 전이 |

## 예외·상태 확인

- `monthlySavingManwon`이 `monthlySalaryManwon`을 초과하면 `400 INVALID_ONBOARDING_INPUT`.
- 프로필이 없으면 `404 ONBOARDING_PROFILE_NOT_FOUND`.
- 리포트·목표안·목표 확정은 필수 입력이 완료되지 않으면 `409 ONBOARDING_INCOMPLETE`.
- 목표 확정 후 월저축·목표기간을 다시 저장하면 확정 목표가 무효화되고 상태가 `IN_PROGRESS`로 되돌아간다.

## 문서화 범위

이 문서는 프론트엔드 개발자가 DTO 필드의 의미를 이해하도록 돕는 의미 사전이다. 화면에 노출할 정확한 라벨·카피는 범위에 포함하지 않는다.
