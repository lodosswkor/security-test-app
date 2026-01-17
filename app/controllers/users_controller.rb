class UsersController < ApplicationController
  before_action :require_login, only: [:index]

  def new
    @user = User.new
  end

  def create
    # [취약점] Mass Assignment - 모든 파라미터 허용
    # is_admin=true 를 전송하면 관리자 계정 생성 가능
    @user = User.new(params.require(:user).permit!)

    if @user.save
      redirect_to login_path, notice: "회원가입 완료! 로그인해주세요."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @users = User.all
  end
end
