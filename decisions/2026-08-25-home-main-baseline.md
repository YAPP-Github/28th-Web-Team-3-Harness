# 홈 main 구현 기준 채택

- 날짜: 2026-08-25
- 상태: accepted
- 관련 정책과 플로우: [POLICY-HOME-001](../domain/policies/home-001-dashboard.md), [FLOW-HOME-001](../domain/workflows/home-001-dashboard.md)

## 배경

완료된 FE와 BE 구현을 운영·개선 작업의 시작점으로 삼기 위해 홈의 목표 현황, 이번 주 미션, 혜택 요약 동작을 역문서화해야 한다. 작업 중 기준이 바뀌지 않도록 다음 커밋을 고정했다.

- FE `main`: `6ba701fb3c85a8980ab090b9321f645edcfab325`
- BE `main`: `6deb8af2f5e167cbbaf0d15ce9a025cf7c7a6227`
- Harness `main`: `d6c9f2da757b9688a6748d0e766354737904a3ff`

## 결정

FE는 사용자가 보는 표시·입력·이동·실패 복구의 기준으로, BE는 사용자별 조회 범위·금액 계산·주간 완료·혜택 선별의 기준으로 사용한다. 홈에서 직접 사용하지 않는 API나 다른 모듈의 생성·저장 세부 규칙은 홈 정책으로 확장하지 않는다.

조사한 FE 주요 파일:

- `apps/web/app/(tabs)/page.tsx`
- `apps/web/app/(tabs)/_components/home-goal-section.tsx`
- `apps/web/app/(tabs)/_components/goal-tracker-row.tsx`
- `apps/web/app/(tabs)/_components/weekly-mission-section.tsx`
- `apps/web/app/(tabs)/_components/weekly-mission-section.test.tsx`
- `apps/web/app/(tabs)/_components/financial-tip-list.tsx`
- `apps/web/app/(tabs)/_components/financial-tip-list.test.tsx`
- `apps/web/app/goal/_components/monthly-goal-card.tsx`
- `apps/web/app/goal/_components/savings-input-sheet.tsx`
- `apps/web/app/(tabs)/mission/lib/format.ts`
- `apps/web/lib/queries/goal.ts`
- `apps/web/lib/queries/mission.ts`
- `apps/web/lib/queries/policy.ts`
- `apps/web/e2e/home.spec.ts`
- `packages/schema/src/goal.ts`
- `packages/schema/src/mission.ts`
- `packages/schema/src/policy.ts`

조사한 BE 주요 파일:

- `api/src/main/kotlin/backend/yapp/api/goal/controller/GoalV2Controller.kt`
- `api/src/main/kotlin/backend/yapp/api/goal/dto/GoalV2Response.kt`
- `core/src/main/kotlin/backend/yapp/core/goal/service/GoalService.kt`
- `api/src/main/kotlin/backend/yapp/api/mission/lifecycle/controller/MissionController.kt`
- `api/src/main/kotlin/backend/yapp/api/mission/lifecycle/dto/MissionLifecycleDtos.kt`
- `core/src/main/kotlin/backend/yapp/core/mission/generation/service/MissionLifecycleService.kt`
- `api/src/main/kotlin/backend/yapp/api/policy/controller/PolicyController.kt`
- `api/src/main/kotlin/backend/yapp/api/policy/dto/PolicyResponses.kt`
- `core/src/main/kotlin/backend/yapp/core/policy/service/PolicyQueryService.kt`

확인한 구현 차이와 미확정 사항:

- FE 홈은 미션 목록의 완료 개수를 전체 개수로 나눠 반올림한다. BE의 별도 미션 진행률 조회는 같은 비율을 정수 나눗셈으로 내림한다. 현재 홈이 목록으로 직접 계산하므로 FE 표시를 현행 기준으로 기록하고, 두 계산의 통합 방향은 확정하지 않는다.
- FE 홈은 `전체`, `식비`, `생활`, `취미`만 필터로 제공한다. BE와 응답 계약은 기존 `교통` 미션을 반환할 수 있다. 기존 교통 미션의 제거 또는 필터 추가를 결정하지 않는다.
- FE 브라우저는 이전 저장값이 없을 때 미션 생성 성공 시 서울 기준 날짜 문자열을 저장하지만 생성 이력 조회에서는 저장 문자열이 정확히 `"true"`인지 판정한다. 따라서 현재 브라우저의 새 생성 성공은 직접 입력·추천받기 동시 노출로 이어지지 않는다. 네이티브는 브리지의 불리언 응답을 사용하며 내부 저장 형식은 조사 범위에 없어 플랫폼 동작을 같다고 확정하지 않는다.
- BE는 삭제된 미션뿐 아니라 비활성화된 항목에 속한 추천 미션도 목록에서 제외한다. 홈 요약과 카드 모두 이 응답을 사용하므로 해당 미션을 집계에 포함하지 않는다.
- 화면 영역 이름은 `눈여겨볼 만한 혜택/팁`이지만 FE는 정책 혜택 목록만 요청한다. BE에는 별도 절약 팁 조회가 있으나 홈에서는 사용하지 않는다. 절약 팁을 홈에 합칠지 결정하지 않는다.
- 혜택 카드가 개별 혜택 ID를 갖지만 FE 홈은 모든 카드를 혜택 목록으로 연결한다. 개별 상세 이동으로 바꾸지 않는다.
- 홈 혜택은 조회수 내림차순, 동률이면 ID 내림차순으로 결정된다. 이 보조 정렬은 최대 5개 경계와 카드 순서를 고정한다.
- FE는 조회 가능한 미션이 하나도 없을 때 주간 마감 정보 대신 고정 대체값 `D-7`을 표시한다. 실제 요일 기반 값으로 보정하지 않는다.
- FE 목표 응답 계약은 BE 응답의 `baseAmountManwon`을 사용하지 않지만, `totalSavedManwon`에 순자산이 이미 포함된다는 BE 계산을 기준으로 총액 의미를 기록한다.

## 영향

홈 개선 작업은 세 영역의 부분 실패를 보존하고, 목표 총액·주간 미션 요약·혜택 선별 의미를 먼저 대조할 수 있다. 미션 생성·생명주기 전체와 혜택 저장·신청 동작은 각 모듈 문서가 담당한다.

## 검토한 대안

- FE 화면만 기록: 총 저축액 구성, 주간 완료 범위, 개인화 혜택 선별 근거를 놓치므로 제외했다.
- BE 계약만 기록: 홈이 실제로 사용하지 않는 진행률·절약 팁 API를 현행 화면 정책으로 오인하므로 제외했다.
- 화면 이름에 맞춰 절약 팁도 홈 정책에 포함: 현재 홈 구현 근거가 없어 제외했다.
