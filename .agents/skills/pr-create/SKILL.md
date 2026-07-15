---
name: pr-create
description: Harness 문서 검증 → AI 리뷰 → 푸시 → GitHub PR 생성까지 한번에 처리. "pr-create", "PR 만들어줘", "리뷰하고 PR" 등의 요청에 사용. main 브랜치로 머지하는 PR은 이 스킬로 생성할 것.
argument-hint: [브랜치]
---

문서 검증 게이트 → AI 리뷰 → 푸시 → PR 생성을 한번에 처리한다.
**셸 스크립트 없음** — 각 단계를 도구 호출로 실행한다.

이 저장소는 FE/BE 공통 도메인 문서·에이전트 자산 저장소다. 빌드·테스트가 없으므로
게이트는 문서 구조·컨벤션 검증으로 대체한다.

## 인자

- `$0`: PR을 올릴 **브랜치**(head). 생략 시 현재 브랜치 사용.
- 리뷰어 인자는 없다 — 팀 고정 리뷰어를 자동 지정한다(Step 6 참고).

## 강제 사용 규칙

- `main`으로 머지하는 PR은 이 스킬로 생성할 것. 이 저장소의 베이스는 항상 `main`이다.
- 사용자가 직접 `git push` + PR 수동 생성을 요청해도 이 스킬 사용을 권장할 것.
- **문서 검증 게이트가 빨간색이면 절대 PR을 생성/수정하지 않을 것.**
- **푸시·PR 생성 전 반드시 사용자 승인을 받을 것.**

## 실행 절차

### Step 0: GitHub CLI 확인 (필수)

1. `which gh`로 설치 여부 확인.
2. 미설치 시 **즉시 중단**하고 아래 안내 표시:

```
⚠️ GitHub CLI(gh)가 설치되어 있지 않습니다. 설치 후 다시 시도해주세요.

[Mac]    brew install gh
[Windows] winget install GitHub.cli  또는  scoop install gh

[설치 후 인증]
  gh auth login
```

3. `gh auth status`로 인증 상태 확인.
4. 미인증 시 `gh auth login` 안내 후 **즉시 중단**.
5. 설치·인증이 완료되지 않으면 이후 단계로 **절대 진행하지 않을 것**.
6. 컨텍스트 확보:
   - 레포 = `gh repo view --json nameWithOwner -q .nameWithOwner`
   - 현재 로그인 = `gh api user -q .login` → `ME`로 저장 (assignee 및 리뷰어 제외용)
   - 베이스 = `main` (고정).

### Step 1: 브랜치 확정

1. `$0`이 주어졌으면 그대로, 없으면 현재 브랜치 사용.
2. `git fetch origin --prune`.
3. 대상 브랜치로 전환(`git switch <브랜치>`, 없으면 `git switch -c <브랜치>`).

### Step 2: 변경사항 확인 (더티 트리 게이트)

1. `git status --short`로 커밋 안 된 변경 확인 — **있으면 사용자에게 알리고 중단**(먼저 커밋/스태시).
2. 포함될 커밋 목록: `git log origin/main..HEAD --oneline`.
3. 변경 파일 표시: `git diff --stat --merge-base origin/main HEAD`.
4. 베이스보다 앞선 커밋이 없으면 중단 — PR할 게 없음.

### Step 3: 문서 검증 게이트

아래 검증을 순서대로 실행한다. **하나라도 실패하면 즉시 중단**하고 실패 항목을 첨부한다.

1. **구조 검증**:

```bash
test "$(readlink .claude/agents)" = "../.agents/agents"
test "$(readlink .claude/skills)" = "../.agents/skills"
for f in AGENTS.md CLAUDE.md README.md domain/glossary.md domain/exceptions.md \
  templates/policy.md templates/workflow.md templates/decision-record.md; do
  test -f "$f" || exit 1
done
```

2. **ID·파일명 컨벤션 검증** (변경된 문서 대상):
   - `domain/policies/`, `domain/workflows/` 전체에서 `- ID:` 라인을 수집해 **중복 ID가 없는지** 확인.
   - 정책·플로우 파일명이 `<영역>-<번호>-<짧은-이름>.md` 형식인지 확인.
   - `decisions/` 파일명이 `YYYY-MM-DD-<짧은-제목>.md` 형식인지 확인.
3. **템플릿 필수 섹션 검증** (이번 diff에서 추가·수정된 문서만):
   - 정책: `## 규칙`, `## 불변조건`, `## 예외`, `## 관련 플로우와 결정`
   - 플로우: `## 정상 흐름`, `## 예외 흐름`, `## 관련 정책과 결정`
   - 결정 기록: `## 배경`, `## 결정`, `## 영향`, `## 검토한 대안`
4. **상대 링크 검증** (변경된 `.md`만): 마크다운 링크의 상대 경로 대상 파일이 존재하는지 `test -e`로 확인.
5. **시크릿 검증**: diff에서 토큰·키·비밀번호로 보이는 패턴(`api[_-]?key`, `secret`, `password`,
   `Bearer `, `-----BEGIN`)을 검사. 매칭되면 해당 라인을 보여주고 중단.

### Step 4: AI 리뷰 (Step 3 통과한 경우에만)

1. diff 범위는 공통: `git diff --merge-base origin/main HEAD`
2. 리뷰를 디스패치한다:
   - Task 도구로 **`general-purpose`** 서브에이전트. 프롬프트에 head 브랜치, 베이스(`main`),
     diff 범위와 함께 **이 저장소의 리뷰 관점**을 전달한다:
     - 콘텐츠 경계 위반: FE 또는 BE에만 적용되는 기술 규칙, API 명세 복제, 확정되지 않은 기획이 들어왔는가
     - 용어 일관성: 새 용어가 `domain/glossary.md`에 등록됐는가, 같은 개념에 다른 이름을 쓰지 않았는가
     - ID 상호 링크: 정책·플로우·결정이 관련 문서 ID를 서로 링크했는가
     - 정책 품질: 문서에 없는 정책을 추론해 확정한 흔적, 모호하거나 기존 정책과 충돌하는 내용이 있는가
     프롬프트 끝에 **언어 규칙**을 명시한다: "리뷰는 한국어로 작성하되 코드 식별자·경로·정책 ID는
     모두 백틱(``)으로 감쌀 것. 영어 개념을 축자 번역한 어색한 번역투 금지." (서브에이전트는 독립
     세션이라 이 규칙을 상속받지 못하므로 매번 프롬프트에 넣어야 한다.)
   - **Codex 교차 리뷰** — openai-codex 플러그인이 설치된 경우에만. 리뷰 전용 companion script 실행:
     `node ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs review --wait`
     (버전 디렉터리는 glob으로 해석 — 여러 개면 최신 버전 사용. `--wait` 필수.)
     플러그인이나 Codex CLI가 없으면 생략하고 "Codex 교차 리뷰 생략됨"만 알림 — 실패로 취급하지 않는다.
2. 리뷰 결과(판정 + 발견 사항) 모두 사용자에게 표시. 두 리뷰가 실행됐으면 최종 판정은 더 나쁜 쪽 채택
   (Codex 출력엔 판정 이모지가 없으므로 blocking·치명 이슈가 있으면 🔴로 취급).
   **언어 정규화**: Codex는 영어로 출력하므로, 사용자에게 보여주거나 PR 본문(Step 7)에 붙이기 전에
   한국어로 옮긴다 — 발견 사항의 의미·심각도·파일/라인은 보존하고, 식별자는 백틱으로 감싼다.
3. 판정에 따라:
   - 🔴 **변경 요청** (둘 중 하나라도) → 사용자에게 경고. 멈추고 먼저 고칠지, draft로 진행할지 질문. **말없이 진행 금지.**
   - 🟡 이하 → 결과 보여주고 계속 진행 여부 확인.

### Step 5: 푸시 (승인 게이트)

1. **사용자에게 푸시 승인을 명시적으로 받을 것.** 승인 전 푸시 금지.
2. 승인 후 `git push -u origin <브랜치>`.
3. 실패 시 원인 분석 후 보고.

### Step 6: 리뷰어 지정 (팀 고정, 본인 제외)

**팀 고정 리뷰어** (변동 시 이 표만 수정):

| 이름 | GitHub |
| --- | --- |
| 문세종 | `jongse7` |
| 정용훈 | `hoonloper` |
| 김동균 | `d6nggyun` |

1. 리뷰어 = 위 3명 중 `ME`(Step 0)를 제외한 전원. `ME`가 표에 없으면 3명 전원.
2. **assignee = `ME`**.
3. 제외 후 리뷰어가 0명이 되는 경우는 없다(표가 3명이므로 최소 2명 보장).
4. 사용자가 "리뷰어 없이" 또는 특정 인원 지정으로 **명시적으로** 오버라이드하면 따를 것
   (그 경우에도 먼저 스킬 규칙임을 한 번 알리고 확인받을 것).

### Step 7: PR 생성 (승인 게이트)

1. `.github/PULL_REQUEST_TEMPLATE.md`가 존재하면 **그 섹션 구조 그대로** 플레이스홀더만 채운다.
   없으면 아래 구조를 사용한다:

```
## 📝 작업 내용 요약

<diff 요약 2–5 bullet(무엇이 왜 바뀌었는지), 한국어>
- resolved #<브랜치명/커밋에서 찾은 이슈 번호, 없으면 이 줄 삭제>

## ✅ 체크리스트

- [x] `main` 브랜치의 최신 코드를 `pull` 받았나요?
- [x] 문서 검증 게이트(구조·ID·템플릿·링크·시크릿)를 통과했나요?
- [x] 새 문서는 `templates/`를 복사해 작성했나요?
- [x] 관련 정책·플로우·결정 ID를 서로 링크했나요?

## 🤖 AI 리뷰

<Step 4 리뷰 판정 + 발견 사항 전체 붙여넣기. Codex 교차 리뷰가 실행됐으면
"### Claude" / "### Codex 교차 리뷰" 소제목으로 각각 구분.
두 블록 모두 한국어로, 식별자·파일 경로·정책 ID는 백틱으로 감싼다 — Codex 영어 출력은
Step 4의 언어 정규화를 거친 한국어 버전을 붙인다(영어 원문 그대로 붙이지 말 것).>

## 💬 기타 코멘트

<후속 작업·리뷰어에게 남길 메모, 없으면 비움. Harness 변경이 병합되면
FE/BE 서브모듈 포인터 갱신 PR을 함께 만들어야 함을 여기에 명시>
```

2. **PR 생성 전 사용자 승인을 받을 것.** 본문을 임시 파일에 쓰고 `--body-file`로 전달:

```bash
gh pr create \
  --base main \
  --head <브랜치> \
  --title "<요약에서 뽑은 간결한 제목>" \
  --assignee "@me" \
  --reviewer "<리뷰어1>" --reviewer "<리뷰어2>" [--reviewer "<리뷰어3>"] \
  --body-file <tmp> \
  [Step 4가 🔴이고 사용자가 draft 선택 시 --draft]
```

3. PR URL과 한 줄 요약 출력(문서 검증 ✅ / AI 리뷰 판정 / assignee / 리뷰어).
4. 병합 후 후속 작업 안내: FE와 BE 저장소에서 서브모듈 포인터 갱신 PR을 함께 만들 것.

## 주의사항

- gh 미설치/미인증 시 절대 진행하지 않고 안내 후 중단.
- 더티 트리(커밋 안 된 변경)면 중단.
- 문서 검증 게이트가 빨강이면 PR 생성 금지.
- **푸시·PR 생성 전 반드시 사용자 승인.**
- assignee는 본인(`@me`), 리뷰어 목록에서 본인 제외.
- PR 제목은 커밋 컨벤션 prefix(docs/feat/fix/chore 등) 영어, subject는 한글/영문 모두 가능, 50자 이내.
- 리뷰어 없는 PR은 생성하지 않을 것(사용자의 명시적 오버라이드가 있으면 예외, Step 6.4 참고).
- 실제 시크릿·인증 정보·개인 정보가 diff에 보이면 PR을 만들지 말고 즉시 보고.
