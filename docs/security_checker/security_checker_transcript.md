# 화이트해커 블랙박스 테스트 Agent 설계 Transcript

> **작성일**: 2026-01-18  
> **주제**: 행정안전부 소프트웨어 개발보안 가이드 기반 모의해킹 Agent 설계  
> **참조 문서**: 행정안전부_소프트웨어_개발보안_가이드_20211229.pdf

---

## 📋 요청 사항

**사용자 요청:**
> 너는 보안점검 전문가로, 블랙박스 테스트를 진행하는 '화이트해커' 전문 claude code 용 agent(s)를 만들고 싶어. 외부에서 테스트 하는 화이트 해커이기 때문에, DB내부나 인프라적인 것들을 제외하고 순수하게  '모의해킹'을 통해 취약점을 검출하고 그 결과 및 권장처리 방법을 문서화 해줘야해. 
첨부된 문서를 참고하여, 어떤 agent(s) 혹은 skill(s)가 필요할지 정리해줘

---

## 📚 참조 문서 분석 결과

### 행정안전부 소프트웨어 개발보안 가이드 핵심 내용

#### 적용 기준
| 구분 | 항목 수 | 설명 |
|------|---------|------|
| 설계단계 보안설계 기준 | 20개 | SR1-1 ~ SR4-1 |
| 구현단계 보안약점 제거 기준 | 49개 | 7대 분류 |

#### 구현단계 7대 보안약점 분류

| 분류 | 항목 수 | 주요 취약점 |
|------|---------|------------|
| 1. 입력데이터 검증 및 표현 | 17개 | SQL 삽입, XSS, 명령어 삽입, 파일 업로드 등 |
| 2. 보안기능 | 16개 | 인증 우회, 암호화, 접근제어 등 |
| 3. 시간 및 상태 | 2개 | TOCTOU, 무한 반복 |
| 4. 에러처리 | 3개 | 오류 메시지 노출, 예외 처리 |
| 5. 코드오류 | 5개 | Null Pointer, 자원 해제, 역직렬화 |
| 6. 캡슐화 | 4개 | 세션 정보 노출, 디버그 코드 |
| 7. API 오용 | 2개 | DNS lookup, 취약한 API |

---

## 🤖 Agent 아키텍처 설계

### 전체 구조도

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
│ Agent   │         │ Agents  │          │ Agent   │
└────┬────┘         └────┬────┘          └────┬────┘
     │                   │                    │
     ▼                   ▼                    ▼
┌─────────┐    ┌─────────────────┐    ┌─────────────┐
│정보수집 │    │취약점 스캔/검증  │    │ 보고서 생성  │
│Skills   │    │    Skills       │    │   Skills    │
└─────────┘    └─────────────────┘    └─────────────┘
```

### Agent 정의

#### 1. Orchestrator Agent (총괄)
| 항목 | 내용 |
|------|------|
| **역할** | 전체 테스트 워크플로우 조율 |
| **기능** | 대상 URL 검증, 에이전트 호출, 취약점 우선순위 결정, 상태 관리 |

#### 2. Reconnaissance Agent (정보수집)
| 항목 | 내용 |
|------|------|
| **역할** | 대상 시스템 정보 수집 |
| **Skills** | tech_stack_fingerprint, directory_enumeration, input_point_mapping, api_endpoint_discovery, error_page_analysis |

#### 3. Scanner Agents (취약점 스캔) - 4개

| Agent | 대상 | 주요 테스트 항목 |
|-------|------|-----------------|
| **Input Validation Scanner** | 입력데이터 검증 (17개) | SQL Injection, XSS, Command Injection, File Upload, CSRF, SSRF 등 |
| **Security Function Scanner** | 보안기능 (16개) | 인증 우회, 접근제어, 암호화 강도, 세션 토큰 분석 등 |
| **Error Handling Scanner** | 에러처리 (3개) | 에러 메시지 노출, 스택 트레이스, 디버그 정보 |
| **Session Management Scanner** | 세션통제 | 세션 예측, 세션 고정, 세션 만료 |

#### 4. Reporter Agent (리포팅)
| 항목 | 내용 |
|------|------|
| **역할** | 취약점 결과 종합 및 보고서 생성 |
| **출력** | 경영진 요약, 기술 상세 보고서, 권장 조치사항, CVSS 점수 |

---

## 📊 블랙박스 테스트 가능 취약점 매핑

### 입력데이터 검증 및 표현 (17개 중 14개 테스트 가능)

| 번호 | 취약점 | 블랙박스 | 테스트 방법 |
|------|--------|:--------:|------------|
| 1 | SQL 삽입 | ✅ | Error-based, Blind, Time-based |
| 2 | 코드 삽입 | ✅ | 동적 코드 실행 테스트 |
| 3 | 경로 조작 및 자원 삽입 | ✅ | ../../../ 패턴 |
| 4 | 크로스사이트 스크립트(XSS) | ✅ | Reflected, Stored, DOM |
| 5 | 운영체제 명령어 삽입 | ✅ | ; | && 등 메타문자 |
| 6 | 위험한 형식 파일 업로드 | ✅ | 확장자 우회, Content-Type 조작 |
| 7 | 신뢰되지 않는 URL 자동접속 | ✅ | Open Redirect 테스트 |
| 8 | 부적절한 XML 외부 개체 참조 | ✅ | XXE Payload |
| 9 | XML 삽입 | ✅ | XPath/XQuery Injection |
| 10 | LDAP 삽입 | ✅ | LDAP 특수문자 삽입 |
| 11 | 크로스사이트 요청 위조(CSRF) | ✅ | 토큰 검증 테스트 |
| 12 | 서버사이드 요청 위조(SSRF) | ✅ | 내부 서버 접근 시도 |
| 13 | HTTP 응답분할 | ✅ | CRLF Injection |
| 14 | 정수형 오버플로우 | ⚠️ | 제한적 테스트 |
| 15 | 보안기능 결정에 사용되는 부적절한 입력값 | ✅ | 파라미터 조작 |
| 16 | 메모리 버퍼 오버플로우 | ⚠️ | 제한적 |
| 17 | 포맷 스트링 삽입 | ⚠️ | 제한적 |

### 보안기능 (16개 중 12개 테스트 가능)

| 번호 | 취약점 | 블랙박스 | 테스트 방법 |
|------|--------|:--------:|------------|
| 1 | 적절한 인증 없는 중요기능 허용 | ✅ | 직접 URL 접근 |
| 2 | 부적절한 인가 | ✅ | 권한 상승 테스트 |
| 3 | 중요 자원에 대한 잘못된 권한 설정 | ✅ | 다른 사용자 자원 접근 |
| 4 | 취약한 암호화 알고리즘 사용 | ✅ | SSL/TLS 분석 |
| 5 | 암호화되지 않은 중요정보 | ✅ | 전송 데이터 분석 |
| 6 | 하드코드된 중요정보 | ⚠️ | JS/HTML 소스 분석 |
| 7 | 충분하지 않은 키 길이 사용 | ✅ | SSL/TLS 분석 |
| 8 | 적절하지 않은 난수값 사용 | ✅ | 세션/토큰 패턴 분석 |
| 9 | 취약한 비밀번호 허용 | ✅ | 약한 비밀번호 등록 시도 |
| 10 | 부적절한 전자서명 확인 | ⚠️ | 제한적 |
| 11 | 부적절한 인증서 유효성 검증 | ✅ | 인증서 검증 |
| 12 | 쿠키를 통한 정보노출 | ✅ | 쿠키 속성 분석 |
| 13 | 주석문 안에 포함된 시스템 주요정보 | ✅ | HTML 소스 분석 |
| 14 | 솔트 없이 일방향 해쉬함수 사용 | ⚠️ | 제한적 |
| 15 | 무결성 검사 없는 코드 다운로드 | ✅ | 다운로드 분석 |
| 16 | 반복된 인증시도 제한 기능 부재 | ✅ | Brute Force 테스트 |

---

## 🔧 핵심 Skills 정의

### Skill 1: SQL Injection Test

```yaml
skill_name: sql_injection_test
category: 입력데이터 검증 및 표현
reference: SR1-1 DBMS 조회 및 결과 검증

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
  - "PreparedStatement 또는 파라미터화된 쿼리 사용"
  - "입력값 검증 및 이스케이프 처리"
  - "최소 권한 DB 계정 사용"
```

### Skill 2: XSS Test

```yaml
skill_name: xss_test
category: 입력데이터 검증 및 표현
reference: SR1-5 웹 서비스 요청 및 결과 검증

test_vectors:
  - "<script>alert('XSS')</script>"
  - "<img src=x onerror=alert('XSS')>"
  - "javascript:alert('XSS')"
  - "<svg onload=alert('XSS')>"

detection_methods:
  - reflected: "입력값이 응답에 그대로 반영"
  - stored: "저장된 데이터가 실행"
  - dom_based: "DOM 조작 스크립트 실행"

remediation:
  - "HTML 인코딩/이스케이프 처리"
  - "Content-Security-Policy 헤더 설정"
  - "입력값 화이트리스트 검증"
```

### Skill 3: Authentication Bypass Test

```yaml
skill_name: authentication_bypass_test
category: 보안기능
reference: SR2-1 인증 대상 및 방식

test_methods:
  - direct_url_access: "인증 없이 URL 직접 접근"
  - parameter_manipulation: "인증 파라미터 조작"
  - cookie_manipulation: "쿠키 값 조작"
  - jwt_token_attack: "JWT 토큰 취약점"

remediation:
  - "모든 중요 페이지에 서버측 인증 확인"
  - "세션 기반 인증 상태 검증"
  - "안전한 토큰 검증 메커니즘"
```

### Skill 4: File Upload Test

```yaml
skill_name: file_upload_test
category: 입력데이터 검증 및 표현
reference: SR1-10 업로드·다운로드 파일 검증

test_methods:
  - extension_bypass: "test.php.jpg, test.pHp"
  - content_type_bypass: "Content-Type 헤더 조작"
  - magic_byte_bypass: "매직 바이트 조작"
  - null_byte: "test.php%00.jpg"

dangerous_extensions:
  - ".php, .jsp, .asp, .aspx"
  - ".exe, .sh, .bat"
  - ".htaccess"

remediation:
  - "화이트리스트 기반 확장자 검증"
  - "파일 내용(매직 바이트) 검증"
  - "업로드 디렉토리 실행 권한 제거"
  - "파일명 랜덤화"
```

### Skill 5: CSRF Test

```yaml
skill_name: csrf_test
category: 입력데이터 검증 및 표현
reference: SR1-6 웹 기반 중요 기능 수행 요청 유효성 검증

test_methods:
  - token_absence: "CSRF 토큰 존재 여부"
  - token_validation: "토큰 검증 로직"
  - referer_check: "Referer 헤더 검증"

remediation:
  - "CSRF 토큰 구현"
  - "SameSite 쿠키 속성 설정"
  - "중요 기능에 재인증 요구"
```

### Skill 6: Session Security Test

```yaml
skill_name: session_security_test
category: 세션통제
reference: SR4-1 세션통제

test_methods:
  - session_prediction: "세션 ID 예측 가능성"
  - session_fixation: "세션 고정 공격"
  - session_timeout: "세션 만료 시간"
  - concurrent_sessions: "동시 세션 허용"

remediation:
  - "로그인 시 세션 ID 재생성"
  - "안전한 세션 ID 생성 알고리즘"
  - "세션 타임아웃 설정"
  - "HttpOnly, Secure 쿠키 속성"
```

### Skill 7: Error Disclosure Test

```yaml
skill_name: error_disclosure_test
category: 에러처리
reference: SR3-1 예외처리

test_methods:
  - invalid_input: "비정상 입력으로 에러 유발"
  - missing_parameter: "필수 파라미터 제거"
  - sql_error_trigger: "SQL 문법 오류 유발"

check_items:
  - "스택 트레이스 노출"
  - "DB 정보 노출"
  - "서버 경로 노출"
  - "프레임워크/버전 정보 노출"

remediation:
  - "사용자 정의 에러 페이지 구현"
  - "상세 에러 로깅은 서버측에서만"
  - "일반적인 에러 메시지만 클라이언트에 전달"
```

### Skill 8: SSL/TLS Analysis

```yaml
skill_name: ssl_tls_analysis
category: 보안기능
reference: SR2-6 암호연산

check_items:
  - protocol_version: "TLS 1.2 이상 사용"
  - cipher_suites: "취약한 암호 스위트"
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
  - "TLS 1.2 이상만 허용"
  - "강력한 암호 스위트만 활성화"
  - "HSTS 헤더 설정"
```

### Skill 9: Brute Force Protection Test

```yaml
skill_name: brute_force_test
category: 보안기능
reference: SR2-2 인증 수행 제한

test_methods:
  - login_attempt_limit: "로그인 시도 횟수 제한"
  - account_lockout: "계정 잠금 정책"
  - captcha_presence: "CAPTCHA 존재"
  - response_delay: "응답 지연"

remediation:
  - "로그인 시도 횟수 제한 (예: 5회)"
  - "실패 시 계정 잠금 또는 지연"
  - "CAPTCHA 적용"
  - "실패 이력 로깅"
```

### Skill 10: Report Generator

```yaml
skill_name: report_generator
category: 리포팅

report_sections:
  - executive_summary: "경영진용 요약"
  - vulnerability_list: "취약점 목록"
  - risk_assessment: "위험도 평가"
  - technical_details: "기술적 상세"
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

## 🗂️ 권장 파일 구조

```
/mnt/skills/user/whitehacker/
├── SKILL.md                          # 메인 스킬 가이드
├── agents/
│   ├── orchestrator.md               # 총괄 에이전트
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

## 📈 테스트 워크플로우

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

## 🎯 구현 우선순위

### Phase 1: 핵심 취약점 스캐너 (우선 구현)
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
15. Orchestrator Agent 완성

---

## ⚠️ 주의사항

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

---

## 📝 다음 단계

이 설계를 바탕으로:
1. 각 Agent의 상세 구현 스펙 작성
2. Skill별 테스트 페이로드 수집
3. 보고서 템플릿 상세화
4. 실제 코드 구현

추가 질문이나 특정 Agent/Skill에 대한 상세 설계가 필요하면 말씀해주세요.
