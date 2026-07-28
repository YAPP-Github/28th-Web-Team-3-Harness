# GitHub 이슈 기반 검증 기록

## 검증 범위

- 대상 저장소: `YAPP-Github/28th-Web-Team-3-BE`
- 확인일: 2026-07-28
- 대조 대상: 현재 필드 의미 문서, BE `origin/main` 커밋 `8298024`, 관련 GitHub 이슈

이슈는 제품 의도와 용어를 보강하는 근거로만 사용했다. 이슈의 미구현 제안 필드를 현재 Swagger 계약으로 기록하지 않았다.

## 결과

| 이슈 | 상태 | 검증한 항목 | 결과 |
| --- | --- | --- | --- |
| [#10](https://github.com/YAPP-Github/28th-Web-Team-3-BE/issues/10) 미션 생성 로직 | closed | 카테고리, 주간 상태, 목표 횟수·단위, 예상 절약액 | 일치. 사용자 확인에 따라 `MEAL/TRANSPORT/HOBBY/LIVING`은 각각 식사/교통/취미/생활이다. `INCOMPLETE`는 주간 종료까지 완료되지 않은 상태다. |
| [#18](https://github.com/YAPP-Github/28th-Web-Team-3-BE/issues/18) 미션 생성 프로세스 | closed | 초안의 목표 횟수·단위, 확정 후 `ACTIVE` 상태 | 일치. `targetCount`, `targetUnit`은 LLM이 임의 변경하지 않는 구조화 값이며 초안·확정 미션의 공통 의미다. |
| [#33](https://github.com/YAPP-Github/28th-Web-Team-3-BE/issues/33) 추천 미션 개별 삭제 | closed | `DELETE /api/missions/recommended/{missionId}`의 범위 | 일치. 본인에게 배정된 추천 미션만 삭제하고 수동 미션은 삭제 대상이 아니다. |
| [#35](https://github.com/YAPP-Github/28th-Web-Team-3-BE/issues/35) 기준 지출액·예상 절약액 정책 | open | `estimatedSavingsWon`의 의미와 향후 계약 | 현재 필드는 예상치이며 완료 후에도 실측 절약액이 아니다. 다만 `expenseEstimate`, `savingsDescription` 등 제안 필드는 이슈 체크리스트상 미구현이므로 현행 API 문서에 추가하지 않았다. |

## 문서 반영

- `category`의 값별 한국어 명칭을 사용자 확인으로 확정했다.
- `estimatedSavingsWon`을 “미션 달성 시 예상 절약액”으로 명확히 하고 실측값이 아님을 기록했다.
- `INCOMPLETE`를 “주간 종료까지 완료되지 않아 미완료 확정”으로 구체화했다.
- 사용자 확인으로 `TIMES_PER_WEEK`의 의미를 주 당 횟수로 확정했다.

## 현재 계약에 추가하지 않은 항목

이슈 #35의 다음 항목은 제품 정책 제안 또는 미구현 작업이므로, Swagger/DTO/구현에 반영될 때까지 필드 사전에 넣지 않는다.

- `expenseEstimate`
- `referenceExpenseWon`
- `alternativeExpenseWon`
- `estimatedSavingsPerUnitWon`
- `estimateBasis`
- `savingsDescription`
- `savingsCopyVersion`
