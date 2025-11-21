Docmd::Engine.routes.draw do
  # Docs CRUD routes
  resources :docs, param: :slug do
    collection do
      post :preview  # Turbo Frame 會用 POST 送出表單資料
    end
    member do
      post :publish
      post :unpublish
    end
  end

  # Tags routes
  resources :tags, only: [:index, :show]

  # Images routes
  resources :images, only: [:index, :new, :create] do
    collection do
      get :insert  # 圖片選擇器
    end
  end

  # 圖片顯示路由（支援子目錄路徑）
  get 'images/*path', to: 'images#show', as: :image_file
  delete 'images/*path', to: 'images#destroy'

  # 根路徑導向文件列表
  root to: 'docs#index'
end
