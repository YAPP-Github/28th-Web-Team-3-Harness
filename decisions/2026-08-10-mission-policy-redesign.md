# 기존 미션 정책 전면 교체

- 날짜: 2026-08-10
- 상태: superseded
- 대체 결정: [2026-08-25-mission-main-baseline](2026-08-25-mission-main-baseline.md)
- 관련 정책과 플로우: [POLICY-MISSION-001](../domain/policies/mission-001-survey.md), [POLICY-MISSION-002](../domain/policies/mission-002-generation.md), [POLICY-MISSION-003](../domain/policies/mission-003-lifecycle.md), [FLOW-MISSION-001](../domain/workflows/mission-001-survey-and-generation.md), [FLOW-MISSION-002](../domain/workflows/mission-002-lifecycle.md)

## 배경

이 기록은 2026-08-10 당시 제안된 전환 방향을 보존한다. 기존 다중 카테고리 설문과 주간 종료 상태 모델은 항목별 소비 기준을 사용한 대안 미션 및 반복 체크 방식과 양립하지 않는다고 판단했다.

## 결정

당시에는 기존 설문·교통·주간 자동 마감·실측 완료 입력·강도 단계·그룹형 노출 정책을 폐기하기로 했다. 항목 하나의 소비 빈도와 금액을 입력해 대안을 만들고, 서버가 횟수와 100원 단위 절약 예상액을 결정하며, 주간 완료 행을 별도로 누적하는 모델을 채택했다.

교통 미션과 연결 이력은 물리 삭제한다. 이후 사용자가 삭제하는 미션은 soft delete해 과거 집계 근거를 보존한다.

## 영향

당시 영향으로 기존 미션 설문 API를 사용자 플로우에서 제외하고 온보딩 프로필에 거주지역을 추가했다. 네이버 블로그 검색과 Gemini 호출을 결합한 AI 생성 및 100원 단위 계산은 현재 기준이 아니다. 현재 구현은 직접 템플릿과 입력 기준 금액을 그대로 사용하며, 자세한 기준은 대체 결정을 따른다.

## 검토한 대안

- 항목당 미션 하나 제한: 같은 항목으로 여러 대안을 반복 생성할 수 있어야 하므로 제외했다.
- AI가 횟수·절약액 생성: 결과 재현성과 검증 가능성을 위해 서버 결정론 계산을 채택했다.
- 완료 상태를 미션 행에 저장: 주간 반복과 과거 이력 보존을 위해 별도 주간 완료 행을 채택했다.
