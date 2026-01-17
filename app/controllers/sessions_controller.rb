class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:email]
    password = params[:password]

    # [취약점] SQL Injection - 사용자 입력을 직접 쿼리에 삽입
    # 예: email에 ' OR '1'='1' -- 입력 시 인증 우회 가능
    user = User.where("email = '#{email}' AND password = '#{password}'").first

    if user
      session[:user_id] = user.id
      # [취약점] 쿠키에 민감 정보 저장 (암호화 없음)
      cookies[:remember_token] = user.id
      redirect_to users_path, notice: "로그인 성공!"
    else
      flash.now[:alert] = "이메일 또는 비밀번호가 잘못되었습니다."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    cookies.delete(:remember_token)
    redirect_to login_path, notice: "로그아웃 되었습니다."
  end
end
