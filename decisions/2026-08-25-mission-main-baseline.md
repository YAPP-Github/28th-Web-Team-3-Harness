# 미션 main 구현 기준 역문서화

- 날짜: 2026-08-25
- 상태: accepted
- 관련 정책과 플로우: [POLICY-MISSION-001](../domain/policies/mission-001-survey.md), [POLICY-MISSION-002](../domain/policies/mission-002-generation.md), [POLICY-MISSION-003](../domain/policies/mission-003-lifecycle.md), [FLOW-MISSION-001](../domain/workflows/mission-001-survey-and-generation.md), [FLOW-MISSION-002](../domain/workflows/mission-002-lifecycle.md)

## 배경

미션 정책은 기획 중 작성된 Harness 문서 이후 구현이 바뀌었다. 완료된 FE·BE `main`을 운영·개선의 새 기준으로 사용하기 위해 아래 커밋을 고정하고 기존 미션 문서를 중복 생성하지 않고 최신화했다.

- Harness: `d6c9f2da757b9688a6748d0e766354737904a3ff`
- FE: `6ba701fb3c85a8980ab090b9321f645edcfab325`
- BE: `6deb8af2f5e167cbbaf0d15ce9a025cf7c7a6227`

## 결정

- 현재 사용자 생성 플로우는 서버 카탈로그를 이용한 대화형 4단계 입력과 생성 작업 조회·초안 확정을 기준으로 한다.
- 추천 미션은 네이버 검색이나 AI 결과가 아니라 항목별 직접 템플릿 3개로 생성한다. 기준 빈도와 기준 금액을 후보마다 그대로 목표 횟수와 절약 예상액에 적용한다.
- 별도 동기 후보 조회는 구현되어 있지만 현재 FE 생성 화면이 사용하지 않으며 확정·저장 식별자도 없다. 조회 전용 호환 계약으로 구분한다.
- 현재 주 완료 상태는 미션 행의 누적 상태가 아니라 주 시작일별 완료 기록으로 계산한다. 삭제는 soft delete하며 월별 내역은 미션의 생성·삭제 시점과 주간 완료 기록을 함께 집계한다.
- 기존 다중 카테고리 미션 설문 API는 BE에 조건부로 남아 있지만 고정 FE에서 호출하지 않으므로 현재 사용자 플로우 정책으로 채택하지 않는다.
- [2026-08-10 기존 결정](2026-08-10-mission-policy-redesign.md)의 설문 폐기·교통 제거·반복 완료·soft delete 방향은 유지한다. 네이버 검색·AI 생성·100원 단위 1회 단가 계산 부분은 이 결정의 직접 템플릿 구현 기준으로 대체한다.

## 조사 근거

FE에서는 다음 고정 커밋 파일과 관련 테스트를 대조했다.

- `packages/schema/src/mission-generation.ts`, `packages/schema/src/mission.ts`
- `apps/web/src/api/mission-generation.ts`, `apps/web/src/api/mission.ts`
- `apps/web/app/mission/new/_components/mission-creation-chat.tsx`
- `apps/web/app/mission/_components/mission-loading.tsx`, `mission-creation-result.tsx`
- `apps/web/app/_components/pending-mission-generation-recovery.tsx`
- `apps/web/app/(tabs)/mission/page.tsx`, `_components/mission-list.tsx`
- `apps/web/app/mission/history/_components/mission-history.tsx`

BE에서는 다음 고정 커밋 파일과 수용 테스트를 대조했다.

- `core/src/main/kotlin/backend/yapp/core/mission/generation/service/MissionGenerationService.kt`, `MissionCandidateService.kt`
- `infra/src/main/kotlin/backend/yapp/infra/mission/generation/MissionAlternativeGenerators.kt`
- `core/src/main/kotlin/backend/yapp/core/mission/generation/domain/MissionGenerationJob.kt`, `MissionDraftTemplate.kt`
- `core/src/main/kotlin/backend/yapp/core/mission/generation/service/MissionLifecycleService.kt`, `MissionHistoryService.kt`
- `core/src/main/kotlin/backend/yapp/core/mission/survey/domain/MissionSurveyValidator.kt`
- `api/src/main/kotlin/backend/yapp/api/mission/generation/controller/MissionGenerationController.kt`
- `api/src/test/kotlin/backend/yapp/api/mission/generation/MissionGenerationAcceptanceTest.kt`
- `api/src/test/kotlin/backend/yapp/api/mission/lifecycle/MissionLifecycleAcceptanceTest.kt`, `MissionHistoryAcceptanceTest.kt`

## 구현 불일치와 확인 필요 사항

- FE는 생활·취미 소비를 한 달 기준으로 질문한다. BE는 입력을 환산하지 않고 `TIMES_PER_WEEK` 목표로 저장한다. [미션 소비 기준 기간 불일치](../domain/exceptions.md#미션-소비-기준-기간-불일치)로 남긴다.
- FE 미션 화면은 진행률을 반올림하고 BE 진행률 응답은 정수 나눗셈으로 소수점을 버린다. [미션 진행률 반올림 불일치](../domain/exceptions.md#미션-진행률-반올림-불일치)로 남긴다.
- 기존 [동기 미션 후보 API 명세](../domain/api-field-mappings/mission-generation.md)는 새 FE 화면이 동기 후보 조회를 사용한다고 설명하지만 고정 FE는 생성 작업 API를 사용한다. 해당 문서는 동기 조회 자체의 필드 계약으로만 해석하고 FE 적용 범위는 후속 정리가 필요하다.
- BE 초안·확정 응답은 절약 예상액 비정확성 고지를 포함하지만 FE 응답 스키마와 결과 화면은 고지를 사용하지 않는다.
- FE는 완료 카드에 삭제 동작을 노출하지 않지만 BE는 이번 주 완료 여부와 무관하게 소유한 미션을 삭제할 수 있다.
- 성공 후 초안이 만료되면 BE는 초안 조회 불가로 응답한다. 네이티브 보류 작업 복귀는 만료를 제거하지만 직접 열린 FE 로딩 화면은 이를 종료하지 못할 수 있다.

## 영향

- `POLICY-MISSION-001`의 활성 항목과 화면 기준 기간을 현재 카탈로그·입력 화면에 맞췄다.
- `POLICY-MISSION-002`와 `FLOW-MISSION-001`의 검색·AI 생성·횟수 분배 설명을 직접 템플릿·생성 작업·복귀·확정 흐름으로 교체했다.
- `POLICY-MISSION-003`과 `FLOW-MISSION-002`에 진행 중·완료 구분, 삭제, 월별 내역과 복구 동작을 추가했다.
- 운영·개선 작업은 구현 불일치를 정책으로 추론하지 않고 예외 목록에서 먼저 확인한다.

## 검토한 대안

- 기존 AI 생성 정책 유지: 고정 BE가 직접 템플릿만 사용해 현재 동작과 다르므로 제외했다.
- 동기 후보 조회를 현재 사용자 플로우로 채택: 고정 FE가 호출하지 않고 후보를 미션으로 저장할 계약도 없어 제외했다.
- FE 또는 BE 한쪽의 기간·진행률 계산을 공통 정책으로 선택: 서로 다른 구현 중 하나를 근거 없이 확정하게 되어 제외했다.
