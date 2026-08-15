# MyPage and Benefits Domain Documentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** FE `origin/develop`의 마이페이지와 혜택 동작을 Harness 공통 정책·플로우·용어 문서로 만든다.

**Architecture:** 화면별 정책과 사용자 플로우를 분리하고 서로 상대 링크로 연결한다. Figma는 화면 의도 확인에 사용하며 동작 충돌은 고정된 FE 기준 SHA를 따른다.

**Tech Stack:** Markdown, Git, Harness 문서 규칙

**Spec:** `docs/superpowers/specs/2026-08-15-mypage-benefits-domain-design.md`

## Global Constraints

- 정책 기준은 FE `origin/develop` 커밋 `0386b29c95a28be493425418bfa754ebbf47a518`이다.
- 코드와 Figma가 다르면 FE 동작을 따른다.
- FE 또는 BE에만 적용되는 기술 규칙을 추가하지 않는다.
- 실제 URL, 시크릿, 인증 정보, 개인정보를 기록하지 않는다.
- 새 문서는 Harness 템플릿의 모든 섹션을 유지한다.

---

### Task 1: 마이페이지 정책과 플로우 작성

**Files:**
- Create: `domain/policies/mypage-001-account-support.md`
- Create: `domain/workflows/mypage-001-inquiry-and-withdrawal.md`

- [ ] `POLICY-MYPAGE-001`에 약관, 개인정보처리방침, 문의 채널 대체 규칙, 버전 표시 조건, 탈퇴 불변조건을 기록한다.
- [ ] `FLOW-MYPAGE-001`에 문의와 탈퇴의 정상·예외 흐름을 기록한다.
- [ ] 두 문서에 상호 상대 링크를 추가한다.

### Task 2: 혜택 정책과 플로우 작성

**Files:**
- Create: `domain/policies/benefit-001-discovery-and-bookmark.md`
- Create: `domain/workflows/benefit-001-browse-and-bookmark.md`

- [ ] `POLICY-BENEFIT-001`에 필터, 목록, 저장, 공식 신청 페이지 이동 규칙을 기록한다.
- [ ] `FLOW-BENEFIT-001`에 조회, 필터 전환, 추가 조회, 저장 변경, 이동 실패 흐름을 기록한다.
- [ ] 두 문서에 상호 상대 링크를 추가한다.

### Task 3: 공통 용어 등록

**Files:**
- Modify: `domain/glossary.md`

- [ ] 마이페이지, 문의 채널, 탈퇴, 혜택, 혜택 분류, 저장한 혜택을 한 문장으로 정의한다.
- [ ] 각 용어에 사용 금지 표현과 관련 정책 링크를 기록한다.

### Task 4: 검증과 PR 준비

**Files:**
- Verify: `AGENTS.md`
- Verify: `.github/PULL_REQUEST_TEMPLATE.md`

- [ ] 구조, ID, 파일명, 필수 섹션, 상대 링크, 시크릿을 검사한다.
- [ ] 변경 diff를 자체 검토한다.
- [ ] AI 리뷰 결과를 PR 본문에 기록한다.
- [ ] 사용자 승인을 받아 브랜치를 푸시한다.
- [ ] 지정 리뷰어 문세종, 정용훈, 김동균을 요청해 `main` 대상 PR을 생성한다.
