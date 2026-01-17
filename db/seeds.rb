# 테스트용 기본 사용자 생성
User.create!(
  email: 'admin@test.com',
  name: 'Admin User',
  password: 'admin123',
  is_admin: true
)

User.create!(
  email: 'user@test.com',
  name: 'Normal User',
  password: 'user123',
  is_admin: false
)

puts "Seeds created!"
puts "Admin: admin@test.com / admin123"
puts "User: user@test.com / user123"
