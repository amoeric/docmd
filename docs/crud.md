# CRUD 功能

Docmd 提供完整的文件 CRUD（建立、讀取、更新、刪除）功能，文件以檔案形式儲存在指定的資料夾中。

## Front Matter 格式

文件支援 YAML front matter 來儲存元資料：

```markdown
---
layout: blog  # 可選，指定要使用的 Rails layout template
title: "文件標題"
date: 2025-08-27 11:00 +0800
tags: [rails, ruby, tutorial]
publish: true
roles: [admin, editor]  # 可選，需要 rolify gem
---

## 文件內容

你的 Markdown 內容...
```

### Layout 設定說明

- **未設定 layout**：使用主應用程式的預設 `application` layout
- **設定 layout**：使用指定的 layout template（例如：`layout: blog` 會使用 `app/views/layouts/blog.html.erb`）

這讓你可以為不同類型的文件使用不同的頁面框架：
- 部落格文章可以使用 `blog` layout
- 文件可以使用 `documentation` layout
- 產品頁面可以使用 `product` layout

## 訪問文件管理介面

掛載 engine 後，可以訪問以下路徑：

- `/docmd` - 文件列表
- `/docmd/docs/new` - 新增文件
- `/docmd/docs/:slug` - 檢視文件
- `/docmd/docs/:slug/edit` - 編輯文件

## 文件屬性

每個文件包含以下屬性：
- `title` - 文件標題
- `slug` - URL 路徑（自動從標題或檔名生成）
- `content` - Markdown 內容
- `layout` - 版面配置
- `date` - 發布日期
- `tags` - 標籤陣列
- `publish` - 是否發布
- `roles` - 權限角色（需要 rolify）
- `html_content` - 轉換後的 HTML