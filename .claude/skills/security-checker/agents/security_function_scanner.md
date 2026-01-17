# Security Function Scanner Agent (보안기능 스캐너)

인증, 인가, 세션 관리 등 보안기능 취약점을 테스트하는 에이전트

---

## 역할

- 인증 우회 테스트
- 인가 테스트
- 세션 관리 테스트
- 암호화/비밀번호 정책 테스트

---

## 대상 취약점

| 번호 | 취약점 | 현재 앱 존재 여부 |
|------|--------|------------------|
| 1 | 적절한 인증 없는 중요기능 허용 | ✅ 존재 |
| 2 | 부적절한 인가 | ✅ 존재 |
| 3 | 취약한 비밀번호 저장 | ✅ 존재 (평문) |
| 4 | 쿠키를 통한 정보노출 | ✅ 존재 |
| 5 | 반복된 인증시도 제한 부재 | ✅ 존재 |

---

## Skill 1: Authentication Bypass Test (인증 우회)

### 대상
- 엔드포인트: `GET /users` (인증 필요 페이지)
- 쿠키: `remember_token`

### 테스트 방법

#### 1. 직접 URL 접근
```bash
# 인증 없이 직접 접근
curl http://localhost:3000/users

# 예상: 로그인 페이지로 리다이렉트 또는 접근 거부
# 취약: 회원목록이 보임
```

#### 2. 쿠키 조작
```bash
# remember_token 쿠키로 인증 우회 시도
curl -b "remember_token=1" http://localhost:3000/users

# 예상: 접근 거부
# 취약: 사용자 ID만으로 인증됨
```

#### 3. 세션 ID 예측
```bash
# 여러 번 로그인하여 세션 ID 패턴 분석
for i in {1..5}; do
  curl -c - -X POST http://localhost:3000/login \
    -d "email=user@test.com&password=user123" 2>/dev/null | grep session
done
```

### 탐지 기준
- 쿠키 조작으로 인증 우회 가능 → **Critical**
- 인증 없이 페이지 접근 가능 → **High**

### 권장 조치
```
참조: SR2-1 인증 대상 및 방식

1. 서버 측 세션 검증
   before_action :require_login

2. 안전한 세션 토큰 사용
   - 예측 불가능한 랜덤 값
   - 서명된 쿠키 사용

3. remember_token 제거 또는 암호화
```

---

## Skill 2: Authorization Test (인가 테스트)

### 대상
- 일반 사용자가 관리자 기능 접근 시도

### 테스트 방법

```bash
# 1. 일반 사용자로 로그인
curl -c cookies.txt -X POST http://localhost:3000/login \
  -d "email=user@test.com&password=user123"

# 2. 다른 사용자 정보 접근 시도 (있다면)
curl -b cookies.txt http://localhost:3000/users/1
curl -b cookies.txt http://localhost:3000/users/2

# 3. 관리자 전용 기능 접근 시도 (있다면)
curl -b cookies.txt http://localhost:3000/admin
```

### 탐지 기준
- 다른 사용자 정보 접근 가능 → **High**
- 권한 없는 기능 실행 가능 → **Critical**

### 권장 조치
```
참조: SR2-3 부적절한 인가

1. 모든 요청에서 권한 확인
   before_action :authorize_admin, only: [:admin_action]

2. 리소스 소유자 확인
   @user = current_user.id == params[:id] ? User.find(params[:id]) : nil
```

---

## Skill 3: Password Security Test (비밀번호 보안)

### 대상
- 비밀번호 저장 방식
- 비밀번호 정책

### 테스트 방법

#### 1. 약한 비밀번호 허용 테스트
```bash
# 짧은 비밀번호
curl -X POST http://localhost:3000/users \
  -d "user[email]=weak1@test.com&user[name]=Weak&user[password]=123"

# 단순 비밀번호
curl -X POST http://localhost:3000/users \
  -d "user[email]=weak2@test.com&user[name]=Weak&user[password]=password"

# 성공하면 취약
```

#### 2. 평문 비밀번호 확인
```
현재 앱은 비밀번호를 평문으로 저장함
DB 접근 시: SELECT password FROM users;
→ 암호화되지 않은 비밀번호 확인 가능
```

### 탐지 기준
- 평문 비밀번호 저장 → **Critical**
- 약한 비밀번호 허용 → **Medium**
- 비밀번호 정책 없음 → **Low**

### 권장 조치
```
참조: SR2-6 암호연산

1. bcrypt 사용
   has_secure_password

2. 비밀번호 정책 적용
   validates :password, length: { minimum: 8 }
   validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/ }
```

---

## Skill 4: Session Security Test (세션 보안)

### 대상
- 세션 쿠키 설정
- 세션 만료

### 테스트 방법

```bash
# 1. 쿠키 속성 확인
curl -c - -X POST http://localhost:3000/login \
  -d "email=user@test.com&password=user123"

# 확인 항목:
# - HttpOnly 플래그
# - Secure 플래그 (HTTPS 환경)
# - SameSite 속성

# 2. 세션 만료 테스트
# 로그인 후 일정 시간 대기 후 접근
```

### 쿠키 보안 체크리스트

| 속성 | 권장값 | 현재 앱 |
|------|--------|---------|
| HttpOnly | true | 확인 필요 |
| Secure | true (HTTPS) | N/A |
| SameSite | Strict/Lax | 확인 필요 |
| 만료시간 | 적절한 값 | 확인 필요 |

### 권장 조치
```
참조: SR4-1 세션통제

1. 안전한 쿠키 설정
   Rails.application.config.session_store :cookie_store,
     key: '_session',
     httponly: true,
     secure: Rails.env.production?,
     same_site: :strict

2. 세션 타임아웃 설정
3. 로그인 시 세션 ID 재생성
```

---

## Skill 5: Brute Force Protection Test

### 대상
- 로그인 엔드포인트: `POST /login`

### 테스트 방법

```bash
# 10회 연속 실패 시도
for i in {1..10}; do
  echo "Attempt $i:"
  curl -s -X POST http://localhost:3000/login \
    -d "email=admin@test.com&password=wrong$i" \
    -w "\nHTTP Code: %{http_code}\n"
done

# 계정 잠금 또는 지연 없으면 취약
```

### 탐지 기준
- 무제한 로그인 시도 가능 → **Medium**
- 계정 잠금 없음 → **Medium**
- CAPTCHA 없음 → **Low**

### 권장 조치
```
참조: SR2-2 인증 수행 제한

1. 로그인 시도 횟수 제한
   - 5회 실패 시 계정 잠금 (30분)
   - 또는 지수적 지연 적용

2. CAPTCHA 적용
3. 실패 로그 기록
```

---

## 출력 형식

```json
{
  "scanner": "security_function_scanner",
  "target": "http://localhost:3000",
  "vulnerabilities": [
    {
      "id": "VULN-003",
      "type": "Authentication Bypass",
      "severity": "Critical",
      "cvss": 9.1,
      "endpoint": "Cookie",
      "parameter": "remember_token",
      "evidence": "쿠키 값 조작으로 인증 우회 가능",
      "remediation": "서명된 세션 토큰 사용"
    },
    {
      "id": "VULN-004",
      "type": "Plaintext Password Storage",
      "severity": "Critical",
      "cvss": 9.0,
      "endpoint": "Database",
      "evidence": "비밀번호가 암호화 없이 저장됨",
      "remediation": "bcrypt 사용"
    },
    {
      "id": "VULN-005",
      "type": "No Brute Force Protection",
      "severity": "Medium",
      "cvss": 5.3,
      "endpoint": "POST /login",
      "evidence": "무제한 로그인 시도 가능",
      "remediation": "로그인 시도 횟수 제한"
    }
  ]
}
```
