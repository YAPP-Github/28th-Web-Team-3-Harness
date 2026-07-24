# Exceptions

정책과 플로우만 읽으면 놓치기 쉬운 공통 특이사항을 기록한다.

각 항목은 다음 정보를 포함한다.

- 적용 범위
- 발생 조건
- 기대 동작
- 관련 정책과 플로우 ID

## 미션 설문 동시 수정

- 적용 범위: 미션 설문 저장
- 발생 조건: 같은 사용자의 설문 교체 요청이 동시에 처리되어 기존 응답이 달라질 수 있음
- 기대 동작: 충돌한 요청은 저장하지 않으며, 최신 설문 상태를 다시 확인해야 한다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-001](policies/mission-001-survey.md), [FLOW-MISSION-001](workflows/mission-001-survey-and-generation.md)

## 미션 종료 상태 경합

- 적용 범위: 추천·수동 미션의 완료와 주간 종료
- 발생 조건: 사용자의 완료 요청과 주간 종료 처리가 같은 미션에 동시에 적용됨
- 기대 동작: 먼저 확정된 완료 또는 미완료 상태를 유지하며, 종료 상태를 다시 바꾸지 않는다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-003](policies/mission-003-lifecycle.md), [FLOW-MISSION-002](workflows/mission-002-lifecycle.md)
