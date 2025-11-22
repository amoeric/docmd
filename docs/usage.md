# 使用方式

## 解析單一 Markdown 檔案
```ruby
parser = Docmd::MarkdownParser.new
html_content = parser.parse_file(Rails.root.join('docs', 'example.md'))
```

## 解析 Markdown 字串
```ruby
parser = Docmd::MarkdownParser.new
html = parser.parse("# 標題\n\n這是一段 **粗體** 文字")
```

## 解析所有 Markdown 檔案
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

## 取得所有 Markdown 檔案列表
```ruby
files = Docmd::MarkdownParser.markdown_files
# => ["/path/to/docs/file1.md", "/path/to/docs/file2.md", ...]
```

## 在 Controller 中使用
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