# BE Swagger·실제 API 분석 인벤토리

## 분석 방법

BE `origin/main` 커밋 `8298024`에서 Swagger 설정, API 문서 인터페이스(`apidoc/**`), 컨트롤러의 실제 매핑을 대조했다. 아래의 DTO는 Swagger가 request/response schema로 노출하는 타입이며, 이후 필드 의미 매핑의 분석 단위다.

`일치`는 Swagger 문서 계약과 컨트롤러 경로·HTTP 메서드가 대조되었다는 뜻이며, 모든 필드의 한국어 의미가 확정되었다는 뜻은 아니다.

## 게스트 인증 — 부분 문서화

`DELETE /api/auth/guest`는 BE PR #52 head commit `0dc9b7c`에서 추가된 계약이며, 나머지 인벤토리의 기준 커밋과 구분해 기록한다.

| HTTP | 경로 | request | response | Swagger 근거 |
| --- | --- | --- | --- | --- |
| POST | `/api/auth/guest` | `GuestAuthRequest` | `TokenResponse` | `GuestAuthApi.issue` |
| POST | `/api/auth/guest/refresh` | `RefreshTokenRequest` | `TokenResponse` | `GuestAuthApi.refresh` |
| DELETE | `/api/auth/guest` | 없음 (Bearer Access Token) | 없음 (`204`) | `GuestAuthApi.withdraw` |

이 영역의 필드와 탈퇴 계약은 [게스트 인증 문서](guest-auth.md)에 기록했다.

## 온보딩 — 일치

| HTTP | 경로 | request | response | Swagger 근거 |
| --- | --- | --- | --- | --- |
| PATCH | `/api/onboarding/profile` | `ProfilePatchRequest` | `ProfileResponse` | `OnboardingApi.patchProfile` |
| GET | `/api/onboarding/profile` | 없음 | `ProfileResponse` | `OnboardingApi.getProfile` |
| GET | `/api/onboarding/report` | 없음 | `ReportResponse` | `OnboardingApi.report` |
| GET | `/api/onboarding/goal-plans` | 없음 | `GoalPlansResponse` | `OnboardingApi.goalPlans` |
| POST | `/api/onboarding/goal` | `GoalConfirmRequest` | `GoalResponse` | `OnboardingApi.confirmGoal` |

## 목표 — 일치

| HTTP | 경로 | request | response | Swagger 근거 |
| --- | --- | --- | --- | --- |
| GET | `/api/goal` | 없음 | `GoalStatusResponse` | `GoalApi.get` |
| PUT | `/api/goal/savings` | `SavingRequest` | `GoalStatusResponse` | `GoalApi.setSaving` |
| PATCH | `/api/goal` | `GoalUpdateRequest` | `GoalStatusResponse` | `GoalApi.update` |

## 기존 미션 설문 — 폐기

`/api/missions/surveys/**`는 POLICY-MISSION-001 개편으로 비활성화되며 미션 카탈로그와 생성 요청 입력으로 대체한다.

## 미션 생성 — 일치

| HTTP | 경로 | request/parameter | response | Swagger 근거 |
| --- | --- | --- | --- | --- |
| POST | `/api/missions/generation-jobs` | `category`, `item`, `baselineFrequency`, `baselineAmountWon` | `MissionGenerationJobResponse` | `MissionGenerationApi.request` |
| GET | `/api/missions/generation-jobs/{jobId}` | path `jobId` | `MissionGenerationJobResponse` | `MissionGenerationApi.status` |
| GET | `/api/missions/generation-jobs/{jobId}/drafts` | path `jobId` | `MissionDraftsResponse` | `MissionGenerationApi.drafts` |
| POST | `/api/missions/generation-jobs/{jobId}/confirm` | path `jobId`, `MissionConfirmRequest` | `MissionConfirmResponse` | `MissionGenerationApi.confirm` |
| POST | `/api/missions/generations` | `category`, `item`, `baselineFrequency`, `baselineAmountWon` | `MissionCandidatesResponse` | `MissionCandidateApi.candidates` |

`POST /api/missions/generations`는 DB 템플릿 기반 후보 3개를 동기 반환하는 별도 조회 계약이다. job 생성·polling·후보 확정을 포함하지 않으며 현재 FE는 `/api/missions/generation-jobs/**`를 사용한다. 두 계약의 필드 규칙은 [미션 생성 API 필드 매핑](mission-generation.md)에 기록했다.

## 미션 수명주기 — 부분 문서화

| HTTP | 경로 | request/parameter | response | Swagger 근거 |
| --- | --- | --- | --- | --- |
| GET | `/api/missions/catalog` | 없음 | `MissionCatalogResponse` | `MissionController.catalog`의 `@Operation` |
| GET | `/api/missions` | query `status`, `category`(선택) | `MissionsResponse` | `MissionController.list`의 `@Operation` |
| GET | `/api/missions/progress` | query `category`(선택) | `MissionProgressResponse` | `MissionController.progress`의 `@Operation` |
| POST | `/api/missions/manual` | `ManualMissionCreateRequest` | `MissionLifecycleResponse` | `MissionController.createManual`의 `@Operation` |
| DELETE | `/api/missions/{source}/{missionId}` | path `source`, `missionId` | 없음 (`204`) | `MissionController.delete`의 `@Operation` |
| PATCH | `/api/missions/{source}/{missionId}/complete` | path `source`, `missionId` | `MissionLifecycleResponse` | `MissionController.complete`의 `@Operation` |

이 영역의 필드 의미는 [미션 수명주기 문서](mission-lifecycle.md)에 기록했다. API 문서 인터페이스가 없어 응답 schema·오류 응답 설명은 SpringDoc의 자동 생성에 의존한다.

## 헬스 — Swagger 문서 미구성

| HTTP | 경로 | request | response | Swagger 근거 |
| --- | --- | --- | --- | --- |
| GET | `/api/health` | 없음 | `HealthResponse` | 별도 `@Operation` 또는 `apidoc` 인터페이스 없음 |

## Swagger 문서화 구조에서 확인한 사항

- SpringDoc UI는 `/swagger-ui.html`, OpenAPI JSON은 `/v3/api-docs`로 설정돼 있다.
- 인증·온보딩·목표·미션 생성은 `apidoc` 인터페이스에 operation, schema, 성공/오류 response 설명을 둔다.
- 미션 수명주기는 컨트롤러의 `@Tag`, `@Operation`만 사용한다.
- 헬스 API에는 별도 Swagger 설명이 없다.
- 수용 테스트는 인증·목표·미션 생성·미션 수명주기의 OpenAPI 경로 공개를 검증한다.
