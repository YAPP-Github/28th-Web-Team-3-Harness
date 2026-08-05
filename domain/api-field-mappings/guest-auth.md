# 게스트 인증 API 필드 매핑

## 범위와 근거

- 기준: BE PR [#52 회원 탈퇴 기능 추가](https://github.com/YAPP-Github/28th-Web-Team-3-BE/pull/52)의 head commit `0dc9b7c`
- Swagger/OpenAPI 경로: `/api/auth/guest`, `/api/auth/guest/refresh`
- 실제 컨트롤러: `api/.../auth/controller/GuestAuthController.kt`
- DTO: `GuestAuthRequest`, `RefreshTokenRequest`, `TokenResponse`
- 정책 근거: GitHub 이슈 [#50 회원 탈퇴 기능 추가](https://github.com/YAPP-Github/28th-Web-Team-3-BE/issues/50)
- 동작 검증: `GuestAuthService`, `GuestWithdrawalService`, `GuestAuthAcceptanceTest`

토큰 값과 UUID는 인증·식별에 사용하는 민감 값이므로 예시 실제 값이나 운영 로그를 이 문서에 기록하지 않는다.

## API별 입출력

| API | request/parameter | response |
| --- | --- | --- |
| `POST /api/auth/guest` | body `uuid` | `accessToken`, `refreshToken` |
| `POST /api/auth/guest/refresh` | body `refreshToken` | `accessToken`, `refreshToken` |
| `DELETE /api/auth/guest` | `Authorization: Bearer <access token>` | 없음 (`204`) |

## 요청·응답 필드

| JSON 경로 / header | 한국어 의미 | 값·생성 규칙 | 사용 API | 상태 | 근거 |
| --- | --- | --- | --- | --- | --- |
| `uuid` | 클라이언트가 제공하는 게스트 식별값 | 공백이 아닌 UUID 문자열. 같은 식별값은 기존 게스트 계정에 매핑되며, 탈퇴 뒤 다시 요청하면 새 계정이 생성된다. | 토큰 발급 | 확정 | `GuestAuthRequest`, 컨트롤러 UUID 검증, `issueForIdentifier`, 탈퇴 수용 테스트 |
| `refreshToken` (body) | Access Token을 재발급하기 위한 갱신 토큰 | 공백 불가. 유효한 토큰은 한 번만 소비하며, 재발급 시 기존 토큰은 재사용할 수 없다. | 토큰 재발급 | 확정 | `RefreshTokenRequest`, `rotate`, 수용 테스트 |
| `accessToken` | 보호된 API 요청에 사용하는 접근 토큰 | 토큰 발급·재발급 시 반환. `DELETE /api/auth/guest`에는 Bearer 인증으로 전달한다. 탈퇴 뒤에는 계정 존재 여부 검증으로 더 이상 인증되지 않는다. | 토큰 발급·재발급·회원 탈퇴 | 확정 | `TokenResponse`, `authenticate`, `SecurityConfig`, 탈퇴 수용 테스트 |
| `refreshToken` (response) | 이후 토큰 재발급에 사용하는 갱신 토큰 | 토큰 발급·재발급 시 반환. 탈퇴 트랜잭션에서 삭제되어 이후 재발급에 사용할 수 없다. | 토큰 발급·재발급 | 확정 | `TokenResponse`, `RefreshTokenRepository`, `GuestWithdrawalService`, 탈퇴 수용 테스트 |
| `Authorization` header | 탈퇴 요청자 인증 정보 | `Bearer <access token>` 형식. 누락·무효 토큰은 `401`이다. 별도 재인증 또는 요청 본문은 없다. | 회원 탈퇴 | 확정 | `GuestAuthApi.withdraw`, `SecurityConfig`, 탈퇴 수용 테스트 |

## 회원 탈퇴 계약

`DELETE /api/auth/guest`는 인증된 현재 게스트 계정과 사용자 귀속 데이터를 하나의 트랜잭션에서 hard delete한다.

- 성공하면 `204 No Content`를 반환한다.
- 인증되지 않았거나 이미 탈퇴한 access token은 `401 UNAUTHORIZED`다.
- 온보딩, 목표·월별 저축, 미션 설문, 미션 생성 작업·초안·추천 및 수동 미션, 결과 이벤트·추천 이력, refresh token과 계정을 삭제한다.
- 다른 게스트 사용자의 데이터에는 영향을 주지 않는다.
- 계정 삭제 단계가 실패하면 앞선 삭제를 롤백한다.
- 진행 중인 미션 생성이 탈퇴 뒤 완료되더라도 삭제된 job을 찾지 못하면 결과를 저장하지 않고 종료한다.
- 탈퇴 사유와 개인식별 가능한 탈퇴 감사 로그는 이 범위에서 수집하지 않는다.

## 문서화 범위

이 문서는 클라이언트가 요청·응답 필드와 탈퇴 후 인증 상태를 이해하도록 돕는 의미 사전이다. 토큰 저장 위치, 로그 보존 정책의 세부 운영 절차, 탈퇴 유예·복구 기능은 이번 계약 범위에 포함하지 않는다.
