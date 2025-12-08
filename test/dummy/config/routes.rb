Rails.application.routes.draw do
  mount Docmd::Engine => "/docmd"

  # 測試用的登入路由
  post '/test_sign_in', to: 'test_sessions#create' if Rails.env.test?

  root to: 'home#index'
end
