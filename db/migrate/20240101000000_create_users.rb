class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      # [취약점] 비밀번호를 평문으로 저장 (bcrypt 미사용)
      t.string :email, null: false
      t.string :name
      t.string :password  # 평문 비밀번호 저장
      t.boolean :is_admin, default: false  # Mass Assignment 취약점용

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
