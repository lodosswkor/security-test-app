# Security Test App & Skills

보안 점검 학습/테스트를 위한 취약점이 포함된 Ruby on Rails 웹 애플리케이션입니다.

> **경고**: 이 애플리케이션은 교육 목적으로 의도적으로 보안 취약점을 포함하고 있습니다. 절대로 프로덕션 환경에서 사용하지 마세요.

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| Infrastructure | Docker / Docker Compose |
| Language/Framework | Ruby 3.2 / Rails 7.1 |
| Database | PostgreSQL 15 |
| Web Server | Puma |

---

## 기능

- **회원가입**: 새 사용자 등록
- **로그인/로그아웃**: 세션 기반 인증
- **회원목록**: 로그인한 사용자만 조회 가능

### 흐름

```
회원가입 → 로그인 → 회원목록 → 로그아웃
```

---

## 실행 방법

### 1. Docker Compose로 실행

```bash
cd security-test-app
docker-compose up --build
```

### 2. 접속

브라우저에서 http://localhost:3000 접속

### 3. 테스트 계정

| 구분 | 이메일 | 비밀번호 |
|------|--------|----------|
| 관리자 | admin@test.com | admin123 |
| 일반 사용자 | user@test.com | user123 |

### 4. 종료

```bash
docker-compose down
```

데이터 초기화가 필요한 경우:
```bash
docker-compose down -v
```

---

## 포함된 취약점

### 1. SQL Injection
- **위치**: 로그인 (`sessions_controller.rb`)
- **원인**: 사용자 입력을 직접 SQL 쿼리에 삽입
- **테스트 방법**:
  ```
  Email: ' OR '1'='1' --
  Password: (아무 값)
  ```

### 2. XSS (Cross-Site Scripting)
- **위치**: 회원목록 (`users/index.html.erb`)
- **원인**: `raw` 헬퍼로 사용자 입력을 이스케이프 없이 출력
- **테스트 방법**:
  ```
  회원가입 시 이름에 입력: <script>alert('XSS')</script>
  ```

### 3. Mass Assignment
- **위치**: 회원가입 (`users_controller.rb`)
- **원인**: `params.permit!`로 모든 파라미터 허용
- **테스트 방법**:
  ```bash
  curl -X POST http://localhost:3000/users \
    -d "user[email]=hacker@test.com" \
    -d "user[name]=Hacker" \
    -d "user[password]=hack123" \
    -d "user[is_admin]=true"
  ```

### 4. 평문 비밀번호 저장
- **위치**: User 모델 및 DB
- **원인**: bcrypt 미사용, 비밀번호를 암호화 없이 저장

### 5. CSRF 보호 비활성화
- **위치**: `application_controller.rb`
- **원인**: `skip_forgery_protection` 설정

### 6. 인증 우회
- **위치**: `application_controller.rb`
- **원인**: 쿠키 검증 로직 취약
- **테스트 방법**: 브라우저 개발자 도구에서 `remember_token` 쿠키 조작

---

## 프로젝트 구조

```
security-test-app/
├── Dockerfile
├── docker-compose.yml
├── Gemfile
├── Rakefile
├── config.ru
├── entrypoint.sh
├── README.md
├── config/
│   ├── application.rb
│   ├── boot.rb
│   ├── environment.rb
│   ├── database.yml
│   ├── routes.rb
│   ├── environments/
│   │   └── development.rb
│   └── initializers/
│       ├── assets.rb
│       ├── secret_key_base.rb
│       └── session_store.rb
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── sessions_controller.rb
│   │   └── users_controller.rb
│   ├── models/
│   │   ├── application_record.rb
│   │   └── user.rb
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application.html.erb
│   │   ├── sessions/
│   │   │   └── new.html.erb
│   │   └── users/
│   │       ├── new.html.erb
│   │       └── index.html.erb
│   └── assets/
│       ├── config/
│       │   └── manifest.js
│       └── stylesheets/
│           └── application.css
└── db/
    ├── migrate/
    │   └── 20240101000000_create_users.rb
    └── seeds.rb
```

---

## 라우팅

| Method | Path | Controller#Action | 설명 |
|--------|------|-------------------|------|
| GET | / | sessions#new | 루트 (로그인 페이지) |
| GET | /signup | users#new | 회원가입 폼 |
| POST | /users | users#create | 회원가입 처리 |
| GET | /users | users#index | 회원목록 (로그인 필요) |
| GET | /login | sessions#new | 로그인 폼 |
| POST | /login | sessions#create | 로그인 처리 |
| GET/DELETE | /logout | sessions#destroy | 로그아웃 |

---

## 보안 점검 도구 추천

- **SQL Injection**: sqlmap
- **XSS**: Burp Suite, OWASP ZAP
- **전체 스캔**: Nikto, OWASP ZAP

---

## 라이선스

이 프로젝트는 교육 목적으로만 사용해야 합니다.
