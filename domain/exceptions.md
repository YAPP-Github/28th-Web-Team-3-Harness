# Exceptions

정책과 플로우만 읽으면 놓치기 쉬운 공통 특이사항을 기록한다.

각 항목은 다음 정보를 포함한다.

- 적용 범위
- 발생 조건
- 기대 동작
- 관련 정책과 플로우 ID

## 미션 생성 작업 경합

- 적용 범위: 추천 미션 생성 작업 요청
- 발생 조건: 같은 사용자의 생성 작업이 끝나기 전에 다시 요청함
- 기대 동작: 카테고리·항목·기준 빈도·기준 금액이 모두 같으면 기존 작업을 반환한다. 하나라도 다르면 진행 중인 입력을 새 입력으로 덮지 않고 충돌을 반환한다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-002](policies/mission-002-generation.md), [FLOW-MISSION-001](workflows/mission-001-survey-and-generation.md)

## 미션 확정 중복과 충돌

- 적용 범위: 생성 작업의 미션 초안 확정
- 발생 조건: 같은 작업을 두 번 이상 확정함
- 기대 동작: 선택 ID 순서와 무관하게 같은 초안 집합이면 기존 미션을 반환한다. 다른 집합이면 첫 확정 결과를 유지하고 충돌을 반환한다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-002](policies/mission-002-generation.md), [FLOW-MISSION-001](workflows/mission-001-survey-and-generation.md)

## 생성 작업 성공 후 초안 만료

- 적용 범위: 성공한 추천 미션 생성 작업의 복귀·상태 조회·초안 조회
- 발생 조건: 생성 성공 후 24시간이 지나 초안을 조회할 수 없게 됨
- 기대 동작: 네이티브 복귀 처리는 만료된 보류 작업을 제거한다. 고정 기준 클라이언트의 로딩 화면은 `성공했지만 초안 조회 불가`를 종료 상태로 처리하지 않아 직접 진입 시 상태 조회를 계속할 수 있으므로 운영·개선 시 별도 만료 복구가 필요하다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-002](policies/mission-002-generation.md), [FLOW-MISSION-001](workflows/mission-001-survey-and-generation.md)

## 미션 소비 기준 기간 불일치

- 적용 범위: 추천 미션의 생활·취미 기준 빈도와 기준 금액
- 발생 조건: 클라이언트는 한 달 기준으로 질문하지만 서버는 전달값을 환산하지 않고 목표 단위를 주당 횟수로 저장함
- 기대 동작: 현재 구현 차이를 문서에 그대로 남긴다. 월간 값을 주간 값으로 간주하거나 임의 환산하는 정책을 확정하지 않고 FE·BE가 기준 기간을 합의한 뒤 함께 수정한다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-001](policies/mission-001-survey.md), [POLICY-MISSION-002](policies/mission-002-generation.md), [FLOW-MISSION-001](workflows/mission-001-survey-and-generation.md)

## 주간 완료 중복 요청

- 적용 범위: 추천·직접 추가 미션의 이번 주 완료
- 발생 조건: 같은 미션의 완료 요청이 반복되거나 동시에 처리됨
- 기대 동작: 미션 출처·미션 ID·주 시작일 조합당 한 건만 완료로 취급한다. 같은 요청의 반복 결과는 완료 상태다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-003](policies/mission-003-lifecycle.md), [FLOW-MISSION-002](workflows/mission-002-lifecycle.md)

## 미션 진행률 반올림 불일치

- 적용 범위: 이번 주 미션 진행률 표시
- 발생 조건: 완료 수를 전체 수로 나눈 값이 정수가 아님
- 기대 동작: 고정 기준 클라이언트 미션 화면은 반올림하고 서버 진행률 응답은 소수점을 버린다. 예를 들어 2/3은 각각 67%와 66%다. 어느 값을 공통 기준으로 삼을지 추론하지 않고 개선 시 계산 규칙을 통일한다.
- 관련 정책과 플로우 ID: [POLICY-MISSION-003](policies/mission-003-lifecycle.md), [FLOW-MISSION-002](workflows/mission-002-lifecycle.md)
