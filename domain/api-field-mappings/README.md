# API 필드 의미 매핑

## 목적

Swagger/OpenAPI에 노출되는 영문 request/response/parameter 필드를, 실제 BE 구현을 근거로 한 한국어 의미와 연결한다. 이 디렉터리는 Swagger 명세의 복제본이 아니라 필드 의미 사전이다.

## 분석 기준

- 대상 저장소: `28th-Web-Team-3-BE`
- 기준 브랜치: `origin/main`
- 기준 커밋: `8298024` (`ci : Gemini API 키 시크릿 주입`)
- Swagger UI 경로: `/swagger-ui.html`
- OpenAPI JSON 경로: `/v3/api-docs`
- 분석일: 2026-07-28

BE의 로컬 `main` 작업 트리에 사용자 변경 사항이 있어, 해당 변경은 분석하지 않았다.

## 상태

| 상태 | 의미 |
| --- | --- |
| 확정 | Swagger 설명, DTO, 컨트롤러, 서비스 또는 테스트가 한국어 의미를 직접 뒷받침한다. |
| 사용자 확인 필요 | 코드로 형태·흐름은 확인했지만 제품에서 사용할 한국어 명칭 또는 정책을 정할 근거가 없다. |
| 미착수 | 아직 필드별 대조를 시작하지 않았다. |

## API 인벤토리

| 영역 | 실제 API 수 | Swagger 문서 방식 | 필드 매핑 상태 |
| --- | ---: | --- | --- |
| 게스트 인증 | 2 | `GuestAuthApi` 인터페이스 | 미착수 |
| 온보딩 | 5 | `OnboardingApi` 인터페이스 | 진행 중 — [문서](onboarding.md) |
| 목표 | 3 | `GoalApi` 인터페이스 | 미착수 |
| 미션 설문 | 3 | `MissionSurveyApi` 인터페이스 | 미착수 |
| 미션 생성 | 4 | `MissionGenerationApi` 인터페이스 | 미착수 |
| 미션 수명주기 | 4 | 컨트롤러 어노테이션 | 진행 중 — [문서](mission-lifecycle.md) |
| 헬스 | 1 | 별도 API 문서 없음 | 미착수 |

총 22개 API를 컨트롤러 기준으로 확인했다. 각 영역의 Swagger 계약과 실제 컨트롤러 경로는 이후 필드 문서화 전에 다시 대조한다.

전체 경로·DTO·Swagger 문서 범위는 [API 분석 인벤토리](api-inventory.md)에서 확인한다.

GitHub 이슈와의 추가 대조 결과는 [이슈 검증 기록](github-issue-validation.md)에서 확인한다.

## 문서화 순서

1. Swagger 설명과 실제 경로를 대조한다.
2. request, response, path/query parameter를 DTO 단위로 수집한다.
3. 서비스·도메인·수용 테스트로 필드 생성 규칙과 값 의미를 확인한다.
4. 근거가 충분한 필드만 `확정`으로 기록한다.
5. 제품 용어 또는 값의 한국어 명칭이 불명확하면 [확인 목록](open-questions.md)에 추가하고 사용자 확인 뒤 반영한다.

재사용 DTO의 필드는 한 영역 문서에서 정의하고, 다른 API에서는 그 문서를 참조한다.
