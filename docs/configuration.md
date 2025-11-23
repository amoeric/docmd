# 配置說明

## 基本配置

在 `config/initializers/docmd.rb` 中設定：

```ruby
Docmd.configure do |config|
  # 設定 Markdown 檔案資料夾路徑
  config.markdown_folder_path = Rails.root.join('docs')

  # 其他範例路徑：
  # config.markdown_folder_path = Rails.root.join('app', 'documents')
  # config.markdown_folder_path = '/absolute/path/to/markdown/files'

  # 設定擁有最高權限的角色（可查看所有文件）
  # 預設為 [:admin, :super_admin]
  config.admin_roles = [:admin, :super_admin]

  # 自訂範例：
  # config.admin_roles = [:root]  # 只有 root 角色有最高權限
  # config.admin_roles = [:admin, :manager, :moderator]  # 多個角色
  # config.admin_roles = []  # 沒有最高權限角色

  # 是否顯示文件大綱目錄 (Table of Contents)
  # 預設為 true，會在文件右側顯示基於標題（h1, h2, h3）的樹狀目錄
  # 設為 false 可以隱藏目錄，讓文章內容佔滿整個寬度
  config.show_toc = true

  # 範例：隱藏文件大綱目錄
  # config.show_toc = false
end
```

## 掛載路由

在 `config/routes.rb` 中掛載 engine：

```ruby
Rails.application.routes.draw do
  mount Docmd::Engine => "/docmd"
  # 其他路由...
end
```

## 支援的 Markdown 功能

Docmd 使用 Redcarpet，支援以下 Markdown 擴充功能：
- 自動連結轉換
- 表格
- 程式碼區塊（fenced code blocks）
- 刪除線
- 語法高亮
- 上標文字
- 底線
- 引用
- 註腳
- 更多...