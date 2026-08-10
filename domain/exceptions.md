# Exceptions

정책과 플로우만 읽으면 놓치기 쉬운 공통 특이사항을 기록한다.

각 항목은 다음 정보를 포함한다.

- 적용 범위
- 발생 조건
- 기대 동작
- 관련 정책과 플로우 ID

## 미션 생성 작업 경합

- 적용 범위: AI 미션 생성 요청
- 발생 조건: 같은 사용자가 서로 다른 항목 또는 소비 기준으로 생성 작업을 동시에 요청함
- 기대 동작: 진행 중인 다른 입력의 작업을 반환하지 않고 충돌을 알린다. 같은 입력 재요청은 기존 작업을 반환할 수 있다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-002](policies/mission-002-generation.md), [FLOW-MISSION-001](workflows/mission-001-survey-and-generation.md)

## 주간 완료 중복 요청

- 적용 범위: AI·직접 추가 미션의 이번 주 완료
- 발생 조건: 같은 미션의 완료 요청이 동시에 처리됨
- 기대 동작: `(mission source, mission id, week start date)` 유일성을 보장하고 한 건만 완료로 취급한다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-003](policies/mission-003-lifecycle.md), [FLOW-MISSION-002](workflows/mission-002-lifecycle.md)
