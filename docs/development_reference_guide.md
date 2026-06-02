# MG-0023 제작 참고 가이드

**최종 업데이트:** 2026-05-23
**프로젝트:** Colony Frontier

---

## 📋 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [슈퍼셀 스타일 디자인 철학](#슈퍼셀-스타일-디자인-철학)
3. [아키텍처 구조](#아키텍처-구조)
4. [개발 워크플로우](#개발-워크플로우)
5. [핵심 시스템 설명](#핵심-시스템-설명)
6. [제작 체크리스트](#제작-체크리스트)

---

## 프로젝트 개요

### 목표

MG-0023은 슈퍼셀의 게임 디자인 철학을 바탕으로 한 콜로니 건설/배틀 게임입니다.

**핵심 가치:**
- 즉시 플레이 가능 (Instant Action)
- 짧고 강렬한 세션 (3-5분)
- "한 번 더"의 중독성 (One More Turn)
- 소셜 경쟁 (Social Competition)

### 기술 스택

- **엔진:** Flutter 3.x
- **상태 관리:** Provider
- **테스트:** Flutter Test
- **언어:** Dart 3.x

---

## 슈퍼셀 스타일 디자인 철학

### 핵심 원칙 5가지

#### 1. Focused on the Game (게임에 집중)

```
한 번에 한 가지에 완벽하게 집중
- 복잡한 시스템 지양
- 2-3개의 핵심 메커닉
- 플레이어가 항상 "무엇을 해야 할지" 명확히 인지
```

#### 2. Smart & Simple (간단하지만 똑똑하게)

```
누구나 30초 안에 배울 수 있지만, 완벽히 마스터하는 데는 평생이 걸림
- 첫 5초 안에 플레이 시작
- 별도 튜토리얼 없음
- 깊이 있는 전략적 선택
```

#### 3. Social First (소셜 우선)

```
게임은 혼자 하는 것이 아니라 함께하는 것
- 클랜/길드 시스템
- 친구와의 배틀
- 리더보드 경쟁
```

#### 4. Live the Game (게임을 살다)

```
개발자들이 자신의 게임을 즐기며, 커뮤니티와 소통
- 모든 개발자는 매일 1시간 이상 게임 플레이
- 커뮤니티 피드백 즉각 반영
```

#### 5. Forever Beta (영원한 베타)

```
게임은 완성되는 것이 아니라 계속 진화
- 주간 밸런스 패치
- 월간 신규 콘텐츠
- 지속적인 A/B 테스트
```

---

## 아키텍처 구조

### 디렉토리 구조

```
lib/
├── main.dart                          # 앱 진입점
├── core/
│   ├── game_state.dart               # 게임 상태 관리
│   ├── synergy_system.dart           # 건물 시너지 시스템
│   ├── weather_system.dart           # 날씨/재해 시스템
│   └── meaningful_choice_system.dart # 의미 있는 선택 시스템
├── models/
│   └── building_model.dart           # 건물 데이터 모델
├── screens/
│   └── colony_screen.dart            # 콜로니 메인 화면
├── ui/
│   ├── intro_showcase.dart           # 화려한 인트로
│   ├── animated_main_menu.dart       # 애니메이션 메인 메뉴
│   ├── crisis_overlay.dart           # 위기 상태 시각화
│   ├── construction_completion_effect.dart  # 건설 완료 효과
│   ├── level_up_showcase.dart        # 레벨업 쇼케이스
│   └── colony_visualization.dart     # 콜로니스트 시각화
├── supercell_style/
│   └── session_battle.dart           # 슈퍼셀 스타일 세션 배틀
└── game/
    ├── level_design_config.dart      # 레벨 디자인 설정
    ├── wave_spawn_table.dart         # 웨이브 스폰 테이블
    └── tutorial_config.dart          # 튜토리얼 설정
```

### 핵심 클래스 다이어그램

```
GameState (ChangeNotifier)
├── Resources (iron, water, oxygen, energy, food, research)
├── Buildings (List<Building>)
├── Unlocked Techs (List<String>)
└── Crisis State (bool)

SessionBattle (StatefulWidget)
├── Elixir System (0-10, +1 per 2.8s)
├── Card Hand (4 cards)
├── Battle Timer (180 seconds)
└── Health System (Player/Enemy)
```

---

## 개발 워크플로우

### 1. 새로운 기능 추가 시

```
1. 슈퍼셀 철학 체크리스트 확인
   ↓
2. 해당 디렉토리에 파일 생성
   ↓
3. 단위 테스트 작성
   ↓
4. 기능 구현
   ↓
5. 통합 테스트
   ↓
6. UI/UX 피드백 반영
```

### 2. 밸런스 조정 시

```
1. 현재 메타 분석 (어떤 카드/전략이 인기?)
   ↓
2. 문제점 식별 (너무 강함/너무 약함?)
   ↓
3. A/B 테스트 설계
   ↓
4. 소규모 테스트 (내부 테스터)
   ↓
5. 데이터 수집 및 분석
   ↓
6. 전체 적용 또는 롤백
```

---

## 핵심 시스템 설명

### 세션 배틀 시스템

**파일:** `lib/supercell_style/session_battle.dart`

**핵심 메커닉:**
1. **엘릭서 시스템**: 2.8초마다 1씩 회복 (최대 10)
2. **카드 플레이**: 엘릭 소비하여 즉시 효과
3. **타이머**: 3분 세션, 종료 시 체력 비교로 승패 결정
4. **"한 번 더" 루프**: 게임 종료 후 즉시 재시작 가능

**카드 밸런스:**
```
카드명     | 엘릭서 | 데미지 | 역할
-----------|--------|--------|------------------
자원수집   | 1      | 5      | 초반 엘릭서 확보
수리드론   | 2      | 10     | 방어/유지
전술스캔   | 2      | 8      | 정보 수집
건설부대   | 3      | 15     | 중간 데미지
특수부대   | 4      | 20     | 강력한 공격
방어진     | 4      | 10     | 방어 특화
에너지파   | 5      | 30     | 고위력 공격
공성포     | 6      | 40     | 최종 병기
```

### 시너지 시스템

**파일:** `lib/core/synergy_system.dart`

**보너스 종류:**
- 인접 보너스: 같은 타입 건물이 인접 시 +15%
- 클러스터 보너스: 3개 이상 인접 시 +25%
- 특수 시너지:
  - Energy + Water → Hydro Power (+20%)
  - Research + Research → Knowledge Sharing (+30%)
  - Storage + Producer → Efficient Storage (+10%)

### 날씨 시스템

**파일:** `lib/core/weather_system.dart`

**날씨 타입:**
- Clear: 기본 상태
- Solar Flare: 에너지 생산 증가
- Dust Storm: 모든 생산 감소
- Meteor Shower: 철 추가 획득 가능
- Cosmic Storm: 모든 자원 감소

---

## 제작 체크리스트

### 매주 점검 항목

- [ ] 이번 주에 새로운 기능을 추가했는가?
- [ ] 밸런스 이슈가 있는가?
- [ ] 커뮤니티 피드백을 확인했는가?
- [ ] 개발자들이 게임을 플레이했는가?

### 기능 출시 전 점검

- [ ] 첫 5초 안에 플레이어가 무엇을 해야 할지 알 수 있는가?
- [ ] 첫 30초 안에 첫 승리/보상을 경험하는가?
- [ ] 세션 시간이 3-5분 내에 끝나는가?
- [ ] 패배 후에도 다시 하고 싶은가?
- [ ] 친구에게 자랑하고 싶은가?

### 코드 품질

- [ ] 모든 새로운 코드에 테스트가 있는가?
- [ ] Lint 경고가 없는가?
- [ ] 애니메이션이 0.3초 이내인가?
- [ ] 불필요한 rebuild가 없는가?

---

## 관련 문서

- `docs/improvement_completion_report.md` - 전체 개선 보고서
- `docs/supercell_design_philosophy.md` - 슈퍼셀 디자인 철학 상세
- `test/design_criteria_e2e_test.dart` - 게임 디자인 기준 테스트

---

**기억하세요: 슈퍼셀의 성공은 "간단하지만 깊이 있는" 게임 디자인에 있습니다.**
