# 기존 미션 정책 전면 교체

- 날짜: 2026-08-10
- 상태: accepted
- 관련 정책과 플로우: [POLICY-MISSION-001](../domain/policies/mission-001-survey.md), [POLICY-MISSION-002](../domain/policies/mission-002-generation.md), [POLICY-MISSION-003](../domain/policies/mission-003-lifecycle.md), [FLOW-MISSION-001](../domain/workflows/mission-001-survey-and-generation.md), [FLOW-MISSION-002](../domain/workflows/mission-002-lifecycle.md)

## 배경

기존 다중 카테고리 설문과 주간 종료 상태 모델은 항목별 소비 기준을 사용한 AI 대안 미션 및 반복 체크 방식과 양립하지 않는다.

## 결정

기존 설문·교통·주간 자동 마감·실측 완료 입력·강도 단계·그룹형 노출 정책을 폐기한다. 항목 하나의 소비 빈도와 금액을 입력해 대안을 만들고, 서버가 횟수와 100원 단위 절약 예상액을 결정하며, 주간 완료 행을 별도로 누적하는 모델로 전환한다.

교통 미션과 연결 이력은 물리 삭제한다. 이후 사용자가 삭제하는 미션은 soft delete해 과거 집계 근거를 보존한다.

## 영향

기존 미션 설문 API는 사용하지 않는다. 온보딩 프로필에 거주지역이 추가되며, AI 생성은 네이버 블로그 검색과 기존 Gemini 호출을 결합한다. 혜택/팁 데이터는 사용자별로 저장하지만 조회 API는 별도 작업으로 남긴다.

## 검토한 대안

- 항목당 미션 하나 제한: 같은 항목으로 여러 대안을 반복 생성할 수 있어야 하므로 제외했다.
- AI가 횟수·절약액 생성: 결과 재현성과 검증 가능성을 위해 서버 결정론 계산을 채택했다.
- 완료 상태를 미션 행에 저장: 주간 반복과 과거 이력 보존을 위해 별도 주간 완료 행을 채택했다.
