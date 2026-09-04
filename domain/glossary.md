# Glossary

| 용어 | 정의 | 사용 금지 표현 | 관련 정책 |
| --- | --- | --- | --- |
| 온보딩 프로필 | 게스트 사용자가 최초 이용 중 부분 저장하는 생년월일·거주지역·월급·월 저축액·순자산·목표 기간의 묶음 | 회원 정보, 설문 결과 | [POLICY-ONBOARDING-001](policies/onboarding-001-profile.md) |
| 월 저축 목표 | 온보딩 마지막 단계에서 현재 월 저축액 이상으로 선택해 목표 금액 계산에 사용하는 매달 저축 금액 | 목표안, 플랜 | [POLICY-ONBOARDING-002](policies/onboarding-002-goal.md) |
| 온보딩 완료 | 월 저축 목표를 확정해 온보딩 목표와 서비스 목표가 생성된 상태 | 설문 완료, 프로필 저장 완료 | [POLICY-ONBOARDING-002](policies/onboarding-002-goal.md) |
| 내 정보 수정 | 온보딩 완료 후 생년월일·월급·월 저축액·순자산·목표 기간을 한 번에 갱신하고 확정된 목표를 동기화하는 과정 | 온보딩 재진입, 프로필 부분 저장 | [POLICY-ONBOARDING-001](policies/onboarding-001-profile.md), [POLICY-ONBOARDING-002](policies/onboarding-002-goal.md) |
| 미션 입력 온보딩 | AI 미션 하나를 생성하기 위해 카테고리·항목·주간 빈도·주간 금액을 한 화면에서 입력하는 과정 | 미션 설문 | [POLICY-MISSION-001](policies/mission-001-survey.md) |
| 미션 항목 | 식사·생활·취미 카테고리 안에서 사용자가 줄이려는 구체적 소비 대상 | 설문 종류 | [POLICY-MISSION-001](policies/mission-001-survey.md) |
| AI 미션 생성 작업 | 항목 하나의 입력과 프로필을 바탕으로 검색·AI 생성·서버 계산을 수행하는 비동기 작업 단위 | 설문 생성 | [POLICY-MISSION-002](policies/mission-002-generation.md) |
| 미션 후보 | 사용자가 선택하기 전에 AI가 제안하고 서버가 횟수·절약액을 결합한 대안 | 강도 단계, 우선순위 미션 | [POLICY-MISSION-002](policies/mission-002-generation.md) |
| 동기 미션 후보 조회 | 선택 항목의 DB 템플릿 기반 후보 3개를 저장·polling 없이 즉시 받는 API 호출 | 동기 미션 저장, 미션 확정 | [동기 미션 후보 API 명세](api-field-mappings/mission-generation.md) |
| AI 미션 | 사용자가 미션 후보를 확정해 매주 반복 수행하는 미션 | 추천 미션 | [POLICY-MISSION-002](policies/mission-002-generation.md), [POLICY-MISSION-003](policies/mission-003-lifecycle.md) |
| 직접 추가 미션 | 사용자가 카테고리와 최대 30자 문구를 직접 입력한 미션 | 수동 미션 | [POLICY-MISSION-003](policies/mission-003-lifecycle.md) |
| 주간 완료 | 미션 정의와 분리해 미션 ID와 월요일 시작일별로 한 번 저장하는 완료 체크 | 종료 상태 | [POLICY-MISSION-003](policies/mission-003-lifecycle.md) |
| 절약 예상액 | 평소 1회 단가를 100원 단위로 내리고 목표 횟수를 곱한 단순 추정 금액 | AI 추정 금액 | [POLICY-MISSION-002](policies/mission-002-generation.md) |
| 정책 혜택 | 게스트의 프로필 조건에 맞춰 노출하는 청년정책 콘텐츠로, 신청 링크가 있을 때만 외부 신청 페이지로 연결한다 | 지원 정책, 정부 혜택 | [POLICY-BENEFIT-001](policies/benefit-001-discovery-and-bookmark.md) |
| 절약 팁 | 식비·생활·취미 소비를 줄이는 방법을 제공하는 콘텐츠로, 원문 링크가 있을 때만 외부 원문으로 연결한다 | 꿀팁, 혜택 카드 | [POLICY-BENEFIT-001](policies/benefit-001-discovery-and-bookmark.md) |
| 혜택 저장 | 게스트가 정책 혜택 또는 절약 팁을 나중에 다시 볼 수 있도록 콘텐츠 유형과 ID로 보관하는 행위 | 찜, 좋아요 | [POLICY-BENEFIT-001](policies/benefit-001-discovery-and-bookmark.md) |
| 저장됨 | 현재 게스트가 저장한 정책 혜택과 절약 팁을 콘텐츠 유형별로 확인하는 화면 | 저장 필터, 북마크함 | [POLICY-BENEFIT-001](policies/benefit-001-discovery-and-bookmark.md) |
| 게스트 탈퇴 | 인증된 게스트의 계정과 그 계정에 귀속된 서버 데이터를 영구 삭제하는 절차 | 앱 삭제, 로그아웃 | [POLICY-MYPAGE-001](policies/mypage-001-account-support.md) |
| 문의 대체 채널 | 카카오톡 오픈채팅 주소를 사용할 수 없을 때에도 문의가 가능하도록 제공하는 개인정보 문의용 이메일 경로 | 보조 문의 | [POLICY-MYPAGE-001](policies/mypage-001-account-support.md) |

같은 개념에 여러 이름을 사용하지 않는다. 새 용어는 한 문장으로 정의하고 관련 정책 ID를 연결한다.
