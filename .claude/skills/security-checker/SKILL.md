# Security Test App - Penetration Testing Skills

Security Test App을 대상으로 한 블랙박스 모의해킹 테스트 스킬 가이드

---

## 개요

### 대상 애플리케이션
- **URL**: http://localhost:3000
- **기술스택**: Ruby on Rails 7.1 / PostgreSQL 15
- **기능**: 회원가입, 로그인, 회원목록

### 테스트 범위
현재 앱에 포함된 6가지 취약점:
1. SQL Injection (로그인)
2. XSS - Stored (회원목록)
3. Mass Assignment (회원가입)
4. 평문 비밀번호 저장
5. CSRF 보호 비활성화
6. 인증 우회 (쿠키 조작)

---

## Agent 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│              Orchestrator Agent (총괄)                   │
│         테스트 계획, 에이전트 조율, 결과 집계              │
└────────────────────────┬────────────────────────────────┘
                         │
    ┌────────────────────┼────────────────────┐
    │                    │                    │
    ▼                    ▼                    ▼
┌─────────┐        ┌──────────┐        ┌──────────┐
│  Recon  │        │ Scanner  │        │ Reporter │
│  Agent  │        │  Agent   │        │  Agent   │
└────┬────┘        └────┬─────┘        └────┬─────┘
     │                  │                   │
     ▼                  ▼                   ▼
 정보수집            취약점 검증          보고서 생성
```

---

## 사용 가능한 Agents

| Agent | 파일 | 역할 |
|-------|------|------|
| Orchestrator | `agents/orchestrator.md` | 전체 테스트 워크플로우 조율 |
| Reconnaissance | `agents/reconnaissance.md` | 대상 정보 수집 |
| Input Validation Scanner | `agents/input_validation_scanner.md` | SQL Injection, XSS 테스트 |
| Security Function Scanner | `agents/security_function_scanner.md` | 인증/인가, 세션 테스트 |
| Reporter | `agents/reporter.md` | 결과 보고서 생성 |

---

## 테스트 워크플로우

### Phase 1: 정보수집
```bash
# 1. 기술 스택 확인
curl -I http://localhost:3000

# 2. 엔드포인트 매핑
GET  /           → 로그인 페이지
GET  /signup     → 회원가입 폼
POST /users      → 회원가입 처리
GET  /users      → 회원목록 (인증 필요)
GET  /login      → 로그인 폼
POST /login      → 로그인 처리
GET  /logout     → 로그아웃

# 3. 입력 포인트 식별
- 로그인: email, password
- 회원가입: user[email], user[name], user[password]
```

### Phase 2: 취약점 스캔
```bash
# SQL Injection 테스트
POST /login
email=' OR '1'='1' --&password=test

# XSS 테스트
POST /users
user[name]=<script>alert('XSS')</script>

# Mass Assignment 테스트
POST /users
user[email]=test@test.com&user[name]=Test&user[password]=test&user[is_admin]=true

# CSRF 테스트
외부 사이트에서 폼 전송 시도

# 인증 우회 테스트
쿠키 remember_token 값 조작
```

### Phase 3: 결과 검증 및 보고서 작성
- 취약점 재현 확인
- CVSS 점수 산정
- 보고서 생성

---

## 빠른 시작

### 전체 테스트 실행
```
Orchestrator Agent 호출 → 자동으로 모든 테스트 수행
```

### 개별 테스트 실행
```
1. Recon Agent: 정보 수집
2. Input Validation Scanner: SQL Injection, XSS 테스트
3. Security Function Scanner: 인증/세션 테스트
4. Reporter Agent: 보고서 생성
```

---

## 파일 구조

```
skills/
├── SKILL.md                           # 이 파일
├── agents/
│   ├── orchestrator.md                # 총괄 에이전트
│   ├── reconnaissance.md              # 정보수집 에이전트
│   ├── input_validation_scanner.md    # 입력값 검증 스캐너
│   ├── security_function_scanner.md   # 보안기능 스캐너
│   └── reporter.md                    # 리포터 에이전트
├── payloads/
│   ├── sql_injection.txt              # SQL 인젝션 페이로드
│   ├── xss.txt                        # XSS 페이로드
│   └── auth_bypass.txt                # 인증 우회 페이로드
├── templates/
│   ├── report_template.md             # 보고서 템플릿
│   └── vulnerability_template.md      # 취약점 상세 템플릿
└── reference/
    ├── vulnerability_mapping.md       # 취약점-가이드 매핑
    └── cvss_scoring.md                # CVSS 점수 기준
```

---

## 주의사항

1. **테스트 환경에서만 사용**: 이 스킬은 로컬 테스트 환경 전용입니다
2. **권한 확인**: 실제 시스템 테스트 시 반드시 사전 승인 필요
3. **데이터 보호**: 수집된 정보는 안전하게 관리

---

## 참고 기준

- 행정안전부 소프트웨어 개발보안 가이드 (2021)
- OWASP Top 10 (2021)
- CVSS v3.1
