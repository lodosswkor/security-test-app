# 화이트해커 블랙박스 테스트 Agent 구조 설계

행정안전부 소프트웨어 개발보안 가이드(2021)를 기반으로 한 **외부 모의해킹 전문 Claude Code Agent** 설계안

---

## 📋 개요

### 목적
- 외부 블랙박스 관점에서 웹 애플리케이션 취약점 진단
- DB/인프라 내부 접근 없이 순수 **모의해킹**으로 취약점 검출
- 결과 및 권장 처리 방법 문서화 자동화

### 적용 기준
- **설계단계 보안설계 기준**: 20개 항목
- **구현단계 보안약점 제거 기준**: 49개 항목 (블랙박스로 탐지 가능한 항목 중심)

---

## 🤖 Agent 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    Main Orchestrator Agent                   │
│              (전체 테스트 계획 및 조율, 리포트 생성)            │
└─────────────────────────┬───────────────────────────────────┘
                          │
    ┌─────────────────────┼─────────────────────┐
    │                     │                     │
    ▼                     ▼                     ▼
┌─────────┐         ┌─────────┐          ┌─────────┐
│ Recon   │         │ Scanner │          │ Reporter│
│ Agent   │         │ Agent   │          │ Agent   │
└────┬────┘         └────┬────┘          └────┬────┘
     │                   │                    │
     ▼                   ▼                    ▼
┌─────────┐    ┌─────────────────┐    ┌─────────────┐
│정보수집 │    │취약점 스캔/검증  │    │ 보고서 생성  │
│Skills   │    │    Skills       │    │   Skills    │
└─────────┘    └─────────────────┘    └─────────────┘
```

---

## 🔧 필요 Agent 정의

### 1. Main Orchestrator Agent (총괄 에이전트)

**역할**: 전체 테스트 워크플로우 조율, 에이전트 간 통신, 최종 결과 집계

**기능**:
- 대상 URL/범위 설정 및 검증
- 테스트 단계별 에이전트 호출
- 발견된 취약점 우선순위 결정 (Critical/High/Medium/Low)
- 전체 테스트 상태 관리

```yaml
orchestrator_agent:
  name: "pentest-orchestrator"
  responsibilities:
    - test_scope_definition
    - agent_coordination
    - vulnerability_prioritization
    - test_status_management
```

---

### 2. Reconnaissance Agent (정보수집 에이전트)

**역할**: 대상 시스템 정보 수집 (Passive/Active)

**수집 항목**:
- 웹 서버 정보 (헤더 분석)
- 기술 스택 식별
- 디렉토리/파일 구조 매핑
- 입력 포인트 식별 (폼, 파라미터, 쿠키)
- API 엔드포인트 수집
- 에러 페이지 정보

```yaml
recon_agent:
  name: "reconnaissance-agent"
  skills:
    - tech_stack_fingerprint
    - directory_enumeration
    - input_point_mapping
    - api_endpoint_discovery
    - error_page_analysis
```

---

### 3. Scanner Agents (취약점 스캔 에이전트 그룹)

행정안전부 가이드의 7대 분류에 맞춰 전문화된 스캐너 에이전트 구성

#### 3.1 Input Validation Scanner Agent
**대상**: 입력데이터 검증 및 표현 취약점 (17개 항목)

| 번호 | 취약점 | 블랙박스 테스트 가능 여부 |
|------|--------|------------------------|
| 1 | SQL 삽입 | ✅ |
| 2 | 코드 삽입 | ✅ |
| 3 | 경로 조작 및 자원 삽입 | ✅ |
| 4 | 크로스사이트 스크립트(XSS) | ✅ |
| 5 | 운영체제 명령어 삽입 | ✅ |
| 6 | 위험한 형식 파일 업로드 | ✅ |
| 7 | 신뢰되지 않는 URL 자동접속 | ✅ |
| 8 | 부적절한 XML 외부 개체 참조 | ✅ |
| 9 | XML 삽입 (XPath/XQuery) | ✅ |
| 10 | LDAP 삽입 | ✅ |
| 11 | 크로스사이트 요청 위조(CSRF) | ✅ |
| 12 | 서버사이드 요청 위조(SSRF) | ✅ |
| 13 | HTTP 응답분할 | ✅ |
| 14 | 정수형 오버플로우 | ⚠️ 제한적 |
| 15 | 보안기능 결정에 사용되는 부적절한 입력값 | ✅ |
| 16 | 메모리 버퍼 오버플로우 | ⚠️ 제한적 |
| 17 | 포맷 스트링 삽입 | ⚠️ 제한적 |

```yaml
input_validation_scanner:
  name: "input-validation-scanner"
  skills:
    - sql_injection_test
    - xss_test
    - command_injection_test
    - path_traversal_test
    - file_upload_test
    - xxe_test
    - csrf_test
    - ssrf_test
    - http_response_splitting_test
    - open_redirect_test
```

#### 3.2 Security Function Scanner Agent
**대상**: 보안기능 취약점 (16개 항목)

| 번호 | 취약점 | 블랙박스 테스트 가능 여부 |
|------|--------|------------------------|
| 1 | 적절한 인증 없는 중요기능 허용 | ✅ |
| 2 | 부적절한 인가 | ✅ |
| 3 | 중요 자원에 대한 잘못된 권한 설정 | ✅ |
| 4 | 취약한 암호화 알고리즘 사용 | ✅ (HTTPS 분석) |
| 5 | 암호화되지 않은 중요정보 | ✅ |
| 6 | 하드코드된 중요정보 | ⚠️ 제한적 |
| 7 | 충분하지 않은 키 길이 사용 | ✅ (SSL/TLS 분석) |
| 8 | 적절하지 않은 난수값 사용 | ✅ (세션/토큰 분석) |
| 9 | 취약한 비밀번호 허용 | ✅ |
| 10 | 부적절한 전자서명 확인 | ⚠️ 제한적 |
| 11 | 부적절한 인증서 유효성 검증 | ✅ |
| 12 | 쿠키를 통한 정보노출 | ✅ |
| 13 | 주석문 안에 포함된 시스템 주요정보 | ✅ (소스 분석) |
| 14 | 솔트 없이 일방향 해쉬함수 사용 | ⚠️ 제한적 |
| 15 | 무결성 검사 없는 코드 다운로드 | ✅ |
| 16 | 반복된 인증시도 제한 기능 부재 | ✅ |

```yaml
security_function_scanner:
  name: "security-function-scanner"
  skills:
    - authentication_bypass_test
    - authorization_test
    - access_control_test
    - crypto_strength_test
    - sensitive_data_exposure_test
    - session_management_test
    - password_policy_test
    - brute_force_protection_test
    - cookie_security_test
    - ssl_tls_analysis
```

#### 3.3 Error Handling Scanner Agent
**대상**: 에러처리 취약점 (3개 항목)

| 번호 | 취약점 | 블랙박스 테스트 가능 여부 |
|------|--------|------------------------|
| 1 | 오류 메시지 정보노출 | ✅ |
| 2 | 오류상황 대응 부재 | ✅ |
| 3 | 부적절한 예외 처리 | ✅ |

```yaml
error_handling_scanner:
  name: "error-handling-scanner"
  skills:
    - error_message_disclosure_test
    - stack_trace_exposure_test
    - debug_info_leak_test
```

#### 3.4 Session Management Scanner Agent
**대상**: 세션통제 취약점 + 캡슐화 취약점 중 세션 관련

| 취약점 | 블랙박스 테스트 가능 여부 |
|--------|------------------------|
| 세션 ID 예측 가능성 | ✅ |
| 세션 고정 공격 | ✅ |
| 세션 만료 부재 | ✅ |
| 잘못된 세션에 의한 데이터 정보노출 | ✅ |

```yaml
session_scanner:
  name: "session-management-scanner"
  skills:
    - session_prediction_test
    - session_fixation_test
    - session_expiration_test
    - concurrent_session_test
```

---

### 4. Reporter Agent (리포팅 에이전트)

**역할**: 취약점 결과 종합 및 보고서 생성

**출력 형식**:
- 취약점 요약 리포트
- 상세 기술 보고서
- 권장 조치사항 (행정안전부 가이드 기준)
- CVSS 점수 매핑

```yaml
reporter_agent:
  name: "vulnerability-reporter"
  skills:
    - executive_summary_generator
    - technical_report_generator
    - remediation_guide_generator
    - cvss_scoring
```

---

## 📚 필요 Skills 상세 정의

### Skill 1: SQL Injection Test
```yaml
skill_name: sql_injection_test
description: SQL 삽입 취약점 테스트
category: 입력데이터 검증 및 표현

test_vectors:
  - "' OR '1'='1"
  - "1; DROP TABLE--"
  - "' UNION SELECT NULL--"
  - "1' AND SLEEP(5)--"
  
detection_methods:
  - error_based: "SQL 에러 메시지 탐지"
  - blind_boolean: "참/거짓 응답 차이 분석"
  - blind_time: "응답 시간 차이 분석"
  - union_based: "UNION 쿼리 응답 분석"

remediation:
  reference: "SR1-1 DBMS 조회 및 결과 검증"
  actions:
    - "PreparedStatement 또는 파라미터화된 쿼리 사용"
    - "입력값 검증 및 이스케이프 처리"
    - "최소 권한 DB 계정 사용"
```

### Skill 2: XSS Test
```yaml
skill_name: xss_test
description: 크로스사이트 스크립트 취약점 테스트
category: 입력데이터 검증 및 표현

test_vectors:
  - "<script>alert('XSS')</script>"
  - "<img src=x onerror=alert('XSS')>"
  - "javascript:alert('XSS')"
  - "<svg onload=alert('XSS')>"

detection_methods:
  - reflected: "입력값이 응답에 그대로 반영되는지 확인"
  - stored: "저장된 데이터가 다른 사용자에게 실행되는지 확인"
  - dom_based: "DOM 조작을 통한 스크립트 실행 확인"

remediation:
  reference: "SR1-5 웹 서비스 요청 및 결과 검증"
  actions:
    - "HTML 인코딩/이스케이프 처리"
    - "Content-Security-Policy 헤더 설정"
    - "입력값 화이트리스트 검증"
```

### Skill 3: Authentication Bypass Test
```yaml
skill_name: authentication_bypass_test
description: 인증 우회 취약점 테스트
category: 보안기능

test_methods:
  - direct_url_access: "인증 없이 URL 직접 접근 시도"
  - parameter_manipulation: "인증 파라미터 조작"
  - cookie_manipulation: "쿠키 값 조작"
  - jwt_token_attack: "JWT 토큰 취약점 공격"

remediation:
  reference: "SR2-1 인증 대상 및 방식"
  actions:
    - "모든 중요 페이지에 서버측 인증 확인 구현"
    - "세션 기반 인증 상태 검증"
    - "안전한 토큰 검증 메커니즘 적용"
```

### Skill 4: File Upload Test
```yaml
skill_name: file_upload_test
description: 파일 업로드 취약점 테스트
category: 입력데이터 검증 및 표현

test_methods:
  - extension_bypass: "확장자 우회 (test.php.jpg, test.pHp)"
  - content_type_bypass: "Content-Type 헤더 조작"
  - magic_byte_bypass: "매직 바이트 조작"
  - null_byte: "널 바이트 삽입"

dangerous_extensions:
  - ".php, .jsp, .asp, .aspx"
  - ".exe, .sh, .bat"
  - ".htaccess"

remediation:
  reference: "SR1-10 업로드·다운로드 파일 검증"
  actions:
    - "화이트리스트 기반 확장자 검증"
    - "파일 내용(매직 바이트) 검증"
    - "업로드 디렉토리 실행 권한 제거"
    - "파일명 랜덤화"
```

### Skill 5: CSRF Test
```yaml
skill_name: csrf_test
description: 크로스사이트 요청 위조 테스트
category: 입력데이터 검증 및 표현

test_methods:
  - token_absence: "CSRF 토큰 존재 여부 확인"
  - token_validation: "토큰 검증 로직 테스트"
  - referer_check: "Referer 헤더 검증 확인"

remediation:
  reference: "SR1-6 웹 기반 중요 기능 수행 요청 유효성 검증"
  actions:
    - "CSRF 토큰 구현"
    - "SameSite 쿠키 속성 설정"
    - "중요 기능에 재인증 요구"
```

### Skill 6: Session Security Test
```yaml
skill_name: session_security_test
description: 세션 보안 테스트
category: 세션통제

test_methods:
  - session_prediction: "세션 ID 예측 가능성 분석"
  - session_fixation: "세션 고정 공격 테스트"
  - session_timeout: "세션 만료 시간 확인"
  - concurrent_sessions: "동시 세션 허용 여부"

remediation:
  reference: "SR4-1 세션통제"
  actions:
    - "로그인 시 세션 ID 재생성"
    - "안전한 세션 ID 생성 알고리즘 사용"
    - "세션 타임아웃 설정"
    - "HttpOnly, Secure 쿠키 속성 설정"
```

### Skill 7: Error Information Disclosure Test
```yaml
skill_name: error_disclosure_test
description: 에러 정보 노출 테스트
category: 에러처리

test_methods:
  - invalid_input: "비정상 입력으로 에러 유발"
  - missing_parameter: "필수 파라미터 제거"
  - sql_error_trigger: "SQL 문법 오류 유발"
  - path_not_found: "존재하지 않는 경로 접근"

check_items:
  - "스택 트레이스 노출"
  - "DB 정보 노출"
  - "서버 경로 노출"
  - "프레임워크/버전 정보 노출"

remediation:
  reference: "SR3-1 예외처리"
  actions:
    - "사용자 정의 에러 페이지 구현"
    - "상세 에러 로깅은 서버측에서만"
    - "일반적인 에러 메시지만 클라이언트에 전달"
```

### Skill 8: SSL/TLS Analysis
```yaml
skill_name: ssl_tls_analysis
description: SSL/TLS 설정 분석
category: 보안기능

check_items:
  - protocol_version: "TLS 1.2 이상 사용 여부"
  - cipher_suites: "취약한 암호 스위트 사용 여부"
  - certificate_validity: "인증서 유효성"
  - hsts_header: "HSTS 헤더 설정"

weak_protocols:
  - "SSLv2, SSLv3"
  - "TLS 1.0, TLS 1.1"

weak_ciphers:
  - "RC4, DES, 3DES"
  - "MD5 기반"
  - "NULL 암호"

remediation:
  reference: "SR2-6 암호연산"
  actions:
    - "TLS 1.2 이상만 허용"
    - "강력한 암호 스위트만 활성화"
    - "HSTS 헤더 설정"
```

### Skill 9: Brute Force Protection Test
```yaml
skill_name: brute_force_test
description: 무차별 대입 공격 방어 테스트
category: 보안기능

test_methods:
  - login_attempt_limit: "로그인 시도 횟수 제한 확인"
  - account_lockout: "계정 잠금 정책 확인"
  - captcha_presence: "CAPTCHA 존재 여부"
  - response_delay: "응답 지연 여부"

remediation:
  reference: "SR2-2 인증 수행 제한"
  actions:
    - "로그인 시도 횟수 제한 (예: 5회)"
    - "실패 시 계정 잠금 또는 지연"
    - "CAPTCHA 적용"
    - "실패 이력 로깅"
```

### Skill 10: Report Generator
```yaml
skill_name: report_generator
description: 취약점 보고서 생성
category: 리포팅

report_sections:
  - executive_summary: "경영진용 요약"
  - vulnerability_list: "발견된 취약점 목록"
  - risk_assessment: "위험도 평가"
  - technical_details: "기술적 상세 내용"
  - remediation_plan: "권장 조치 사항"
  - appendix: "부록 (증거, 스크린샷)"

output_formats:
  - markdown
  - html
  - pdf
  - docx

severity_mapping:
  critical: "CVSS 9.0-10.0"
  high: "CVSS 7.0-8.9"
  medium: "CVSS 4.0-6.9"
  low: "CVSS 0.1-3.9"
  info: "정보성 항목"
```

---

## 🗂️ Skill 파일 구조

```
/mnt/skills/user/whitehacker/
├── SKILL.md                          # 메인 스킬 가이드
├── agents/
│   ├── orchestrator.md               # 총괄 에이전트 정의
│   ├── reconnaissance.md             # 정보수집 에이전트
│   ├── input_validation_scanner.md   # 입력값 검증 스캐너
│   ├── security_function_scanner.md  # 보안기능 스캐너
│   ├── error_handling_scanner.md     # 에러처리 스캐너
│   ├── session_scanner.md            # 세션관리 스캐너
│   └── reporter.md                   # 리포터 에이전트
├── payloads/
│   ├── sql_injection.txt             # SQL 인젝션 페이로드
│   ├── xss.txt                       # XSS 페이로드
│   ├── command_injection.txt         # 명령어 삽입 페이로드
│   ├── path_traversal.txt            # 경로 조작 페이로드
│   └── file_upload_bypass.txt        # 파일 업로드 우회
├── templates/
│   ├── report_template.md            # 보고서 템플릿
│   ├── vulnerability_template.md     # 취약점 상세 템플릿
│   └── remediation_template.md       # 권장조치 템플릿
├── reference/
│   ├── kisa_security_guide.md        # 행정안전부 가이드 요약
│   ├── owasp_mapping.md              # OWASP Top 10 매핑
│   └── cvss_scoring.md               # CVSS 점수 기준
└── utils/
    ├── http_client.py                # HTTP 요청 유틸리티
    ├── response_analyzer.py          # 응답 분석기
    └── evidence_collector.py         # 증거 수집기
```

---

## 📊 테스트 워크플로우

```
1. 초기화 단계
   ├── 대상 URL 검증
   ├── 테스트 범위 설정
   └── 필요 에이전트 로드

2. 정보수집 단계 (Reconnaissance Agent)
   ├── 기술 스택 식별
   ├── 입력 포인트 매핑
   └── API 엔드포인트 수집

3. 취약점 스캔 단계 (Scanner Agents)
   ├── 입력값 검증 테스트
   ├── 보안기능 테스트
   ├── 에러처리 테스트
   └── 세션관리 테스트

4. 검증 단계
   ├── False Positive 제거
   └── 취약점 재현 확인

5. 리포팅 단계 (Reporter Agent)
   ├── 취약점 분류 및 우선순위
   ├── 보고서 생성
   └── 권장 조치사항 작성
```

---

## 🎯 우선 구현 권장 순서

### Phase 1: 핵심 취약점 스캐너
1. SQL Injection Test Skill
2. XSS Test Skill  
3. Authentication Test Skill
4. File Upload Test Skill

### Phase 2: 보안기능 스캐너
5. Session Security Test Skill
6. CSRF Test Skill
7. Access Control Test Skill
8. Brute Force Test Skill

### Phase 3: 보조 스캐너
9. Error Disclosure Test Skill
10. SSL/TLS Analysis Skill
11. HTTP Header Security Skill
12. Information Leakage Test Skill

### Phase 4: 리포팅 및 자동화
13. Report Generator Skill
14. Evidence Collector Skill
15. Orchestrator Agent

---

## 📝 주의사항

1. **법적 고려**: 반드시 테스트 대상 시스템 소유자의 사전 동의 필요
2. **범위 제한**: 합의된 범위 내에서만 테스트 수행
3. **데이터 보호**: 수집된 정보의 안전한 관리
4. **영향 최소화**: 시스템 가용성에 영향을 주지 않도록 주의

---

## 📚 참고 기준

- 행정안전부 소프트웨어 개발보안 가이드 (2021.11)
- OWASP Top 10 (2021)
- CWE/SANS Top 25
- CVSS v3.1 점수 체계
