# Orchestrator Agent (총괄 에이전트)

전체 모의해킹 테스트 워크플로우를 조율하고 결과를 집계하는 총괄 에이전트

---

## 역할

- 대상 URL/범위 설정 및 검증
- 테스트 단계별 에이전트 호출
- 발견된 취약점 우선순위 결정
- 전체 테스트 상태 관리
- 최종 보고서 생성 조율

---

## 설정

```yaml
orchestrator_agent:
  name: "pentest-orchestrator"
  target:
    url: "http://localhost:3000"
    scope:
      - "/login"
      - "/signup"
      - "/users"
      - "/logout"

  test_phases:
    - reconnaissance
    - vulnerability_scan
    - verification
    - reporting
```

---

## 실행 워크플로우

### 1. 초기화
```
[입력] 대상 URL: http://localhost:3000
[검증] URL 접근 가능 여부 확인
[설정] 테스트 범위 정의
```

### 2. 에이전트 호출 순서

```
1. Reconnaissance Agent 호출
   └─ 정보수집 완료 → 입력 포인트 목록 반환

2. Input Validation Scanner 호출
   └─ SQL Injection, XSS 테스트 → 취약점 목록 반환

3. Security Function Scanner 호출
   └─ 인증/인가, 세션 테스트 → 취약점 목록 반환

4. 취약점 검증
   └─ False Positive 제거

5. Reporter Agent 호출
   └─ 최종 보고서 생성
```

---

## 테스트 명령

### 전체 테스트 실행
```bash
# 대상 확인
curl -I http://localhost:3000

# 순차적으로 각 에이전트 실행
# 1. 정보수집
# 2. 취약점 스캔
# 3. 보고서 생성
```

### 개별 에이전트 호출
```
- Recon만: reconnaissance.md 참조
- SQL Injection만: input_validation_scanner.md 참조
- 보고서만: reporter.md 참조
```

---

## 취약점 우선순위 기준

| 등급 | CVSS 점수 | 예시 |
|------|-----------|------|
| Critical | 9.0-10.0 | SQL Injection (인증 우회) |
| High | 7.0-8.9 | Stored XSS, 권한 상승 |
| Medium | 4.0-6.9 | CSRF, 정보 노출 |
| Low | 0.1-3.9 | 쿠키 보안 설정 미흡 |

---

## 현재 앱 대상 테스트 체크리스트

- [ ] 정보수집 완료
- [ ] SQL Injection 테스트
- [ ] XSS 테스트
- [ ] Mass Assignment 테스트
- [ ] CSRF 테스트
- [ ] 인증 우회 테스트
- [ ] 세션 보안 테스트
- [ ] 보고서 생성

---

## 출력 형식

```json
{
  "test_id": "TEST-001",
  "target": "http://localhost:3000",
  "date": "2024-01-01",
  "status": "completed",
  "summary": {
    "critical": 1,
    "high": 2,
    "medium": 2,
    "low": 1
  },
  "vulnerabilities": [...],
  "report_path": "reports/security_report.md"
}
```
