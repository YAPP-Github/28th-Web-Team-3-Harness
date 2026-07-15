# 28th-Web-Team-3-Harness

FE와 BE가 함께 사용하는 도메인 컨텍스트와 AI 에이전트 자산 저장소입니다.

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
│   └── exceptions.md
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
- `decisions/`: 정책과 플로우 결정 기록
- `templates/`: 정책, 플로우, 결정 기록 템플릿

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
