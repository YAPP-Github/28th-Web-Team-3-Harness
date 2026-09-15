# 28th-Web-Team-3-Harness

FE와 BE가 함께 사용하는 도메인 컨텍스트와 AI 에이전트 자산 저장소입니다.

개발된 기능의 개선·수정·운영 작업을 시작할 때 관련 정책과 구현 근거를 함께 확인합니다. 문서의 기준일 이후 구현이 바뀌었을 수 있으므로, 문서를 현재 코드와 자동으로 동일시하지 않습니다.

## 작업 시작

1. [공통 지침](AGENTS.md)과 [용어집](domain/glossary.md)을 읽습니다.
2. 아래에서 작업 영역의 정책·플로우를 선택합니다.
3. [예외 사항](domain/exceptions.md), 관련 결정 기록의 상태와 기준 커밋을 확인합니다.
4. 수정 대상 FE·BE 코드와 대조합니다. 불일치는 근거와 함께 기록하고, 문서에 없는 정책을 확정하지 않습니다.

## 영역별 문서

아래 목록은 이 브랜치에 포함된 문서 기준입니다. 열린 PR의 문서는 병합 전까지 확정된 기준으로 취급하지 않습니다.

| 영역 | 정책 | 업무 플로우 |
| --- | --- | --- |
| 홈 | [목표·미션·혜택 요약](domain/policies/home-001-dashboard.md) | [홈 조회](domain/workflows/home-001-dashboard.md) |
| 온보딩 | [프로필](domain/policies/onboarding-001-profile.md), [목표](domain/policies/onboarding-002-goal.md) | [프로필·목표 설정](domain/workflows/onboarding-001-profile-and-goal.md), [프로필 변경](domain/workflows/onboarding-002-profile-update.md) |
| 미션 | [생성 입력](domain/policies/mission-001-survey.md), [생성](domain/policies/mission-002-generation.md), [수명주기](domain/policies/mission-003-lifecycle.md) | [입력·생성](domain/workflows/mission-001-survey-and-generation.md), [수명주기](domain/workflows/mission-002-lifecycle.md) |
| 혜택 | [탐색·저장](domain/policies/benefit-001-discovery-and-bookmark.md) | [조회·저장](domain/workflows/benefit-001-browse-and-bookmark.md) |
| 마이페이지 | [계정·지원](domain/policies/mypage-001-account-support.md) | [문의·탈퇴](domain/workflows/mypage-001-inquiry-and-withdrawal.md) |

- [API 필드 의미 매핑](domain/api-field-mappings/README.md): 구현 근거를 확인하는 보조 자료. 각 문서의 분석일·기준 브랜치·PR을 확인합니다.
- [미확정 필드 의미](domain/api-field-mappings/open-questions.md): 확인이 필요한 항목. 확정 정책과 구분합니다.
- [결정 기록](decisions/): 변경 배경과 대안. `superseded` 기록은 과거 맥락으로만 읽습니다.

## 관리 범위

- 공통 도메인 용어
- 확정된 비즈니스 정책과 불변조건
- 기획적 업무 플로우
- 예외와 알려진 특이사항
- 공통 에이전트와 스킬
- 정책 결정 기록과 작성 템플릿

FE 또는 BE에만 적용되는 구현 규칙, 실제 시크릿, 확정되지 않은 기획, API 명세 복제본은 관리하지 않습니다.

## 구조

```text
.
├── AGENTS.md
├── CLAUDE.md
├── README.md
├── .agents/
│   ├── agents/
│   └── skills/
├── .claude/
│   ├── agents -> ../.agents/agents
│   └── skills -> ../.agents/skills
├── .github/
│   └── PULL_REQUEST_TEMPLATE.md
├── domain/
│   ├── glossary.md
│   ├── policies/
│   ├── workflows/
│   ├── api-field-mappings/
│   └── exceptions.md
├── docs/
│   └── api-versioning.md
├── decisions/
└── templates/
    ├── policy.md
    ├── workflow.md
    └── decision-record.md
```

- `AGENTS.md`: 공통 에이전트 지침, 문서 읽기 순서, 작성 규칙
- `CLAUDE.md`: Claude Code 진입점
- `.agents/`: 공통 에이전트와 스킬 원본
- `.claude/`: Claude Code 호환 심볼릭 링크
- `.github/`: PR 템플릿
- `domain/`: 용어, 정책, 플로우, 특이사항
- `docs/`: 저장소 운영 문서
- `domain/api-field-mappings/`: API 필드 의미와 구현 근거, 확인이 필요한 항목
- `decisions/`: 정책과 플로우 결정 기록
- `templates/`: 정책, 플로우, 결정 기록 템플릿

API 배포 조합을 기록할 때는 [API 버전과 호환성 관리](docs/api-versioning.md)를 따른다.

## 서브모듈 초기화

새 클론:

```bash
git clone --recurse-submodules https://github.com/YAPP-Github/28th-Web-Team-3-FE.git
git clone --recurse-submodules https://github.com/YAPP-Github/28th-Web-Team-3-BE.git
```

기존 클론:

```bash
git submodule update --init --recursive
```

소비 저장소는 검증된 Harness 커밋을 고정합니다. `git submodule update --remote`로 자동 갱신하지 않습니다.

Harness 변경이 병합되면 FE와 BE의 서브모듈 포인터 갱신 PR을 함께 만듭니다. 두 저장소가 서로 다른 Harness 커밋을 오래 유지하면 공통 컨텍스트가 어긋납니다.

## 문서 작성

기존 동작을 바꾸는 작업은 관련 정책·플로우·예외를 함께 갱신하고, 변경 이유와 영향을 결정 기록에 남깁니다. 과거 결정은 삭제하지 않고 새 결정과 연결합니다. API 필드 매핑은 확정된 제품 정책을 대신하지 않습니다.

1. `domain/glossary.md`에서 기존 용어를 확인합니다.
2. `templates/`에서 문서 종류에 맞는 템플릿을 복사합니다.
3. 관련 정책, 플로우, 결정 ID를 서로 연결합니다.
4. 정책 또는 동작 변경은 FE와 BE 리뷰를 받습니다.

| 종류 | ID 형식 | 파일명 | 위치 | 템플릿 |
| --- | --- | --- | --- | --- |
| 정책 | `POLICY-<영역>-<3자리 번호>` | `<영역>-<번호>-<짧은-이름>.md` | `domain/policies/` | `templates/policy.md` |
| 플로우 | `FLOW-<영역>-<3자리 번호>` | `<영역>-<번호>-<짧은-이름>.md` | `domain/workflows/` | `templates/workflow.md` |
| 결정 기록 | 없음 (날짜 기반) | `YYYY-MM-DD-<짧은-제목>.md` | `decisions/` | `templates/decision-record.md` |

## 에이전트와 스킬

`.agents/`가 원본입니다. `.claude/agents`와 `.claude/skills`는 Claude Code 호환을 위한 상대 심볼릭 링크입니다.

- 에이전트: 역할, 입력, 수행 절차, 출력 형식, 금지 행동을 설명하는 마크다운 파일
- 스킬: `<skill-name>/SKILL.md` 구조
- 양쪽 파트에 같은 의미로 적용되는 것만 포함합니다. 특정 기술 스택 전용은 해당 FE 또는 BE 저장소에서 관리합니다.

상위 FE/BE 저장소에서 자동 발견되지 않으므로 필요한 작업에서 Harness 경로를 명시적으로 읽습니다.

현재 제공하는 스킬:

- [API 필드 문서화](.agents/skills/api-field-documentation/SKILL.md): Swagger와 구현을 대조해 필드 의미와 근거를 기록합니다.
- [PR 생성](.agents/skills/pr-create/SKILL.md): 문서 구조·ID·링크 검증과 리뷰를 거쳐 PR을 작성합니다.

`.agents/agents/`는 역할 정의를 위한 예약 경로이며, 현재 등록된 공통 에이전트는 없습니다.

## 변경 전 확인

- 정책·플로우 ID와 파일명이 기존 규칙을 따르고, ID가 중복되지 않는지 확인합니다.
- 해당 [정책](templates/policy.md)·[플로우](templates/workflow.md)·[결정](templates/decision-record.md) 템플릿의 필수 섹션을 확인합니다.
- 상대 링크 대상과 `.claude/` 심볼릭 링크가 유효한지 확인합니다.
- `git diff --check`로 공백 오류를 확인하고, 실제 인증 정보가 포함되지 않았는지 검토합니다.

별도 검증 스크립트는 두지 않습니다. PR 생성 절차의 문서 검증 게이트를 사용합니다.

## Windows

Windows 네이티브 Git은 심볼릭 링크 checkout을 위해 `core.symlinks=true`와 링크 생성 권한이 필요합니다.

```bash
git config core.symlinks true
git submodule update --init --recursive
```

링크가 일반 파일로 checkout되면 Windows 개발자 모드 또는 관리자 권한을 활성화한 뒤 다시 checkout합니다. 설정이 어려우면 WSL 사용을 권장합니다.

확인:

```bash
git ls-files -s .claude/agents .claude/skills
readlink .claude/agents
readlink .claude/skills
```

Git mode `120000`, 대상 `../.agents/agents`, `../.agents/skills`가 나와야 합니다.

## 리뷰 규칙

- 정책, 플로우, 결정, 공통 에이전트, 공통 스킬 동작 변경: FE 1명 + BE 1명
- 오타, 링크, 표현, 서식만 바꾸는 변경: 리뷰어 1명
