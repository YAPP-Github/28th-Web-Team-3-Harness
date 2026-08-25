# Glossary

| 용어 | 정의 | 사용 금지 표현 | 관련 정책 |
| --- | --- | --- | --- |
| 미션 생성 입력 | 추천 미션을 만들기 위해 카테고리·항목·기준 빈도·기준 금액을 대화형 화면에서 순서대로 입력하는 과정 | 미션 설문, AI 설문 | [POLICY-MISSION-001](policies/mission-001-survey.md) |
| 미션 항목 | 식비·생활·취미 카테고리 안에서 서버 카탈로그가 활성 상태로 제공하는 구체적 소비 대상 | 설문 종류 | [POLICY-MISSION-001](policies/mission-001-survey.md) |
| 소비 기준 | 추천 미션 문구의 목표 횟수와 절약 예상액에 사용하는 사용자의 기준 빈도와 기준 금액 | 실측값, AI 계산값 | [POLICY-MISSION-001](policies/mission-001-survey.md), [POLICY-MISSION-002](policies/mission-002-generation.md) |
| 추천 미션 생성 작업 | 입력 하나에 직접 템플릿 초안 3개와 만료 시각을 연결하고 조회·확정 상태를 관리하는 작업 단위 | AI 미션 생성 작업, 설문 생성 | [POLICY-MISSION-002](policies/mission-002-generation.md) |
| 미션 초안 | 생성 작업에 저장되어 사용자가 확정할 수 있는 직접 템플릿 기반 대안 | 강도 단계, AI 후보 | [POLICY-MISSION-002](policies/mission-002-generation.md) |
| 동기 미션 후보 조회 | 직접 템플릿 후보 3개를 저장·생성 작업·상태 조회 없이 즉시 받는 조회 전용 호출 | 동기 미션 저장, 미션 확정 | [POLICY-MISSION-002](policies/mission-002-generation.md) |
| 추천 미션 | 사용자가 생성 작업의 미션 초안을 확정해 매주 수행하는 미션 | AI 미션 | [POLICY-MISSION-002](policies/mission-002-generation.md), [POLICY-MISSION-003](policies/mission-003-lifecycle.md) |
| 직접 추가 미션 | 사용자가 활성 카테고리와 최대 30자 문구를 직접 입력한 미션 | 수동 미션 | [POLICY-MISSION-003](policies/mission-003-lifecycle.md) |
| 주간 완료 | 미션 정의와 분리해 미션 출처·ID와 서울 시간 기준 월요일 시작일별로 한 번 저장하는 완료 체크 | 종료 상태 | [POLICY-MISSION-003](policies/mission-003-lifecycle.md) |
| 절약 예상액 | 추천 미션 완료 시 아낄 수 있다고 안내하는 단순 추정 금액으로 현재는 입력 기준 금액을 그대로 사용한 값 | AI 추정 금액, 실절약액 | [POLICY-MISSION-002](policies/mission-002-generation.md) |
| 미션 내역 | 월별 각 주의 미션 전체 수와 완료 수로 과거 수행 결과를 보여 주는 기록 화면 | 완료 미션 목록 | [POLICY-MISSION-003](policies/mission-003-lifecycle.md) |

같은 개념에 여러 이름을 사용하지 않는다. 새 용어는 한 문장으로 정의하고 관련 정책 ID를 연결한다.
