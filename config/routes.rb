Docmd::Engine.routes.draw do
  # Docs CRUD routes
  resources :docs, param: :slug do
    member do
      post :publish
      post :unpublish
    end
  end

  # 根路徑導向文件列表
  root to: 'docs#index'
end
