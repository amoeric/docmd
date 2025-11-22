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