# 미션 도메인 공통 기준 기록

- 날짜: 2026-07-24
- 상태: accepted
- 관련 정책과 플로우: [POLICY-MISSION-001](../domain/policies/mission-001-survey.md), [POLICY-MISSION-002](../domain/policies/mission-002-generation.md), [POLICY-MISSION-003](../domain/policies/mission-003-lifecycle.md), [FLOW-MISSION-001](../domain/workflows/mission-001-survey-and-generation.md), [FLOW-MISSION-002](../domain/workflows/mission-002-lifecycle.md)

## 배경

미션 설문, 생성·확정, 추천·수동 미션 생명주기는 백엔드 PR [#13](https://github.com/YAPP-Github/28th-Web-Team-3-BE/pull/13), [#15](https://github.com/YAPP-Github/28th-Web-Team-3-BE/pull/15), [#19](https://github.com/YAPP-Github/28th-Web-Team-3-BE/pull/19), [#20](https://github.com/YAPP-Github/28th-Web-Team-3-BE/pull/20), [#28](https://github.com/YAPP-Github/28th-Web-Team-3-BE/pull/28), [#30](https://github.com/YAPP-Github/28th-Web-Team-3-BE/pull/30)에 구현되었지만, FE와 BE가 함께 읽는 도메인 기준 문서에는 정리되지 않았다.

## 결정

현재 구현으로 확인되는 FE·BE 공통 동작만 정책과 플로우로 기록한다. 추천 가중치, AI 공급자, 저장 방식, API 경로처럼 특정 구현에 속하는 내용은 공통 하네스에서 제외한다.

## 영향

미션 화면과 서버 구현은 같은 용어, 생성 선행 조건, 초안 확정과 미션 종료 규칙을 참조할 수 있다. 온보딩 자체의 정책은 이 기록의 범위에 포함하지 않는다.

## 검토한 대안

- 백엔드 코드만 기준으로 유지: FE가 참조할 공통 용어와 업무 흐름이 분산된다.
- 추천 알고리즘과 AI 연동 세부사항까지 기록: 특정 기술 구현을 공통 도메인 규칙으로 고정하게 된다.
