# 마이페이지 main 구현 기준 채택

- 날짜: 2026-08-25
- 상태: accepted
- 관련 정책과 플로우: [POLICY-MYPAGE-001](../domain/policies/mypage-001-account-support.md), [FLOW-MYPAGE-001](../domain/workflows/mypage-001-inquiry-and-withdrawal.md)

## 배경

마이페이지 정책을 먼저 정하고 구현하던 방식 대신, 완료된 FE·BE의 같은 시점 `main` 구현을 운영 기준으로 역문서화한다. 작업 중 원격 변경과 기존 미병합 문서의 영향을 피하려고 조사 대상을 다음 커밋으로 고정했다.

- Harness: `d6c9f2da757b9688a6748d0e766354737904a3ff`
- FE: `6ba701fb3c85a8980ab090b9321f645edcfab325`
- BE: `6deb8af2f5e167cbbaf0d15ce9a025cf7c7a6227`

FE에서는 마이페이지·프로필 진입, 공개 법률 문서, 문의 채널, 앱 버전, 탈퇴 화면과 인증 API·네이티브 토큰 처리 및 관련 테스트를 조사했다. BE에서는 현재 사용자 조회, 게스트 탈퇴 API, 탈퇴 트랜잭션과 사용자 귀속 저장소, 인증·탈퇴 테스트를 조사했다.

주요 조사 파일은 다음과 같다.

- FE: `apps/web/app/(tabs)/mypage/page.tsx`, `apps/web/app/(tabs)/mypage/_components/inquiry-sheet.tsx`, `apps/web/app/(tabs)/mypage/_components/app-version-row.tsx`, `apps/web/app/(tabs)/mypage/_components/withdrawal-button.tsx`
- FE: `apps/web/app/legal/terms/page.tsx`, `apps/web/app/legal/privacy/page.tsx`, `apps/web/app/profile/page.tsx`, `apps/web/src/api/auth.ts`, `apps/native/src/auth/guest-auth.ts`와 각 관련 테스트
- BE: `api/src/main/kotlin/backend/yapp/api/auth/controller/CurrentUserController.kt`, `api/src/main/kotlin/backend/yapp/api/auth/controller/GuestAuthController.kt`
- BE: `core/src/main/kotlin/backend/yapp/core/auth/service/GuestWithdrawalService.kt`, `api/src/test/kotlin/backend/yapp/api/auth/CurrentUserAcceptanceTest.kt`, `api/src/test/kotlin/backend/yapp/api/auth/GuestAuthAcceptanceTest.kt`, `core/src/test/kotlin/backend/yapp/core/auth/service/GuestWithdrawalServiceTest.kt`

## 결정

고정된 FE 구현을 화면·안내·외부 이동·복구 동작의 기준으로, BE 구현을 인증·데이터 삭제·토큰 무효화·트랜잭션 불변조건의 기준으로 채택한다.

마이페이지의 내 정보는 프로필 조회로 가는 진입점까지만 이 모듈에서 다룬다. 프로필 값의 저장과 목표 기간 변경은 온보딩·목표 모듈의 정책 범위로 남긴다. 현재 사용자 조회는 사용자 ID와 온보딩 완료 여부를 반환하는 인증 계약으로 확인했지만, 마이페이지 화면이 이 조회를 직접 호출한다고 기록하지 않는다.

이용약관과 개인정보처리방침은 인증 영역 밖에 있는 공개 문서이며 공통 시행일은 2026년 8월 10일이다. 문의 화면은 유효한 카카오톡 오픈채팅 주소를 우선하고, 설정이 없거나 유효하지 않으면 개인정보 문의용 이메일로 대체한다. 앱 버전은 네이티브 앱이 유효한 값을 돌려줄 때만 표시한다.

탈퇴는 사용자의 재확인을 거친 뒤 게스트 귀속 데이터를 한 트랜잭션으로 hard delete한다. 삭제 대상은 혜택 저장 내역, 미션·추천·수행 기록, 온보딩 정보, 목표·저축 정보, refresh token과 게스트 계정이다. 성공 후 기존 access token과 refresh token은 거절되며, 같은 기기 식별자로 재진입해도 새 사용자 ID를 발급한다. 앱 삭제만으로 서버 탈퇴 요청이 발생한다는 근거는 없어 두 동작을 같게 취급하지 않는다.

구현에서 확인한 차이는 다음과 같이 보존한다.

- 이용약관의 통지 문구는 마이페이지 문의하기를 카카오톡 오픈채팅으로 표현하지만, 실제 문의 화면은 설정 오류나 누락 시 이메일로 대체한다. 운영 정책은 사용 가능한 문의 채널을 보장하는 실제 화면 동작을 따르며 법률 문구 정합성은 별도 검토가 필요하다.
- 개인정보처리방침은 관계 법령상 보존 의무가 있는 경우 보관 가능성을 안내하지만, 조사한 탈퇴 서비스는 현재 모델링된 모든 사용자 귀속 행을 삭제하며 보존 예외를 구현하지 않는다. 법적 보존 대상 추가 여부는 근거 없이 확정하지 않는다.
- 서버 탈퇴 성공 뒤 네이티브 토큰 정리가 실패해도 FE는 온보딩 첫 화면으로 이동한다. 서버가 기존 계정과 토큰을 이미 무효화하므로 삭제 결과를 되돌리지 않는다.
- 기존 미병합 `codex/docs-mypage-benefits` 브랜치는 이번 기준에 포함하지 않는다.

## 영향

마이페이지 개선·수정 작업은 공개 법률 문서 접근, 항상 사용 가능한 문의 경로, 조건부 앱 버전 표시, 명시적 탈퇴 확인, 전체 삭제의 원자성과 기존 토큰 무효화를 회귀 조건으로 확인한다.

법률 문서의 문의 채널·보존 문구를 바꾸거나, 탈퇴 데이터 보존 예외를 추가하거나, 앱 삭제를 탈퇴와 연계하려면 FE·BE 구현과 법률 문구를 함께 검토하고 별도 결정을 남겨야 한다.

## 검토한 대안

- 기존 미병합 혜택·마이페이지 문서를 그대로 사용: 고정된 최신 `main`보다 오래된 구현을 기준으로 만들 수 있어 제외했다.
- 화면 시안과 문구만 정책으로 채택: 데이터 삭제 범위, 토큰 무효화, 실패 시 롤백을 설명할 수 없어 제외했다.
- 저장소별 삭제 순서와 브릿지 구현을 정책에 그대로 기록: 공통 도메인 규칙이 아닌 기술 세부사항이므로 결정 기록의 조사 근거로만 남겼다.
