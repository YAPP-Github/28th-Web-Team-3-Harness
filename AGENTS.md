# Team 3 Common Agent Harness

## Purpose

FE와 BE가 같은 도메인 의미와 기획적 업무 플로우를 기준으로 작업하게 한다.

## Reading Order

1. `domain/glossary.md`
2. 관련 `domain/policies/` 문서
3. 관련 `domain/workflows/` 문서
4. `domain/exceptions.md`
5. 관련 `decisions/` 문서

## Rules

- 문서에 없는 정책을 추론해 확정하지 않는다.
- 모호하거나 충돌하는 내용은 구현 전에 보고한다.
- FE 또는 BE에만 적용되는 기술 규칙을 이 저장소에 추가하지 않는다.
- 실제 시크릿, 인증 정보, 개인 정보를 기록하지 않는다.
- 새 문서는 `templates/`의 해당 템플릿을 복사해 작성한다.

## Document Conventions

| 종류 | ID 형식 | 파일명 | 위치 |
| --- | --- | --- | --- |
| 정책 | `POLICY-<영역>-<3자리 번호>` | `<영역>-<번호>-<짧은-이름>.md` | `domain/policies/` |
| 플로우 | `FLOW-<영역>-<3자리 번호>` | `<영역>-<번호>-<짧은-이름>.md` | `domain/workflows/` |
| 결정 기록 | 없음 (날짜 기반) | `YYYY-MM-DD-<짧은-제목>.md` | `decisions/` |

- 같은 개념에 여러 이름을 사용하지 않는다. 새 용어는 `domain/glossary.md`에 한 문장으로 정의하고 관련 정책 ID를 연결한다.
- 정책, 플로우, 결정 문서는 관련 문서의 ID를 서로 링크한다.

## Shared Agents & Skills

- `.agents/agents/`: FE와 BE가 함께 사용하는 역할 기반 에이전트 정의. 각 파일은 역할, 입력, 수행 절차, 출력 형식, 금지 행동을 설명한다.
- `.agents/skills/`: FE와 BE가 함께 사용하는 반복 가능한 작업 절차. 각 스킬은 `<skill-name>/SKILL.md` 구조를 사용한다.
- 양쪽 파트에 같은 의미로 적용되는 것만 포함한다. 특정 기술 스택 전용은 해당 FE 또는 BE 저장소에서 관리한다.
