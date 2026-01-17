Rails.application.routes.draw do
  root "sessions#new"

  # 회원가입
  get  "/signup", to: "users#new"
  post "/users",  to: "users#create"

  # 회원목록
  get "/users", to: "users#index"

  # 로그인/로그아웃
  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  get    "/logout", to: "sessions#destroy"
  delete "/logout", to: "sessions#destroy"
end
