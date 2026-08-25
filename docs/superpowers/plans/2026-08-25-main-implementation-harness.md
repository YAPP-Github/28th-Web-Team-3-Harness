# Main Implementation Harness Documentation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 완료된 FE·BE `main` 구현을 홈·온보딩·미션·혜택·마이페이지별 독립 Harness 브랜치에 정책·플로우·기준 결정으로 역문서화한다.

**Architecture:** Harness `main`의 같은 커밋에서 모듈별 worktree와 브랜치를 직접 분기한다. 각 모듈은 고정된 FE·BE 커밋을 독립 조사하고, 문서 검증과 AI 리뷰를 거쳐 커밋·푸시하되 PR은 만들지 않는다.

**Tech Stack:** Markdown, Git worktree, ripgrep, FE TypeScript/React 소스, BE Kotlin/Spring 소스

**Spec:** `docs/superpowers/specs/2026-08-25-main-implementation-harness-design.md`

## Global Constraints

- Harness 기준은 `d6c9f2da757b9688a6748d0e766354737904a3ff`이다.
- FE 기준은 `6ba701fb3c85a8980ab090b9321f645edcfab325`이다.
- BE 기준은 `6deb8af2f5e167cbbaf0d15ce9a025cf7c7a6227`이다.
- FE는 화면·입력·전환·안내·복구 동작의 근거로 사용한다.
- BE는 저장 데이터·유효성·상태 전이·권한·불변조건의 근거로 사용한다.
- 충돌하거나 근거가 부족한 정책을 추론해 확정하지 않는다.
- FE 또는 BE에만 적용되는 기술 규칙을 Harness에 추가하지 않는다.
- 실제 시크릿, 인증 정보, 개인정보와 환경별 실제 URL을 기록하지 않는다.
- 새 정책·플로우는 `templates/`의 필수 섹션을 모두 유지한다.
- 모든 브랜치는 독립적이며 다른 모듈 브랜치를 병합하거나 cherry-pick하지 않는다.
- 각 브랜치는 커밋·푸시까지만 수행하고 GitHub PR을 생성하지 않는다.

---

### Task 1: 홈 모듈 역문서화

**Branch:** `codex/harness-home`

**Files:**
- Create: `domain/policies/home-001-dashboard.md`
- Create: `domain/workflows/home-001-dashboard.md`
- Create: `decisions/2026-08-25-home-main-baseline.md`
- Modify: `domain/glossary.md`
- Existing: `docs/superpowers/specs/2026-08-25-main-implementation-harness-design.md`
- Existing: `docs/superpowers/plans/2026-08-25-main-implementation-harness.md`

- [ ] FE 홈 페이지, 목표 섹션, 주간 미션 섹션, 절약 팁 섹션과 테스트를 조사한다.
- [ ] BE 목표·미션·팁 조회 계약과 상태 계산을 조사한다.
- [ ] 목표 진행 현황, 이번 주 미션 요약, 절약 팁 표시·이동·실패 동작을 정책으로 작성한다.
- [ ] 홈 진입부터 부분 데이터 조회와 사용자 이동까지 정상·예외 흐름을 작성한다.
- [ ] FE·BE 기준 SHA, 조사 파일, 구현 불일치와 범위 경계를 결정 기록에 작성한다.
- [ ] 홈 전용 공통 용어만 용어집에 추가한다.
- [ ] 구조·ID·필수 섹션·상대 링크·시크릿을 검증한다.
- [ ] 변경을 자체 검토하고 커밋한다.

### Task 2: 온보딩 모듈 역문서화

**Branch:** `codex/harness-onboarding`

**Files:**
- Create: `domain/policies/onboarding-001-profile.md`
- Create: `domain/policies/onboarding-002-goal.md`
- Create: `domain/workflows/onboarding-001-profile-and-goal.md`
- Create: `decisions/2026-08-25-onboarding-main-baseline.md`
- Modify: `domain/glossary.md`

- [ ] FE 게스트 진입, 온보딩 질문, 입력 검증, 확인, 목표, 결과와 복귀 동작을 조사한다.
- [ ] BE 게스트 인증, 온보딩 저장·조회, 목표 생성·조회 계약과 유효성 규칙을 조사한다.
- [ ] 프로필 질문값·완료 조건·재진입 규칙을 첫 정책에 작성한다.
- [ ] 목표 입력·계산·저장·조회 규칙을 둘째 정책에 작성한다.
- [ ] 게스트 진입부터 결과 확인과 홈 이동까지 정상·예외 흐름을 작성한다.
- [ ] FE·BE 기준 SHA, 조사 파일, 구현 불일치와 범위 경계를 결정 기록에 작성한다.
- [ ] 온보딩 전용 공통 용어만 용어집에 추가한다.
- [ ] 구조·ID·필수 섹션·상대 링크·시크릿을 검증한다.
- [ ] 변경을 자체 검토하고 커밋한다.

### Task 3: 미션 모듈 최신화

**Branch:** `codex/harness-mission`

**Files:**
- Modify: `domain/policies/mission-001-survey.md`
- Modify: `domain/policies/mission-002-generation.md`
- Modify: `domain/policies/mission-003-lifecycle.md`
- Modify: `domain/workflows/mission-001-survey-and-generation.md`
- Modify: `domain/workflows/mission-002-lifecycle.md`
- Create: `decisions/2026-08-25-mission-main-baseline.md`
- Modify: `domain/glossary.md`
- Modify: `domain/exceptions.md`

- [ ] FE 설문, 대화형·직접 생성, 동기 후보·job, 확정, 수행, 완료·삭제, 기록과 복귀 처리를 조사한다.
- [ ] BE 설문, 동기 후보 생성, 직접 템플릿, 생성 job, 선택, 생명주기, 기록 계약과 상태 전이를 조사한다.
- [ ] 기존 미션 문서의 각 규칙을 고정 구현과 대조하고 오래된 규칙만 수정한다.
- [ ] 동기 생성, 직접 템플릿, 삭제와 복귀 흐름을 기존 정책·플로우 구조 안에 반영한다.
- [ ] 경합·중복 요청·종료 상태 특이사항을 `domain/exceptions.md`에서 최신화한다.
- [ ] FE·BE 기준 SHA, 조사 파일, 변경된 기존 정책과 구현 불일치를 결정 기록에 작성한다.
- [ ] 새 미션 용어만 용어집에 추가하고 기존 정의를 중복하지 않는다.
- [ ] 구조·ID·필수 섹션·상대 링크·시크릿을 검증한다.
- [ ] 변경을 자체 검토하고 커밋한다.

### Task 4: 혜택 모듈 역문서화

**Branch:** `codex/harness-benefits`

**Files:**
- Create: `domain/policies/benefit-001-discovery-and-bookmark.md`
- Create: `domain/workflows/benefit-001-browse-and-bookmark.md`
- Create: `decisions/2026-08-25-benefit-main-baseline.md`
- Modify: `domain/glossary.md`

- [ ] FE 정책·절약 팁 탭, 필터, 카드, 저장 토글, 저장 목록, 취소 확인과 테스트를 조사한다.
- [ ] BE 정책·팁 조회, 분류, 북마크 생성·삭제·조회 계약과 유효성 규칙을 조사한다.
- [ ] 콘텐츠 유형, 필터, 페이지 조회, 표시 분류, 저장 일관성, 외부 이동 규칙을 정책으로 작성한다.
- [ ] 화면 진입, 탭·필터 전환, 추가 조회, 저장·해제, 저장 목록, 실패 복구 흐름을 작성한다.
- [ ] FE·BE 기준 SHA, 조사 파일, 구현 불일치와 기존 미병합 문서의 비기준 상태를 결정 기록에 작성한다.
- [ ] 혜택 전용 공통 용어만 용어집에 추가한다.
- [ ] 구조·ID·필수 섹션·상대 링크·시크릿을 검증한다.
- [ ] 변경을 자체 검토하고 커밋한다.

### Task 5: 마이페이지 모듈 역문서화

**Branch:** `codex/harness-mypage`

**Files:**
- Create: `domain/policies/mypage-001-account-support.md`
- Create: `domain/workflows/mypage-001-inquiry-and-withdrawal.md`
- Create: `decisions/2026-08-25-mypage-main-baseline.md`
- Modify: `domain/glossary.md`

- [ ] FE 약관, 개인정보처리방침, 문의 채널, 앱 버전, 탈퇴 확인·실패·성공 처리를 조사한다.
- [ ] BE 현재 사용자 조회, 게스트 탈퇴, 토큰·데이터 처리 계약과 불변조건을 조사한다.
- [ ] 공개 법률 문서, 문의 대체 채널, 버전 표시, 탈퇴와 앱 삭제 차이를 정책으로 작성한다.
- [ ] 문의 외부 이동과 탈퇴 확인·처리·복구의 정상·예외 흐름을 작성한다.
- [ ] FE·BE 기준 SHA, 조사 파일, 구현 불일치와 기존 미병합 문서의 비기준 상태를 결정 기록에 작성한다.
- [ ] 마이페이지 전용 공통 용어만 용어집에 추가한다.
- [ ] 구조·ID·필수 섹션·상대 링크·시크릿을 검증한다.
- [ ] 변경을 자체 검토하고 커밋한다.

### Task 6: 독립 검토와 원격 푸시

**Branches:** 위 5개 브랜치

- [ ] 각 브랜치의 기준 커밋부터 HEAD까지 review package를 만든다.
- [ ] 각 모듈을 FE·BE 고정 SHA와 대조하는 독립 AI 리뷰를 수행한다.
- [ ] Critical·Important 지적을 해당 모듈 브랜치에서 수정하고 재검토한다.
- [ ] 각 브랜치에서 문서 검증 명령을 새로 실행하고 작업 트리가 깨끗한지 확인한다.
- [ ] `codex/harness-home`을 `origin`에 푸시한다.
- [ ] `codex/harness-onboarding`을 `origin`에 푸시한다.
- [ ] `codex/harness-mission`을 `origin`에 푸시한다.
- [ ] `codex/harness-benefits`를 `origin`에 푸시한다.
- [ ] `codex/harness-mypage`를 `origin`에 푸시한다.
- [ ] 원격 브랜치 5개가 존재하고 PR이 생성되지 않았음을 확인한다.
