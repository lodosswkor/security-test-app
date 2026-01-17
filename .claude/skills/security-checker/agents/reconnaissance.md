# Reconnaissance Agent (정보수집 에이전트)

대상 시스템의 정보를 수집하는 에이전트

---

## 역할

- 웹 서버 정보 수집 (헤더 분석)
- 기술 스택 식별
- 디렉토리/파일 구조 매핑
- 입력 포인트 식별 (폼, 파라미터, 쿠키)
- API 엔드포인트 수집
- 에러 페이지 정보 수집

---

## 설정

```yaml
recon_agent:
  name: "reconnaissance-agent"
  target: "http://localhost:3000"
  skills:
    - tech_stack_fingerprint
    - endpoint_mapping
    - input_point_discovery
    - error_page_analysis
```

---

## 수집 항목

### 1. 서버 정보 수집

```bash
# HTTP 헤더 분석
curl -I http://localhost:3000

# 예상 결과:
# Server: nginx 또는 puma
# X-Powered-By: 노출 시 기술스택 정보
# X-Frame-Options: Clickjacking 방어 여부
# X-XSS-Protection: XSS 필터 설정
# Content-Security-Policy: CSP 설정 여부
```

### 2. 기술 스택 식별

| 항목 | 값 |
|------|-----|
| Language | Ruby |
| Framework | Rails 7.1 |
| Database | PostgreSQL |
| Web Server | Puma |

**식별 방법:**
- 쿠키명: `_session_id` → Rails
- 에러 페이지: Rails 기본 에러 페이지
- 응답 헤더: X-Runtime, X-Request-Id

### 3. 엔드포인트 매핑

```
GET  /            → 루트 (로그인 페이지로 리다이렉트)
GET  /signup      → 회원가입 폼
POST /users       → 회원가입 처리
GET  /users       → 회원목록 (인증 필요)
GET  /login       → 로그인 폼
POST /login       → 로그인 처리
GET  /logout      → 로그아웃
```

### 4. 입력 포인트 식별

#### 로그인 폼 (/login)
```html
<input name="email" type="email">
<input name="password" type="password">
```
- 입력 포인트: `email`, `password`
- 메서드: POST
- 인코딩: application/x-www-form-urlencoded

#### 회원가입 폼 (/signup)
```html
<input name="user[email]" type="email">
<input name="user[name]" type="text">
<input name="user[password]" type="password">
```
- 입력 포인트: `user[email]`, `user[name]`, `user[password]`
- 숨겨진 파라미터 가능: `user[is_admin]`
- 메서드: POST

### 5. 쿠키/세션 분석

```
쿠키명: _security_test_session
  - HttpOnly: 확인 필요
  - Secure: 확인 필요
  - SameSite: 확인 필요

쿠키명: remember_token
  - 값: 사용자 ID (취약)
  - HttpOnly: 없음 (취약)
```

### 6. 에러 페이지 분석

```bash
# 존재하지 않는 페이지
curl http://localhost:3000/nonexistent

# SQL 에러 유발
curl -X POST http://localhost:3000/login -d "email='&password=test"

# 확인 항목:
# - 스택 트레이스 노출 여부
# - DB 정보 노출 여부
# - 서버 경로 노출 여부
```

---

## 실행 명령

```bash
# 1. 기본 정보 수집
curl -I http://localhost:3000

# 2. 페이지 구조 확인
curl -s http://localhost:3000/login | grep -E '<form|<input|name='
curl -s http://localhost:3000/signup | grep -E '<form|<input|name='

# 3. 쿠키 확인
curl -c cookies.txt -b cookies.txt http://localhost:3000/login
cat cookies.txt

# 4. 에러 페이지 확인
curl http://localhost:3000/404test
```

---

## 출력 형식

```json
{
  "target": "http://localhost:3000",
  "tech_stack": {
    "language": "Ruby",
    "framework": "Rails 7.1",
    "database": "PostgreSQL",
    "web_server": "Puma"
  },
  "endpoints": [
    {"method": "GET", "path": "/login", "auth_required": false},
    {"method": "POST", "path": "/login", "auth_required": false},
    {"method": "GET", "path": "/signup", "auth_required": false},
    {"method": "POST", "path": "/users", "auth_required": false},
    {"method": "GET", "path": "/users", "auth_required": true},
    {"method": "GET", "path": "/logout", "auth_required": true}
  ],
  "input_points": [
    {"endpoint": "/login", "params": ["email", "password"]},
    {"endpoint": "/users", "params": ["user[email]", "user[name]", "user[password]"]}
  ],
  "cookies": [
    {"name": "_security_test_session", "httponly": true},
    {"name": "remember_token", "httponly": false, "note": "취약"}
  ]
}
```
