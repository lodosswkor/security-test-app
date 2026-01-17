class ApplicationController < ActionController::Base
  # [취약점] CSRF 보호 비활성화
  skip_forgery_protection

  helper_method :current_user, :logged_in?

  def current_user
    # [취약점] 세션에서 user_id만 확인, 추가 검증 없음
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    # [취약점] 인증 우회 가능 - 쿠키 조작으로 우회 가능
    unless logged_in? || cookies[:remember_token]
      redirect_to login_path, alert: "로그인이 필요합니다."
    end
  end
end
