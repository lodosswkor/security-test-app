# 보안 취약점 진단 보고서

---

## 1. 개요

| 항목 | 내용 |
|------|------|
| **대상 시스템** | {{TARGET_URL}} |
| **진단 기간** | {{START_DATE}} ~ {{END_DATE}} |
| **진단자** | {{TESTER_NAME}} |
| **보고서 버전** | {{VERSION}} |
| **작성일** | {{REPORT_DATE}} |

---

## 2. 경영진 요약 (Executive Summary)

### 2.1 진단 결과 요약

대상 시스템에 대한 모의해킹 진단 결과, 총 **{{TOTAL_VULNS}}건**의 보안 취약점이 발견되었습니다.

| 위험등급 | 발견 건수 | 비율 |
|----------|-----------|------|
| Critical | {{CRITICAL_COUNT}} | {{CRITICAL_PCT}}% |
| High | {{HIGH_COUNT}} | {{HIGH_PCT}}% |
| Medium | {{MEDIUM_COUNT}} | {{MEDIUM_PCT}}% |
| Low | {{LOW_COUNT}} | {{LOW_PCT}}% |

### 2.2 주요 발견사항

{{MAJOR_FINDINGS}}

### 2.3 권고사항

{{RECOMMENDATIONS_SUMMARY}}

---

## 3. 진단 범위

### 3.1 대상 시스템

- URL: {{TARGET_URL}}
- 기술스택: {{TECH_STACK}}
- 테스트 환경: {{TEST_ENVIRONMENT}}

### 3.2 진단 항목

| 분류 | 항목 수 | 진단 완료 |
|------|---------|-----------|
| 입력값 검증 | 17 | {{INPUT_VALIDATION_TESTED}} |
| 보안기능 | 16 | {{SECURITY_FUNCTION_TESTED}} |
| 에러처리 | 3 | {{ERROR_HANDLING_TESTED}} |
| 세션관리 | 4 | {{SESSION_MGMT_TESTED}} |

---

## 4. 취약점 상세

{{VULNERABILITY_DETAILS}}

---

## 5. 취약점 목록

| ID | 취약점명 | 위험등급 | CVSS | 위치 | 상태 |
|----|----------|----------|------|------|------|
{{VULNERABILITY_TABLE}}

---

## 6. 권장 조치사항

### 6.1 즉시 조치 (Critical/High)

{{IMMEDIATE_ACTIONS}}

### 6.2 단기 조치 (1주 내)

{{SHORT_TERM_ACTIONS}}

### 6.3 중기 조치 (1개월 내)

{{MID_TERM_ACTIONS}}

---

## 7. 부록

### 7.1 진단 도구

- curl
- 브라우저 개발자 도구
- 수동 테스트

### 7.2 참고 기준

- 행정안전부 소프트웨어 개발보안 가이드 (2021)
- OWASP Top 10 (2021)
- CVSS v3.1

### 7.3 면책 조항

본 보고서는 진단 시점의 대상 시스템 상태를 기반으로 작성되었습니다.
진단 이후 시스템 변경으로 인해 추가적인 취약점이 발생할 수 있습니다.

---

**보고서 끝**
