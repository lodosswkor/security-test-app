# Reporter Agent (리포터 에이전트)

취약점 결과를 종합하고 보고서를 생성하는 에이전트

---

## 역할

- 발견된 취약점 종합
- 위험도 평가 (CVSS 점수)
- 보고서 생성
- 권장 조치사항 작성

---

## 설정

```yaml
reporter_agent:
  name: "vulnerability-reporter"
  output_formats:
    - markdown
    - json
  report_sections:
    - executive_summary
    - vulnerability_list
    - risk_assessment
    - technical_details
    - remediation_plan
```

---

## CVSS v3.1 점수 기준

| 등급 | 점수 범위 | 설명 |
|------|-----------|------|
| Critical | 9.0 - 10.0 | 즉시 조치 필요 |
| High | 7.0 - 8.9 | 빠른 조치 필요 |
| Medium | 4.0 - 6.9 | 계획된 조치 필요 |
| Low | 0.1 - 3.9 | 리스크 수용 가능 |
| Info | 0.0 | 정보성 항목 |

---

## 현재 앱 취약점 CVSS 산정

### VULN-001: SQL Injection
```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
점수: 9.8 (Critical)

- Attack Vector (AV): Network
- Attack Complexity (AC): Low
- Privileges Required (PR): None
- User Interaction (UI): None
- Scope (S): Unchanged
- Confidentiality (C): High
- Integrity (I): High
- Availability (A): High
```

### VULN-002: Stored XSS
```
CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:L/I:L/A:N
점수: 5.4 (Medium)

- Attack Vector (AV): Network
- Attack Complexity (AC): Low
- Privileges Required (PR): Low (회원가입 필요)
- User Interaction (UI): Required (피해자가 페이지 방문)
- Scope (S): Changed
- Confidentiality (C): Low
- Integrity (I): Low
- Availability (A): None
```

### VULN-003: CSRF
```
CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:N/I:L/A:N
점수: 4.3 (Medium)
```

### VULN-004: Mass Assignment
```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:N
점수: 7.5 (High)
```

### VULN-005: Plaintext Password
```
CVSS:3.1/AV:L/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:N
점수: 6.0 (Medium)
- 로컬 접근(DB) 필요하므로 AV:L
```

### VULN-006: Authentication Bypass (Cookie)
```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:L/A:N
점수: 8.2 (High)
```

---

## 보고서 생성 명령

### Markdown 보고서 생성
```bash
# templates/report_template.md 참조하여 생성
```

### JSON 보고서 생성
```json
{
  "report": {
    "title": "Security Test App 취약점 진단 보고서",
    "date": "2024-01-01",
    "target": "http://localhost:3000",
    "tester": "Pentest Agent",
    "summary": {
      "total_vulnerabilities": 6,
      "critical": 1,
      "high": 2,
      "medium": 3,
      "low": 0
    },
    "vulnerabilities": [...]
  }
}
```

---

## 보고서 섹션

### 1. Executive Summary (경영진 요약)
```markdown
## 요약

대상 시스템에서 총 6건의 보안 취약점이 발견되었습니다.

| 등급 | 건수 |
|------|------|
| Critical | 1 |
| High | 2 |
| Medium | 3 |

**즉시 조치가 필요한 항목:**
- SQL Injection을 통한 인증 우회 (Critical)
```

### 2. Vulnerability List (취약점 목록)
```markdown
## 취약점 목록

| ID | 취약점 | 등급 | CVSS | 위치 |
|----|--------|------|------|------|
| VULN-001 | SQL Injection | Critical | 9.8 | POST /login |
| VULN-002 | Stored XSS | Medium | 5.4 | POST /users |
| VULN-003 | CSRF | Medium | 4.3 | 전체 폼 |
| VULN-004 | Mass Assignment | High | 7.5 | POST /users |
| VULN-005 | Plaintext Password | Medium | 6.0 | Database |
| VULN-006 | Auth Bypass | High | 8.2 | Cookie |
```

### 3. Technical Details (기술 상세)
```markdown
## 기술 상세

### VULN-001: SQL Injection

**위치:** POST /login (email 파라미터)

**재현 방법:**
curl -X POST http://localhost:3000/login \
  -d "email=' OR '1'='1' --&password=test"

**영향:**
- 인증 우회
- 데이터베이스 정보 유출 가능
- 데이터 조작/삭제 가능

**증거:**
[스크린샷 또는 응답 데이터]
```

### 4. Remediation Plan (권장 조치)
```markdown
## 권장 조치사항

### 우선순위 1 (즉시)
1. **SQL Injection 수정**
   - PreparedStatement 사용
   - 예: `User.where(email: params[:email])`

### 우선순위 2 (1주 내)
2. **인증 메커니즘 강화**
   - remember_token 제거 또는 암호화
   - 서버 측 세션 검증 강화

3. **비밀번호 암호화**
   - bcrypt 적용: `has_secure_password`

### 우선순위 3 (1개월 내)
4. **XSS 방어**
   - raw 헬퍼 제거
   - CSP 헤더 설정

5. **CSRF 보호 활성화**
   - `protect_from_forgery with: :exception`

6. **Mass Assignment 방어**
   - Strong Parameters 적용
```

---

## 출력 파일

```
reports/
├── security_report.md          # 전체 보고서
├── security_report.json        # JSON 형식
├── executive_summary.md        # 경영진 요약
└── evidence/                   # 증거 자료
    ├── vuln-001-sqli.png
    ├── vuln-002-xss.png
    └── ...
```
