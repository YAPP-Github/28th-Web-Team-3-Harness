# 온보딩 main 구현을 정책 기준으로 채택

- 날짜: 2026-08-25
- 상태: accepted
- 관련 정책과 플로우: [POLICY-ONBOARDING-001](../domain/policies/onboarding-001-profile.md), [POLICY-ONBOARDING-002](../domain/policies/onboarding-002-goal.md), [FLOW-ONBOARDING-001](../domain/workflows/onboarding-001-profile-and-goal.md), [FLOW-ONBOARDING-002](../domain/workflows/onboarding-002-profile-update.md)

## 배경

온보딩 정책이 개발 중 바뀌었고 기존 Harness에는 API 필드 의미만 있으며 현재 사용자 흐름을 설명하는 정책과 플로우가 없다. 완료된 FE와 BE 구현에서 이후 개선·수정·운영 작업의 공통 기준을 역문서화할 필요가 있다.

조사 기준은 다음 커밋으로 고정했다.

- FE `YAPP-Github/28th-Web-Team-3-FE`: `6ba701fb3c85a8980ab090b9321f645edcfab325`
- BE `YAPP-Github/28th-Web-Team-3-BE`: `6deb8af2f5e167cbbaf0d15ce9a025cf7c7a6227`
- Harness `YAPP-Github/28th-Web-Team-3-Harness`: `d6c9f2da757b9688a6748d0e766354737904a3ff`

주요 조사 파일은 다음과 같다.

- FE: `apps/native/src/auth/guest-auth.ts`, `apps/web/app/_components/onboarding-route-guard.tsx`, `apps/web/app/onboarding/`, `apps/web/app/profile/edit/page.tsx`, `apps/web/src/api/onboarding.ts`, `apps/web/lib/queries/onboarding.ts`, `packages/schema/src/onboarding.ts`, `packages/schema/src/onboarding-api.ts` 및 대응 테스트·E2E 테스트
- BE: `GuestAuthController.kt`, `GuestAuthService.kt`, `CurrentUserController.kt`, `OnboardingController.kt`, `OnboardingV2Controller.kt`, `OnboardingProfileService.kt`, `GoalService.kt`, 온보딩 DTO·도메인·서비스·계산기 및 `GuestAuthAcceptanceTest.kt`, `OnboardingAcceptanceTest.kt`, `OnboardingGoalV2AcceptanceTest.kt`

## 결정

- FE는 사용자에게 실제로 제공되는 질문 순서, 입력 범위, 화면 전환, 오류와 복구 동작의 기준으로 사용한다.
- BE는 게스트 식별, 저장 데이터, 입력 유효성, 목표 계산, 완료 상태와 트랜잭션의 기준으로 사용한다.
- 현재 FE가 사용하는 프로필 부분 저장과 v2 목표 미리보기·확정 경로를 공식 온보딩 흐름으로 채택한다. 서버에 남아 있는 목표안 기반 v1 경로는 현재 공식 화면 정책에서 제외한다.
- 목표 확정 전에는 `IN_PROGRESS`, 목표와 완료 상태가 함께 생성된 뒤에는 `COMPLETED`로 본다. 외부 화면의 완료 판정은 서비스 목표 존재 여부를 사용한다.
- 온보딩 완료 후 내 정보 수정은 최초 온보딩의 부분 저장과 구분한다. FE는 프로필 전체 수정 요청을 보내고, BE는 기존 목표가 있으면 순자산·월 저축액·목표 기간으로 목표를 재계산한다.
- 현재 FE는 완료 사용자가 목표 기간을 바꾼 경우 프로필 전체 수정 성공 뒤 목표 기간 수정 요청도 보낸다. 두 번째 요청만 실패하면 첫 번째 요청을 반복하지 않고 목표 기간 동기화부터 재시도한다.
- 기존 [온보딩 API 필드 매핑](../domain/api-field-mappings/onboarding.md)은 이전 BE 기준과 v1 목표안 계약을 포함하므로 이번 결정의 현재 흐름 근거로 사용하지 않는다.

구현에서 확인한 차이는 다음처럼 확정하지 않고 경계로 남긴다.

- FE는 월급·월 저축액을 각각 1~650만원으로 제한하지만 BE는 0~650만원을 허용한다.
- FE는 목표 기간을 6개월 단위의 6~36개월로 제공하지만 BE는 3~36개월의 모든 정수를 허용한다.
- BE는 새 프로필의 거주지역을 서울로 기본 설정한다. FE는 서울을 무응답으로 오인하지 않도록 사용자별 확인 기록이 있어야 답변으로 인정한다.
- FE는 생년월일, 거주지역, 월급, 월 저축액, 순자산, 목표 기간이 모두 있어야 목표 화면을 연다. BE 목표 준비 검사는 거주지역, 월 저축액, 목표 기간만 요구한다. BE는 순자산 누락을 0으로 계산하고, 월급 누락 시 월급 상한 없이 현재 월 저축액의 150%를 최댓값으로 사용한다.
- BE는 150% 최댓값과 서버 설정의 권장 상향률을 퍼밀 정수 연산으로 계산한다. 계산 결과가 0.5만원처럼 정수 만원 단위 사이에 놓이면 소수 부분을 버린다. FE는 서버가 반환한 정수 최댓값과 권장값을 그대로 사용한다.
- BE의 현재 프로필 조회는 저장된 행이 없어도 빈 `IN_PROGRESS` 응답을 반환한다. FE에는 과거 `404 ONBOARDING_PROFILE_NOT_FOUND`도 빈 프로필로 복구하는 호환 처리가 남아 있다.

## 영향

- 온보딩 개선은 공식 화면의 더 좁은 입력·완료 조건을 깨지 않아야 한다.
- 서버 계약을 공식 화면에 맞게 좁히거나 화면 범위를 서버 계약까지 넓힐 때는 위 차이를 별도 정책 결정으로 해소해야 한다.
- 목표안 기반 화면을 다시 도입하지 않는 한 `PLAN_1`, `PLAN_2`는 온보딩 사용자 용어로 사용하지 않는다.
- 주소 기본값이나 클라이언트 확인 기록을 변경하면 기존 사용자의 재진입 동작을 함께 검토해야 한다.
- 내 정보 수정의 프로필·목표 동기화 순서를 바꾸면 첫 요청만 성공한 부분 실패 복구와 캐시 무효화 범위를 함께 검토해야 한다.

## 검토한 대안

- 기존 API 필드 매핑만 유지: 화면 순서, 재진입, v2 목표 확정과 오류 복구를 설명하지 못해 제외했다.
- FE와 BE의 넓은 범위를 합쳐 하나의 입력 규칙으로 확정: 실제 화면과 서버 경계를 모두 왜곡하므로 차이를 명시하는 방식을 채택했다.
- 서버에 남은 v1·v2 목표 경로를 모두 공식 정책으로 기록: 현재 FE가 v2만 사용하므로 운영 중인 사용자 흐름과 혼동되어 제외했다.
