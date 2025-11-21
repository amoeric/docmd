# Docmd
Docmd 是一個 Rails engine gem，用於解析和管理 Markdown 檔案。它使用 Redcarpet gem 來處理 Markdown 內容，並提供簡單的配置方式讓你在 Rails 應用程式中使用。

## 主要功能
- 使用 Redcarpet 解析 Markdown 檔案
- 支援自訂 Markdown 檔案資料夾路徑
- 提供簡單的配置介面
- 支援批量解析多個 Markdown 檔案

## 安裝步驟

### 1. 加入 Gemfile
在你的 Rails 應用程式的 Gemfile 中加入：

```ruby
gem 'docmd', path: 'path/to/docmd'  # 開發階段
# 或
gem 'docmd'  # 從 RubyGems 安裝
```

### 2. 執行 bundle
```bash
$ bundle install
```

### 3. 執行安裝 generator
```bash
$ rails generate docmd:install
```

這會：
- 在 `config/initializers/docmd.rb` 建立配置檔
- 建立 `docs` 資料夾供你放置 Markdown 檔案

### 4. 在 routes.rb 中掛載 engine
```ruby
Rails.application.routes.draw do
  mount Docmd::Engine => "/docmd"
  # 其他路由...
end
```

## 配置

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

## 使用方式

### 解析單一 Markdown 檔案
```ruby
parser = Docmd::MarkdownParser.new
html_content = parser.parse_file(Rails.root.join('docs', 'example.md'))
```

### 解析 Markdown 字串
```ruby
parser = Docmd::MarkdownParser.new
html = parser.parse("# 標題\n\n這是一段 **粗體** 文字")
```

### 解析所有 Markdown 檔案
```ruby
# 取得並解析配置路徑下的所有 .md 檔案
all_docs = Docmd::MarkdownParser.parse_all
# 回傳格式：
# {
#   "folder/file.md" => {
#     path: "/full/path/to/file.md",
#     content: "原始 markdown 內容",
#     html: "轉換後的 HTML",
#     metadata: { filename: "file.md", updated_at: Time, ... }
#   }
# }
```

### 取得所有 Markdown 檔案列表
```ruby
files = Docmd::MarkdownParser.markdown_files
# => ["/path/to/docs/file1.md", "/path/to/docs/file2.md", ...]
```

### 在 Controller 中使用
```ruby
class DocumentsController < ApplicationController
  def index
    @documents = Docmd::MarkdownParser.parse_all
  end

  def show
    parser = Docmd::MarkdownParser.new
    @html_content = parser.parse_file(params[:file_path])
  end
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

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
