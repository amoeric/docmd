# Docmd

Docmd 是一個 Rails engine gem，用於解析和管理 Markdown 檔案，
能夠快速的建立以 md 檔為基礎的文章系統，支援文章、圖片、標籤、角色權限功能。

## 主要功能

- **Markdown 文件管理** - 完整的 CRUD 功能
- **圖片管理** - 上傳、瀏覽、刪除圖片
- **標籤系統** - 文件分類與標籤雲
- **角色權限** - 基於 rolify 的權限控制
- **自訂版面** - 支援不同的 layout template
- **簡單整合** - 輕鬆掛載到 Rails 應用程式

## 安裝步驟

### 1. 加入 Gemfile

```ruby
# 從本地路徑（開發階段）
gem 'docmd', path: 'path/to/docmd'

# 或從 GitHub
gem 'docmd', github: 'your-username/docmd'

# 或從 RubyGems（發布後）
gem 'docmd'
```

### 2. 執行 bundle

```bash
bundle install
```

### 3. 執行 generator、建立設定檔

```bash
rails generate docmd:install
```

這會：
- 在 `config/initializers/docmd.rb` 建立配置檔
- 建立 `docs` 資料夾供你放置 Markdown 檔案

### 4. 掛載 engine 路由

在 `config/routes.rb` 中加入：

```ruby
Rails.application.routes.draw do
  mount Docmd::Engine => "/docmd"
  # 其他路由...
end
```

### 5. 加入 docmd CSS

專案所有頁面均使用 tailwindcss CDN

在主應用程式加入 docmd 設定的 markdown stylesheet

```
# app/views/laouts/application.html.erb
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "docmd/application", "data-turbo-track": "reload" %>
```

可以自訂 markdown 內容樣式：
- **[Markdown 內容樣式](docs/markdown_content_css.md)**

## 文件索引

詳細的使用說明請參考以下文件：

- **[配置說明](docs/configuration.md)** - 設定檔和路由配置
- **[使用方式](docs/usage.md)** - 基本使用和程式碼範例
- **[CRUD 功能](docs/crud.md)** - 文件的建立、讀取、更新、刪除
- **[圖片管理](docs/image-management.md)** - 圖片上傳和管理功能
- **[角色權限](docs/role-permissions.md)** - 基於角色的權限控制
- **[Pundit 整合](docs/pundit-integration.md)** - 使用 Pundit 進行進階權限管理
- **[API 文件](docs/api.md)** - 完整的 API 參考

## 快速開始

### 建立第一個文件

1. 訪問 `/docmd/docs/new`
2. 填寫標題和內容
3. 選擇性設定標籤、發布狀態、權限角色
4. 儲存文件

### 上傳圖片

1. 訪問 `/docmd/images`
2. 點擊「上傳圖片」
3. 選擇圖片檔案
4. 複製 Markdown 語法插入到文件中

## 系統需求

- Ruby 3.1.0+
- Rails 8.0.0+
- Redcarpet gem（自動安裝）
- Rolify gem（可選，用於角色管理）
- Pundit gem（可選，用於進階權限控制）

## 貢獻

歡迎提交 Pull Request 或開 Issue 回報問題！

## 授權

本 gem 以 [MIT License](https://opensource.org/licenses/MIT) 開源。