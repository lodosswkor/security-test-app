class User < ApplicationRecord
  # [취약점] 비밀번호 암호화 없음 - 평문 저장
  # [취약점] 유효성 검사 최소화
  validates :email, presence: true
end
