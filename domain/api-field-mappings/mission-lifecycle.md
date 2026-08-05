# 미션 수명주기 API 필드 매핑

## 범위와 근거

- 기준: BE PR #53 (`feat/48-manual-mission-api`)
- Swagger/OpenAPI 경로: `/api/missions`, `/api/missions/manual`, `/api/missions/recommended/{missionId}`, `/api/missions/{source}/{missionId}/complete`
- 실제 컨트롤러: `api/.../mission/lifecycle/controller/MissionController.kt`
- DTO: `api/.../mission/lifecycle/dto/MissionLifecycleDtos.kt`
- 의미 검증: `MissionLifecycleService.kt`, `Mission.kt`, `ManualMission.kt`, `MissionLifecycleAcceptanceTest.kt`

`MissionLifecycleResponse`는 수동 미션 생성, 목록 조회, 완료 API에서 공통으로 사용된다.

## API별 입출력

| API | request/parameter | response |
| --- | --- | --- |
| `GET /api/missions` | query `status`(선택) | `missions[]` |
| `POST /api/missions/manual` | body | `MissionLifecycleResponse` |
| `DELETE /api/missions/recommended/{missionId}` | path `missionId` | 없음 (`204`) |
| `PATCH /api/missions/{source}/{missionId}/complete` | path `source`, `missionId` | `MissionLifecycleResponse` |

## 요청·파라미터

| JSON 경로 / parameter | 한국어 의미 | 값·제약 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `status` (query) | 미션 상태 필터 | `ACTIVE`, `COMPLETED`, `INCOMPLETE` 중 하나를 선택적으로 전달 | 확정 | 컨트롤러가 상태와 일치하는 미션만 반환; 상태 enum과 서비스 목록 필터 |
| `category` | 미션 카테고리 | `MEAL`(식사), `TRANSPORT`(교통), `HOBBY`(취미), `LIVING`(생활) | 확정 | 사용자 확인, `MissionCategory` enum 및 닫힌 GitHub 이슈 #10의 초기 미션 원형 카테고리 |
| `text` | 사용자가 작성한 수동 미션 내용 | 앞뒤 공백 제거 후 1~30자 | 확정 | `ManualMissionCreateRequest`, `createManual`, 수동 미션 생성 수용 테스트 |
| `missionId` (path) | 미션 식별자 | UUID | 확정 | 컨트롤러 path variable 및 수용 테스트 |
| `source` (path) | 미션 생성 출처 | `RECOMMENDED`(추천 미션), `MANUAL`(사용자 수동 생성 미션) | 확정 | `MissionSource` enum, 완료 서비스 분기, 컨트롤러 태그 설명 |

## 공통 응답: `MissionLifecycleResponse`

| JSON 경로 | 한국어 의미 | 값·생성 규칙 | 상태 | 근거 |
| --- | --- | --- | --- | --- |
| `id` | 미션 식별자 | UUID | 확정 | 공통 응답 DTO, `Mission`/`ManualMission` 엔티티 |
| `source` | 미션 생성 출처 | `RECOMMENDED` 또는 `MANUAL` | 확정 | `LifecycleMissionSnapshot` 변환 |
| `category` | 미션 카테고리 | `MEAL`(식사), `TRANSPORT`(교통), `HOBBY`(취미), `LIVING`(생활) | 확정 | 요청 `category`와 동일한 근거 |
| `title` | 미션 제목 | 추천 미션은 생성된 제목, 수동 미션은 입력 `text` | 확정 | `Mission.toSnapshot`, `ManualMission.toSnapshot` |
| `targetCount` | 각 미션에서 수행해야 할 행위의 횟수 | 추천 미션에만 제공 | 확정 | 공통 snapshot/응답 변환, 수동 응답에서는 미직렬화 |
| `targetUnit` | 각 미션에서 수행해야 할 행위의 시간 단위 | 추천 미션에만 제공 | 확정 | 공통 snapshot/응답 변환, 수동 응답에서는 미직렬화 |
| `estimatedSavingsWon` | 미션 달성 시 예상 절약액 | 원화 정수인 추정치이며 추천 미션에만 제공 | 확정 | 응답 DTO, 추천 미션 변환 |
| `savingsEstimateVersion` | 예상 절약 금액 산정 버전 | 추천 미션에만 제공 | 확정 | 응답 DTO, 추천 미션 변환 |
| `savingsLabel` | 예상 절약 금액 표시 문구 | 추천 미션에만 제공하며 `약 {estimatedSavingsWon}원 절약 예상` 형식 | 확정 | `MissionLifecycleResponse.from` |
| `status` | 미션 진행 상태 | `ACTIVE`(진행 중), `COMPLETED`(완료), `INCOMPLETE`(주간 종료까지 완료되지 않아 미완료 확정) | 확정 | enum, 완료 로직, 기한 경과 처리 로직, GitHub 이슈 #10 |
| `weekEndsAt` | 해당 주 미션의 종료 시각 | Asia/Seoul 기준 다음 월요일 00:00 시각 | 확정 | `weekEnd` 구현과 수용 테스트 |

## 완료 API 확인

`PATCH /api/missions/{source}/{missionId}/complete`는 본문 없이 미션을 완료 처리하고 위 공통 응답을 반환한다.

- `ACTIVE` 미션은 `COMPLETED`로 바뀐다.
- 이미 `COMPLETED`이면 같은 응답을 반환하는 멱등 동작이다.
- `INCOMPLETE`이면 `MISSION_STATUS_CONFLICT`로 완료할 수 없다.
- 다른 사용자의 미션 또는 없는 미션은 `MISSION_NOT_FOUND`이다.

## 문서화 범위

이 문서는 프론트엔드 개발자가 DTO 필드의 의미를 이해하도록 돕는 의미 사전이다. 화면에 노출할 정확한 라벨·카피는 범위에 포함하지 않는다.
