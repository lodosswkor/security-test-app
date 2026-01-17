# CVSS v3.1 점수 산정 가이드

---

## 1. CVSS 개요

CVSS (Common Vulnerability Scoring System)는 취약점의 심각도를 평가하는 표준 체계입니다.

### 점수 범위

| 등급 | 점수 | 조치 우선순위 |
|------|------|---------------|
| Critical | 9.0 - 10.0 | 즉시 (24시간 내) |
| High | 7.0 - 8.9 | 긴급 (1주 내) |
| Medium | 4.0 - 6.9 | 일반 (1개월 내) |
| Low | 0.1 - 3.9 | 낮음 (분기 내) |
| None | 0.0 | 정보성 |

---

## 2. Base Score Metrics (기본 점수)

### 2.1 Attack Vector (AV) - 공격 벡터

| 값 | 설명 | 점수 |
|----|------|------|
| Network (N) | 네트워크를 통한 원격 공격 | 0.85 |
| Adjacent (A) | 인접 네트워크에서 공격 | 0.62 |
| Local (L) | 로컬 접근 필요 | 0.55 |
| Physical (P) | 물리적 접근 필요 | 0.20 |

### 2.2 Attack Complexity (AC) - 공격 복잡도

| 값 | 설명 | 점수 |
|----|------|------|
| Low (L) | 특별한 조건 불필요 | 0.77 |
| High (H) | 특정 조건 필요 | 0.44 |

### 2.3 Privileges Required (PR) - 필요 권한

| 값 | 설명 | 점수 (U) | 점수 (C) |
|----|------|----------|----------|
| None (N) | 권한 불필요 | 0.85 | 0.85 |
| Low (L) | 일반 사용자 권한 | 0.62 | 0.68 |
| High (H) | 관리자 권한 | 0.27 | 0.50 |

### 2.4 User Interaction (UI) - 사용자 상호작용

| 값 | 설명 | 점수 |
|----|------|------|
| None (N) | 상호작용 불필요 | 0.85 |
| Required (R) | 사용자 행동 필요 | 0.62 |

### 2.5 Scope (S) - 범위

| 값 | 설명 |
|----|------|
| Unchanged (U) | 영향 범위가 취약 컴포넌트 내로 제한 |
| Changed (C) | 다른 컴포넌트에도 영향 |

### 2.6 Impact Metrics (영향도)

| 지표 | 값 | 설명 | 점수 |
|------|-----|------|------|
| Confidentiality (C) | None | 영향 없음 | 0.00 |
| | Low | 일부 정보 노출 | 0.22 |
| | High | 전체 정보 노출 | 0.56 |
| Integrity (I) | None | 영향 없음 | 0.00 |
| | Low | 일부 데이터 수정 | 0.22 |
| | High | 전체 데이터 수정 | 0.56 |
| Availability (A) | None | 영향 없음 | 0.00 |
| | Low | 일부 가용성 저하 | 0.22 |
| | High | 전체 서비스 중단 | 0.56 |

---

## 3. 현재 앱 취약점 CVSS 산정

### VULN-001: SQL Injection (인증 우회)

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
점수: 9.8 (Critical)
```

| 지표 | 값 | 근거 |
|------|-----|------|
| AV | Network | 웹을 통한 원격 공격 |
| AC | Low | 단순 페이로드로 공격 가능 |
| PR | None | 인증 불필요 |
| UI | None | 사용자 상호작용 불필요 |
| S | Unchanged | DB 접근 범위 내 |
| C | High | 전체 사용자 정보 접근 가능 |
| I | High | 데이터 수정/삭제 가능 |
| A | High | 서비스 중단 가능 |

---

### VULN-002: Stored XSS

```
CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:L/I:L/A:N
점수: 5.4 (Medium)
```

| 지표 | 값 | 근거 |
|------|-----|------|
| AV | Network | 웹을 통한 공격 |
| AC | Low | 단순 스크립트 삽입 |
| PR | Low | 회원가입 필요 |
| UI | Required | 피해자가 페이지 방문 필요 |
| S | Changed | 다른 사용자 브라우저에 영향 |
| C | Low | 쿠키 등 일부 정보 탈취 |
| I | Low | DOM 조작 가능 |
| A | None | 가용성 영향 없음 |

---

### VULN-003: CSRF

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:N/I:L/A:N
점수: 4.3 (Medium)
```

| 지표 | 값 | 근거 |
|------|-----|------|
| AV | Network | 원격 공격 |
| AC | Low | 단순 HTML 폼으로 공격 |
| PR | None | 공격자 권한 불필요 |
| UI | Required | 피해자가 링크 클릭 필요 |
| S | Unchanged | 피해자 세션 범위 |
| C | None | 정보 노출 없음 |
| I | Low | 의도치 않은 행동 수행 |
| A | None | 가용성 영향 없음 |

---

### VULN-004: Mass Assignment

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:N
점수: 7.5 (High)
```

| 지표 | 값 | 근거 |
|------|-----|------|
| AV | Network | 웹을 통한 공격 |
| AC | Low | 파라미터 추가만으로 공격 |
| PR | None | 인증 불필요 |
| UI | None | 상호작용 불필요 |
| S | Unchanged | 앱 범위 내 |
| C | None | 직접적 정보 노출 없음 |
| I | High | 관리자 권한 획득 가능 |
| A | None | 가용성 영향 없음 |

---

### VULN-005: Plaintext Password

```
CVSS:3.1/AV:L/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:N
점수: 6.0 (Medium)
```

| 지표 | 값 | 근거 |
|------|-----|------|
| AV | Local | DB 직접 접근 필요 |
| AC | Low | 단순 조회로 확인 |
| PR | High | DB 접근 권한 필요 |
| UI | None | 상호작용 불필요 |
| S | Unchanged | DB 범위 내 |
| C | High | 모든 비밀번호 노출 |
| I | High | 계정 탈취 가능 |
| A | None | 가용성 영향 없음 |

---

### VULN-006: Authentication Bypass (Cookie)

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:L/A:N
점수: 8.2 (High)
```

| 지표 | 값 | 근거 |
|------|-----|------|
| AV | Network | 원격 공격 |
| AC | Low | 쿠키 값만 변경 |
| PR | None | 인증 불필요 |
| UI | None | 상호작용 불필요 |
| S | Unchanged | 앱 범위 내 |
| C | High | 다른 사용자 정보 접근 |
| I | Low | 세션 조작 |
| A | None | 가용성 영향 없음 |

---

## 4. CVSS 계산기

온라인 계산기: https://www.first.org/cvss/calculator/3.1

### 벡터 문자열 예시

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H  → 9.8
CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:L/I:L/A:N  → 5.4
CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:N/I:L/A:N  → 4.3
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:N  → 7.5
CVSS:3.1/AV:L/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:N  → 6.0
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:L/A:N  → 8.2
```
